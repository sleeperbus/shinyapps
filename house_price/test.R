library(ggvis)
source("helpers.R")
sido = readRDS("data/sido.rds")
gugun = readRDS("data/gugun.rds")
dong = readRDS("data/dong.rds")

# 인천 서구 거래동향
sampleGugunCode = "28260"
sampleGugun = data.frame()
for (year in 2006:2015) {
  fileName = paste0("data/", sampleGugunCode, "_", year, ".rds")
  tmpDf = data.frame()
  tmpDf = readRDS(fileName)
  sampleGugun = rbind(sampleGugun, tmpDf) 
}
str(sampleGugun)
sampleGugun %>%
  ggvis(x=~SALE_DATE) %>% layer_histograms(fill:="red", opacity:=0.7)

# function factoring test
tradeDong = f_getTrade(dong$dongCode[1], 2015, 3)
rentDong = f_getRent(dong$dongCode[1], 2015, 3)
str(rentDong)

# 데이터 가져오기
yearData = f_dongYearData(dong$dongCode[1], 2015, 2015, f_getRent)
