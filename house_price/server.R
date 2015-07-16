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

shinyServer(function(input, output, clientData, session){ 
  apts = data.frame()  
  
  newDongCode = eventReactive(input$refreshButton, {
    print("newDongCode in")
    print(paste("newDongCode is", input$dong))
    input$dong
  })
  
  data = reactive({
    print("data in")
    code = ""
    t = try(newDongCode())  
    if ("try-error" %in% class(t)) code = "1168010300"
    else code = newDongCode()
    print(paste("selected dongCode is", code))
    apts = f_makeData(code, input$period[1], input$period[2]) 
  })
  
  output$aptNames = renderUI({
    print("aptNames in")
    apts = data() 
    aptNames = list()
    uniqueApts = apts[, c("APT_NAME", "APT_CODE")]
    uniqueApts = uniqueApts[!duplicated(uniqueApts),]
    aptNames = as.list(uniqueApts[,2])
    names(aptNames) = uniqueApts[,1]
#     checkboxGroupInput("aptCodes", "아파트를 선택하세요.", choices=aptNames,
#                        selected=uniqueApts[1,1])
    checkboxGroupInput("aptCodes", "아파트를 선택하세요.", choices=aptNames)
                       
  })    
  
  observe({
    print("observe gugun in")
    sidoCode = input$sido    
    
    codes = list()
    selectedGugun = subset(gugun, sidoCode == input$sido)
    codes = as.list(selectedGugun[,2])
    names(codes) = selectedGugun[,3] 
    updateSelectInput(session, "gugun", "구군", 
                      choices=codes, selected=selectedGugun[1,2])     
  })

  observe({
    print("observe dong in")
    sidoCode = input$sido
    gugunCode = input$gugun
    
    codes = list()
    selectedDong = subset(dong, sidoCode == input$sido & gugunCode == input$gugun)
    codes = as.list(selectedDong[,3])
    names(codes) = selectedDong[,4]
    updateSelectInput(session, "dong", "동", choices=codes, selected=selectedDong[1,3])  
  })
  
  vis = reactive({
    print("vis in")
    print(df)
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
