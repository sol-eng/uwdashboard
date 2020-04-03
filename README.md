<!-- badges: start -->
[![R build status](https://github.com/kasaai/uwdashboard/workflows/Deploy/badge.svg)](https://github.com/kasaai/uwdashboard/actions)
<!-- badges: end -->

# Underwriting Dashboard

A project to demonstrate automated Shiny app deployment via [GitHub Actions](https://github.com/features/actions)
and [RStudio Connect (RSC)](https://rstudio.com/products/connect/). The app is deployed at [https://colorado.rstudio.com/rsc/content/5218/](https://colorado.rstudio.com/rsc/content/5218/).

## Content

The current content of the dashboard consists of a visualization tool to analyze
additive variable attributions in a personal automobile insurance loss cost model.
The model is built using the [R interface to TensorFlow/Keras](https://tensorflow.rstudio.com/)
and model interpretation is powered by the [DALEX](https://github.com/ModelOriented/DALEX)
package. For details, refer to the paper below and the associated [repo](https://github.com/kasaai/explain-ml-pricing).

*Kevin Kuo and Daniel Lupton.* **Towards Explainability of Machine Learning Models in Insurance Pricing**. [arXiv:2003.10674](https://arxiv.org/abs/2003.10674), 2020.

## Workflow

Changes to the app are proposed via pull requests (PRs). When a new PR is opened,
the code is bundled then deployed as a new temporary app on RSC. At this point,
user testing can be done to ensure that the app is behaving as expected. Upon approval,
one can merge the PR to `master`, which triggers a deployment to the persistent
production endpoint.

## Contributions

Features requests, bug reports, and PRs are all welcome!

