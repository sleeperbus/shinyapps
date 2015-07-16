library(shiny)
library(ggvis)

sido = readRDS("data/sido.rds")
sido$sidoCode = as.character(sido$sidoCode)
sido$sidoName = as.character(sido$sidoName) 
codes = list()
codes = as.list(sido[,1])
names(codes) = sido[,2]

shinyUI(fluidPage(
  titlePanel("House Prices Tracker"),
	ggvisOutput("plot"),
	hr(),
	fluidRow(
		column(3, 
			h4("지역선택"),
      selectInput("sido", "시도", choices=codes, selected=sido[1,1]),
			br(),
      selectInput("gugun", "구군", choices=list()),
			br(),
      selectInput("dong", "동", choices=list()),
      actionButton("refreshButton", "적용", icon("refresh"))
		), 
		column(3,
      sliderInput("period", "기간:", min=2006, max=2015, value=c(2013, 2015)),
      checkboxGroupInput("pyung", 
                         "Pyung", 
                         list("24-"=24, "28"=28, "33"=33, "40+"=40),
                         selected=33)
		),
		column(3, 
			uiOutput("aptNames")
		)
	) 
))
