source("helpers.R")

sidos = readRDS("data/sido.rds")
guguns = readRDS("data/gugun.rds")
dongs = readRDS("data/dong.rds")

#apply(as.data.frame(dong[,3]), 1, f_dataToFile, 2006, 2015)

for (curGugunCode in guguns[,2]) {
  dongCodes = data.frame()
  result = data.frame()
  curDongs = subset(dongs, gugunCode == curGugunCode)
  for (year in 2006:2006) {
    result = apply(as.data.frame(curDongs[,3]), 1, f_dongYearData, year, year)
    result = do.call("rbind", result)
    fileName = paste(paste(curGugunCode, year, sep="_"), "rds", sep=".")
    saveRDS(result, paste("data", fileName, sep="/"))
  }
}


