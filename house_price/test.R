source("house_price/helpers.R")
dong = readRDS("house_price/data/dong.rds")
seoulDong = subset(dong, sidoCode == "11")
seoulSample = seoulDong[sample(100), ]

#result = f_readUrl("1168010800", "2015", "1")

#result = apply(as.data.frame(seoulSample[,3]), 1, f_makeData, "2006", "2015")
result = apply(as.data.frame(seoulDong[,3]), 1, f_makeData, "2006", "2015")
result = do.call("rbind", result)
result = na.omit(result)
str(result)
