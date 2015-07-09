library(shiny)
library(ggvis)
shinyUI(fluidPage(
  titlePanel("House Prices Tracker"),
  sidebarLayout(
    sidebarPanel(
      textInput("dongCode", "DongCode:", "2826010300"),
      sliderInput("period", "Period:", min=2006, max=2015, value=c(2010, 2015)), 
      checkboxGroupInput("pyung", 
                         "Pyung", 
                         list("24-"=24, "28"=28, "33"=33, "40+"=40),
                         selected=33),
      uiOutput("ui") 
    ),
    mainPanel(
#       plotOutput("plot")
      ggvisOutput("plot")
    )
  )
))