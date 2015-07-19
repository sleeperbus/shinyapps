source("helpers.R")

dong = readRDS("data/dong.rds")
seoulDongCode = subset(dong, sidoCode == "11")
result = apply(as.data.frame(seoulDongCode[1:100,3]), 1, f_makeData, 2006, 2015)
result = do.call("rbind", result)
