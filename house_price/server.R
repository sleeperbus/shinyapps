library(shiny)
source("helpers.R")

minYear = "2006"
maxYear = "2015"

shinyServer(function(input, output){ 
  data = reactive({
    print("get data active")
    f_makeData(input$dongCode, minYear, maxYear)
  })

  output$ui = renderUI({
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
    
    ggvis(result, x=~SALE_DATE, y=~SUM_AMT) %>%
      group_by(APT_NAME, PYUNG) %>%
      layer_points(fill=~factor(APT_NAME), opacity:=0.4) %>%
      layer_smooths(stroke = ~factor(APT_NAME)) %>%
      add_tooltip(function(df) df$SUM_AMT) %>%
      add_axis("x", title="매매시점") %>% 
      add_axis("y", title="매매가격", title_offset=70) 
#      add_legend(title="아파트")
  }) 

  vis %>% bind_shiny("plot")  
})
