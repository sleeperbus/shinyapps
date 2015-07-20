library(jsonlite)
library(stringr)

f_readUrl = function(dongCode, year, period) {
	message(paste("now: ", dongCode, "-", year, "-", period))
	data = tryCatch(
		{
			message(paste(year, "-", period))
			url = paste0("http://rt.molit.go.kr/rtApt.do?cmd=getTradeAptLocal&dongCode=", 
				dongCode, "&danjiCode=ALL&srhYear=", year,
				"&srhPeriod=", period, "&gubunRadio2=1") 
			rawData = readLines(url, encoding="UTF-8")
			data = fromJSON(rawData) 
			aptInfo = as.data.frame(data[1])
			prices = as.data.frame(data[2]) 
			if (nrow(prices) > 0) {
				names(aptInfo) = c("APT_NAME", "AREA_CNT", "APT_CODE", "BORM", 
					"BUILD_YEAR", "BUBN")
        aptInfo$DONG_CODE = dongCode
				names(prices) = c("SALE_MONTH", "SUM_AMT", "SALE_DAYS", "APT_CODE", 
					"FLOOR", "AREA")
				tempApts = merge(aptInfo, prices, by="APT_CODE") 
				tempApts$SALE_YEAR = year
				tempApts 
			} else {
				NULL
			}
		}, 
		error = function(cond) {
			message(paste(dongCode, year, "-", period, "failed."))
			message(cond)
			return(NA)
		} 
	)
	return(data)
}

f_makeData = function(dongCode, from, to) {
	print(paste("f_makeData in with dongCode", dongCode,
		"from", from, "to", to))
	apts = data.frame()
	for (srhYear in from:to) {
		for (srhPeriod in 1:4) {
			tempApts = f_readUrl(dongCode, srhYear, srhPeriod)		

			if (!is.null(tempApts)) {
				apts = rbind(apts, tempApts)
			}
		}
	}  

	if (nrow(apts) == 0) return(NA)
	
	apts$SALE_MONTH = str_pad(apts$SALE_MONTH, 2, pad="0")
	apts$SALE_DAYS= str_pad(apts$SALE_DAYS, 2, pad="0")
	apts$SUM_AMT = as.numeric(gsub(",", "", apts$SUM_AMT))
	apts$SALE_DATE = do.call(paste0, apts[,c("SALE_YEAR", "SALE_MONTH", "SALE_DAYS")])
	apts$SALE_DATE = strptime(apts$SALE_DATE, "%Y%m%d")
	apts$SALE_DATE = as.Date(apts$SALE_DATE)
	apts$AREA = round(as.numeric(apts$AREA))
	apts = apts[with(apts, order(SALE_DATE)),]
	
	apts$REAL_AREA = -1
	apts$REAL_AREA_DESC = ""  
	apts[which(apts$AREA <= 35), c("REAL_AREA")] = 0
	apts[which(apts$AREA <= 35), c("REAL_AREA_DESC")] = "(~35)"
	apts[which(apts$AREA >= 36 & apts$AREA <= 40), c("REAL_AREA")] = 1
	apts[which(apts$AREA >= 36 & apts$AREA <= 40), c("REAL_AREA_DESC")] = "(36~40)"
	apts[which(apts$AREA >= 41 & apts$AREA <= 50), c("REAL_AREA")] = 2
	apts[which(apts$AREA >= 41 & apts$AREA <= 50), c("REAL_AREA_DESC")] = "(41~50)"
	apts[which(apts$AREA >= 51 & apts$AREA <= 60), c("REAL_AREA")] = 3
	apts[which(apts$AREA >= 51 & apts$AREA <= 60), c("REAL_AREA_DESC")] = "(51~60)"
	apts[which(apts$AREA >= 61 & apts$AREA <= 70), c("REAL_AREA")] = 4
	apts[which(apts$AREA >= 61 & apts$AREA <= 70), c("REAL_AREA_DESC")] = "(61~70)"
	apts[which(apts$AREA >= 71 & apts$AREA <= 80), c("REAL_AREA")] = 5
	apts[which(apts$AREA >= 71 & apts$AREA <= 80), c("REAL_AREA_DESC")] = "(71~80)"
	apts[which(apts$AREA >= 81 & apts$AREA <= 90), c("REAL_AREA")] = 6
	apts[which(apts$AREA >= 81 & apts$AREA <= 90), c("REAL_AREA_DESC")] = "(81~90)"
	apts[which(apts$AREA >= 91 & apts$AREA <= 100), c("REAL_AREA")]  = 7
	apts[which(apts$AREA >= 91 & apts$AREA <= 100), c("REAL_AREA_DESC")] = "(91~100)"
	apts[which(apts$AREA >= 101), c("REAL_AREA")]  = 8
	apts[which(apts$AREA >= 101), c("REAL_AREA_DESC")] = "(101~)"
	
	apts$TOOL_TIP = ""  
	apts$TOOL_TIP = with(apts, paste(APT_NAME, paste0(AREA, "m2"), SUM_AMT, SALE_DATE, sep="/"))
	
	apts$APT_NAME = factor(apts$APT_NAME)
	apts$GROUP = do.call(paste0, list(apts$APT_NAME, apts$REAL_AREA_DESC))
	apts$GROUP = factor(apts$GROUP)
	return (apts)
}

