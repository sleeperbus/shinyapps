library(shiny)
source("helpers.R")

apts = data.frame() 

shinyServer(function(input, output){
    data = reactive({
        f_makeData(input$dongCode, input$period[1], input$period[2])    
    })
    
    output$ui = renderUI({
    })
    
    output$plot = renderPlot({
        apts = data() 
        f_plot(apts)    
    }) 
})