library(jsonlite)
library(stringr)
library(ggplot2)
library(scales)
library(ggvis)

f_makeData = function(dongCode, from, to) {
  apts = data.frame()
  for (srhYear in from:to) {
    for (srhPeriod in 1:4) {
      url = paste0("http://rt.molit.go.kr/rtApt.do?cmd=getTradeAptLocal&dongCode=", 
                   dongCode, "&danjiCode=", "ALL", "&srhYear=", srhYear,
                   "&srhPeriod=", srhPeriod, "&gubunRadio2=", "1")
      rawData = readLines(url, warn="F", encoding="UTF-8")
      data = fromJSON(rawData) 
      aptInfo = as.data.frame(data[1])
      prices = as.data.frame(data[2]) 
      if (nrow(prices) > 0) {
        names(aptInfo) = c("APT_NAME", "AREA_CNT", "APT_CODE", "BORM", 
                           "BUILD_YEAR", "BUBN")
        names(prices) = c("SALE_MONTH", "SUM_AMT", "SALE_DAYS", "APT_CODE", 
                          "FLOOR", "AREA")
        tempApts = merge(aptInfo, prices, by="APT_CODE") 
        tempApts$SALE_YEAR = srhYear
        apts = rbind(apts, tempApts) 
      }
    }
  } 
  apts$SALE_MONTH = str_pad(apts$SALE_MONTH, 2, pad="0")
  apts$SALE_DAYS= str_pad(apts$SALE_DAYS, 2, pad="0")
  apts$SUM_AMT = as.numeric(gsub(",", "", apts$SUM_AMT))
  apts$SALE_DATE = do.call(paste0, apts[,c("SALE_YEAR", "SALE_MONTH", "SALE_DAYS")])
  apts$SALE_DATE = strptime(apts$SALE_DATE, "%Y%m%d")
  apts$SALE_DATE = as.Date(apts$SALE_DATE)
  apts$AREA = round(as.numeric(apts$AREA))
  apts = apts[with(apts, order(SALE_DATE)),]
  apts$PYUNG = 0
  apts[with(apts, AREA < 70 ),]$PYUNG = 24
  apts[with(apts, AREA >= 70 & AREA < 80),]$PYUNG = 28
  apts[with(apts, AREA >= 80 & AREA < 90),]$PYUNG = 33
  apts[with(apts, AREA >= 90),]$PYUNG = 40
  apts$ENG_NAME = ""
  return (apts)
}

f_plot = function(data, aptCodes, baseDate, pyungs) { 
  if (!missing(aptCodes)) {
    if (length(aptCodes) == 1 & aptCodes[1] == "") finalData = data.frame()
    else if (length(aptCodes) > 0) data= subset(data, APT_CODE %in% aptCodes)             
  } 
  
  if (!missing(baseDate)) data = subset(data, SALE_DATE >= as.Date(baseDate, "%Y%m%d"))    
  
  if (!missing(pyungs)) {
    if (length(pyungs) > 0) data= subset(data, PYUNG %in% pyungs)             
  } 
  
  p = ggplot(data=data, aes(x=SALE_DATE, y=SUM_AMT, 
                            group=interaction(APT_NAME, PYUNG), 
                            color=interaction(APT_NAME, PYUNG))) +
    geom_smooth() +
    geom_point(size=2) +
    scale_x_date(breaks = date_breaks(width="1 year")) +
    scale_y_continuous(breaks=seq(10000,90000,1000)) +
    theme(text=element_text(family="Gulim"))
#    theme(text=element_text(family="Apple SD Gothic Neo"))
  return (p)
}


