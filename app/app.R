## app.R ##
library(shiny)
library(shinydashboard)
library(tidyverse)
library(DALEX)
library(ggplot2)
library(scales)
library(patchwork)
library(iBreakDown)
library(reticulate)
library(tensorflow)
library(keras)
library(pins)

# Need to use the following branch of {ingredients}
# remotes::install_github("kevinykuo/ingredients", ref = "weights")

pins::board_register_github(name = "cork", repo = "kasaai/cork")
testing_data <- pins::pin_get("toy-model-testing-data", board = "cork")

toy_model <- keras::load_model_tf("model_artifacts/toy-model")
predictors <- c(
  "sex", "age_range", "vehicle_age", "make",
  "vehicle_category", "region"
)

custom_predict <- function(model, newdata) {
  predict(model, newdata, batch_size = 10000)
}

explainer_nn <- DALEX::explain(
  model = toy_model,
  data = testing_data,
  y = testing_data$loss_per_exposure,
  weights = testing_data$exposure,
  predict_function = custom_predict,
  label = "neural_net"
)

ui <- dashboardPage(
  dashboardHeader(title = "Underwriting Dasboard"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Attribution Report", tabName = "report", icon = icon("chart-bar")),
      # Control widget
      selectInput(inputId = "sex", label = "Sex",
                  choices =  testing_data$sex %>% unique()),
      selectInput(inputId = "age_range", label = "Driver Age",
                  choices = testing_data$age_range %>% unique()),
      numericInput(inputId = "vehicle_age", label = "Vehicle Age", value = 0, min = 0),
      selectInput(inputId = "make", label = "Make",
                  choices = testing_data$make %>% unique()),
      selectInput(inputId = "vehicle_category", label = "Vehicle Category",
                  choices = testing_data$vehicle_category %>% unique()),
      selectInput(inputId = "region", label = "Region",
                  choices = testing_data$region %>% unique())
      
    )
  ),    
  dashboardBody(
    tabItems(
      tabItem(tabName = "report",
              box(
                verbatimTextOutput("text1"),
                width = 12
              ),
              box(
                plotOutput("plot1"),
                width = 12
              )

      )
    )
  )
)

server <- function(input, output) {
  newdata <- reactive({
    tibble(
      sex = input$sex,
      age_range = input$age_range,
      vehicle_age = as.double(input$vehicle_age),
      make = input$make,
      vehicle_category = input$vehicle_category,
      region = input$region
    )
  })
  
  breakdown <- reactive(iBreakDown::break_down(explainer_nn, newdata()))
  
  output$text1 <- renderText({
    prediction <- predict(toy_model, newdata()) %>% 
      as.vector()
    
    main_contributions <- breakdown() %>% 
      as.data.frame() %>% 
      select(variable_name, variable_value, contribution, sign) %>% 
      filter(abs(contribution) > 100,
             !variable_name %in% c("intercept", "")) %>% 
      mutate(words = glue::glue(
        '`{variable_name}` is "{variable_value}"',
        ' (', '{ifelse(sign == 1, "+", "")}',
        '{scales::dollar(contribution, prefix = "$R")})')
      )
    
    words_higher_risk <- main_contributions %>% 
      filter(sign == 1) %>% 
      pull(words)
    
    words_lower_risk <- main_contributions %>% 
      filter(sign == -1) %>% 
      pull(words)
    
    glue::glue(
      "The predicted loss cost for the selected policy is ", 
      "{scales::dollar(prediction, prefix = 'R$')}",
      "\n\n",
      "Higher risk characteristics:", "\n",
      glue::glue_collapse(paste0(" - ", words_higher_risk), sep = "\n"),
      "\n",
      "Lower risk characteristics:", "\n",
      glue::glue_collapse(paste0(" - ", words_lower_risk), sep = "\n")
    )
  })
  
  output$plot1 <- renderPlot({
    df <- breakdown() %>%
      as.data.frame() %>%
      mutate(start = lag(cumulative, default = first(contribution)),
             label = formatC(contribution, digits = 2, format = "f")) %>%
      mutate_at("label",
                ~ ifelse(!variable %in% c("intercept", "prediction") & .x > 0,
                         paste0("+", .x),
                         .x))
    
    df %>%
      ggplot(aes(reorder(variable, position), fill = sign,
                 xmin = position - 0.40,
                 xmax = position + 0.40,
                 ymin = start,
                 ymax = cumulative)) +
      geom_rect(alpha = 0.4) +
      geom_errorbarh(data = df %>% filter(variable_value != ""),
                     mapping = aes(xmax = position - 1.40,
                                   xmin = position + 0.40,
                                   y = cumulative), height = 0,
                     linetype = "dotted",
                     color = "blue") +
      geom_rect(
        data = df %>% filter(variable %in% c("intercept", "prediction")),
        mapping = aes(xmin = position - 0.4,
                      xmax = position + 0.4,
                      ymin = start,
                      ymax = cumulative),
        color = "black") +
      scale_fill_manual(values = c("blue","orange", NA)) +
      coord_flip() +
      theme_bw() +
      theme(legend.position = "none") +
      geom_text(
        aes(label = label,
            y = pmax(df$cumulative,  df$cumulative - df$contribution)),
        nudge_y = 10,
        hjust = "inward",
        color = "black"
      ) +
      xlab("Variable") +
      ylab("Contribution") +
      theme(axis.text.y = element_text(size = 10))
  })
}

shinyApp(ui, server)