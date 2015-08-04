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

shinyServer(function(input, output, clientData, session){ 
  tooltip = function(df) {
    if (is.null(df)) return(NULL)
    apts = data()
    row = apts[apts$ID == df$ID,]
    return(row$TOOL_TIP)
  }
  
	newDongCode = eventReactive(input$refreshButton, { 
		print("newDongCode in")
		print(paste("newDongCode is", input$dong))
		input$dong
		})
	
	data = reactive({ 
		print("data in")
    curGugunCode = ""
		curDongCode = ""
		t = try(newDongCode())  
		if ("try-error" %in% class(t)) {
      curGugunCode = "11680"
      curDongCode = "1168010300"
		} else {
      curGugunCode = input$gugun  
      curDongCode = newDongCode() 
		}
		message(paste("selected dongCode is", curDongCode))
    apts = data.frame()
    for (year in input$period[1]:input$period[2]) {
      fileName = paste(paste(curGugunCode, year, sep="_"), "rds", sep=".")
      fileName = paste("data", fileName, sep="/")
      if (file.exists(fileName)) {
        yearApts = readRDS(fileName) 
        apts = rbind(apts, yearApts)
      }  
    }  
    apts = subset(apts, DONG_CODE == curDongCode)
    if (nrow(apts) == 0) return(NULL)
    apts$ID = 1:nrow(apts)
    return(apts)
	})
	
	output$aptNames = renderUI({
		print("aptNames in")
		apts = data() 
		aptNames = list()
		uniqueApts = apts[, c("APT_NAME", "APT_CODE")]
		uniqueApts = uniqueApts[!duplicated(uniqueApts),]
		aptNames = as.list(uniqueApts[,2])
		names(aptNames) = uniqueApts[,1]
		checkboxGroupInput("aptCodes", "", choices=aptNames) 
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
  
  observe({
		print("vis in")
		apts = data()
    if (nrow(apts) == 0) return(NULL)
		aptCodes = input$aptCodes
		realArea = input$realArea
		
		result = subset(apts, SALE_YEAR >= input$period[1] & SALE_YEAR <= input$period[2])
		result = subset(result, APT_CODE %in% aptCodes)
		result = subset(result, REAL_AREA%in% realArea)
		result$APT_NAME = factor(result$APT_NAME, ordered=F)
		result$GROUP = factor(result$GROUP)
		
		ggvis(result, x=~SALE_DATE, y=~SUM_AMT, fill=~GROUP, stroke=~GROUP) %>%
		layer_points(opacity:=0.4, key :=~ID) %>%
		add_tooltip(tooltip, "hover") %>%
		group_by(GROUP) %>%
		layer_smooths(span=1) %>%
		add_axis("x", title="매매시점") %>% 
		add_axis("y", title="매매가격", title_offset=70) %>%
    bind_shiny("plot")
		})  
	})
