library(shiny)
source("helpers.R")

shinyServer(function(input, output){ 
  data = reactive({
    print("get data active")
    f_makeData(input$dongCode, input$period[1], input$period[2])    
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
  
  f_plot2 = function(data, aptCodes, pyungs) { 
    print("f_plot2 active")
    if (!missing(aptCodes)) {
      if (length(aptCodes) > 0) data= subset(data, APT_CODE %in% aptCodes)             
    }  
    
    if (!missing(pyungs)) {
      if (length(pyungs) > 0) data= subset(data, PYUNG %in% pyungs)             
    }
    
    p = ggvis(data, x = ~SALE_DATE, y = ~SUM_AMT) %>%
      group_by(APT_NAME, PYUNG) %>%
      layer_points(fill = ~factor(APT_NAME)) %>%
      add_tooltip(function(df) df$SUM_AMT)
    return (p)
  }
  
  vis = reactive({
    print("ggvis plot active")
    apts = data()
    f_plot2(data=apts, aptCodes=input$aptCodes, pyungs=input$pyung)    
  }) 

  vis %>% bind_shiny("plot")  
})