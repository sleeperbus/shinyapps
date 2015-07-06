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
  
#   output$plot = renderPlot({
#     apts = data() 
#     f_plot2(data=apts, aptCodes=input$aptCodes, pyungs=input$pyung)    
#   })   

  vis = reactive({
    print("ggvis plot active")
    apts = data()
    f_plot2(data=apts, aptCodes=input$aptCodes, pyungs=input$pyung)    
  }) 

  vis %>% bind_shiny("plot")  
})