# server.R

library(quantmod)
source("helpers.R")

shinyServer(function(input, output) {
  data = reactive({
    getSymbols(input$symb, src="yahoo", from=input$dates[1],
               to=input$dates[2], auto.assign=F)      
  })
  
  finalData = reactive({
    if (!input$adjust) return(data())
    adjust(data())
  })

  output$plot <- renderPlot({ 
    chartSeries(finalData(), theme = chartTheme("white"), 
      type = "line", log.scale = input$log, TA = NULL)
  })
  
})