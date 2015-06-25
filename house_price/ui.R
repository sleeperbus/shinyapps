library(shiny)
shinyUI(fluidPage(
  titlePanel("House Prices Tracker"),
  sidebarLayout(
    sidebarPanel(
      textInput("dongCode", "DongCode:", "2826010300"),
      sliderInput("period", "Period:", min=2006, max=2015, value=c(2011, 2015))
    ),
    mainPanel()
  )
))