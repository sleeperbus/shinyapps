source("helpers.R")

dong = readRDS("data/dong.rds")
seoulDong = subset(dong, sidoCode == "11")
seoulSample = seoulDong[sample(10), ]

result = apply(as.data.frame(dong[,3]), 1, f_makeData, 2006, 2014)
#result = apply(as.data.frame(seoulSample[,3]), 1, f_makeData, 2015, 2015)
#result = apply(as.data.frame(dong[,3]), 1, f_makeData, 2015, 2015)
result = do.call("rbind", result)
result = na.omit(result)
str(result)
saveRDS(result, "data/result.RDS")
