library(shiny)
source("helpers.R")



shinyServer(function(input, output){
  apts = data.frame() 
  aptNames = list()
  
  data = reactive({
    f_makeData(input$dongCode, input$period[1], input$period[2])    
  })
    
  output$ui = renderUI({
    uniqueApts = apts[, c("APT_NAME", "APT_CODE")]
    uniqueApts = uniqueApts[,!duplicated(uniqueApts)]
    aptNames = as.list(uniqueApts[,2])
    names(aptNames) = uniqueApts[,1]
    checkboxGroupInput("aptCodes", "Select APTs", choices=aptNames)
  })
    
  output$plot = renderPlot({
    apts = data() 
    f_plot(apts)    
  }) 
})