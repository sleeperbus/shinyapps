library(shiny)
source("helpers.R")

shinyServer(function(input, output){ 
  data = reactive({
    f_makeData(input$dongCode, input$period[1], input$period[2])    
  })

  output$ui = renderUI({
    apts = data()
    aptNames = list()
    uniqueApts = apts[, c("APT_NAME", "APT_CODE")]
    uniqueApts = uniqueApts[!duplicated(uniqueApts),]
    aptNames = as.list(uniqueApts[,2])
    names(aptNames) = uniqueApts[,1]
    checkboxGroupInput("aptCodes", "Select APTs", choices=aptNames)
  })    
  
  output$plot = renderPlot({
    apts = data() 
    f_plot(data=apts, aptCodes=input$aptCodes, pyungs=input$pyung)    
  })   
})