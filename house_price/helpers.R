library(jsonlite)
library(stringr)
library(ggplot2)
library(scales)

f_makeData = function(dongCode, from, to) {
  print(paste("f_makeData in with dongCode", dongCode,
              "from", from, "to", to))
  apts = data.frame()
  for (srhYear in from:to) {
    for (srhPeriod in 1:4) {
      url = paste0("http://rt.molit.go.kr/rtApt.do?cmd=getTradeAptLocal&dongCode=", 
                   dongCode, "&danjiCode=ALL&srhYear=", srhYear,
                   "&srhPeriod=", srhPeriod, "&gubunRadio2=1")
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
  
  apts[which(apts$AREA < 70), c("PYUNG")]  = 24 
  apts[which(apts$AREA >= 70 & apts$AREA < 80), c("PYUNG")]  = 28
  apts[which(apts$AREA >= 80 & apts$AREA < 90), c("PYUNG")]  = 33
  apts[which(apts$AREA >= 90), c("PYUNG")]  = 38

  apts$ENG_NAME = ""
  apts$APT_NAME = factor(apts$APT_NAME)
  apts$GROUP = do.call(paste0, list(apts$APT_NAME, "-", apts$PYUNG))
  apts$GROUP = factor(apts$GROUP)
#   print(unique(apts$GROUP))
  return (apts)
}


