library(shiny)
shinyUI(fluidPage(
  titlePanel("House Prices Tracker"),
  sidebarLayout(
    sidebarPanel(
      textInput("dongCode", "DongCode:", "2826010300"),
      sliderInput("period", "Period:", min=2006, max=2015, value=c(2013, 2015)), 
      checkboxGroupInput("pyung", "Pyung", list("24-"=1, "28"=2, "33"=3, "40+"=4)),
      uiOutput("ui") 
    ),
    mainPanel(plotOutput("plot"))
  )
))