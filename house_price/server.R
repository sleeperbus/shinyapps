library(shiny)
source("helpers.R")

sido = readRDS("data/sido.rds")
sido$sidoCode = as.character(sido$sidoCode)
sido$sidoName = as.character(sido$sidoName)

gugun = readRDS("data/gugun.rds")
gugun$sidoCode = as.character(gugun$sidoCode)
gugun$gugunCode = as.character(gugun$gugunCode)
gugun$gugunName = as.character(gugun$gugunName)

dong = readRDS("data/dong.rds")
dong$sidoCode = as.character(dong$sidoCode)
dong$gugunCode = as.character(dong$gugunCode)
dong$dongCode = as.character(dong$dongCode)
dong$dongName = as.character(dong$dongName) 

minYear = "2006"
maxYear = "2015"

shinyServer(function(input, output){ 
  data = reactive({
    print("get data active")
    data = f_makeData("2826010300", minYear, maxYear)
    return(data)
  })
   
  output$sido = renderUI({
    codes = list()
    codes = as.list(sido[,1])
    names(codes) = sido[,2]
    selectInput("sido", "Sido", choices=codes, selected=sido[1,1])
  })
  
  output$gugun = renderUI({
    codes = list()
    print(input$sido)
    selectedGugun = subset(gugun, sidoCode == input$sido)
    codes = as.list(selectedGugun[,2])
    names(codes) = selectedGugun[,3]
    selectInput("gugun", "Gugun", choices=codes, selected=selectedGugun[1,2])   
  })
  
  output$aptNames = renderUI({
    print("dynamic ui active")
    apts = data()
    aptNames = list()
    uniqueApts = apts[, c("APT_NAME", "APT_CODE")]
    uniqueApts = uniqueApts[!duplicated(uniqueApts),]
    aptNames = as.list(uniqueApts[,2])
    names(aptNames) = uniqueApts[,1]
    checkboxGroupInput("aptCodes", "Select APTs", choices=aptNames,
                       selected=uniqueApts[1,1])
  })    
  
  vis = reactive({
    print("ggvis plot active")
    apts = data()
    aptCodes = input$aptCodes
    pyungs = input$pyung
    
    result = subset(apts, SALE_YEAR >= input$period[1] & SALE_YEAR <= input$period[2])
		result = subset(result, APT_CODE %in% aptCodes)
    result = subset(result, PYUNG %in% pyungs)
    result$APT_NAME = factor(result$APT_NAME, ordered=F)
    result$PYUNG = factor(result$PYUNG)
    result$GROUP = factor(result$GROUP)
    
    ggvis(result, x=~SALE_DATE, y=~SUM_AMT) %>%
      group_by(GROUP) %>%
      layer_points(fill=~GROUP, opacity:=0.4) %>%
      layer_smooths(stroke= ~GROUP) %>%
      add_tooltip(function(df) df$SUM_AMT) %>%
      add_axis("x", title="매매시점") %>% 
      add_axis("y", title="매매가격", title_offset=70) 
  }) 

  vis %>% bind_shiny("plot")  
})
