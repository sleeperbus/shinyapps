library(shiny)
library(ggvis)
shinyUI(fluidPage(
  titlePanel("House Prices Tracker"),
	ggvisOutput("plot"),
	hr(),
	fluidRow(
		column(3, 
			h4("Region"),
			uiOutput("sido"),
			br(),
			uiOutput("gugun"),
			br(),
			uiOutput("dong")
		), 
		column(3,
      sliderInput("period", "Period:", min=2006, max=2015, value=c(2010, 2015))
      checkboxGroupInput("pyung", 
                         "Pyung", 
                         list("24-"=24, "28"=28, "33"=33, "40+"=40),
                         selected=33)
		),
		column(3, 
			h4("Select APTs"),
			uiOutput("aptNames")
		)
	) 
))
