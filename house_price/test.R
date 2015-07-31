library(ggvis)
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

