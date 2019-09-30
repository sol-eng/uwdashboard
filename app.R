## app.R ##
library(shiny)
library(shinydashboard)

ui <- dashboardPage(
  dashboardHeader(title = "Underwriting Dashboard"),
  dashboardSidebar(
    sidebarMenu(
      # Dashboard
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      # Report
      menuItem("Policy Report", tabName = "report", icon = icon("chart-line")),
      # Control widget
      selectInput(inputId = "category", label = "Select input",
                  choices = c("Option 1", "Option 2"),
                  selected = "Option 1", multiple = TRUE)
    )
  ),    
  dashboardBody(
    tabItems(
      # First tab 
      tabItem(tabName = "dashboard",
              fluidRow(
                # Box 1
                box("placeholder text", width = 7),
                
                # Box 2
                box("placeholder text", width = 5)
              )
      ),
      
      # Second tab
      tabItem(tabName = "report",
              # tab content
              box("placeholder text")

      )
    )
  )
)

server <- function(input, output) {
  
}

shinyApp(ui, server)