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
      selectInput("gugun", "구군", choices=list()),
      selectInput("dong", "동", choices=list()),
      actionButton("refreshButton", "적용", icon("refresh"))
		), 
		column(3,
      sliderInput("period", "기간:", min=2006, max=2015, value=c(2013, 2015)),
      checkboxGroupInput("realArea",  "전용면적",
                         list("~35"=0, "36~40"=1, "41~50"=2, "51~60"=3,
                              "61-70"=4, "71~80"=5, "81~90"=6,
                              "91~100"=7, "101~"=8), selected=c(5,6)) 
    ),
		column(3, 
			uiOutput("aptNames")
		)
	) 
))
