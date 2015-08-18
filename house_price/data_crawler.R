source("helpers.R")

sidos = readRDS("data/sido.rds")
guguns = readRDS("data/gugun.rds")
dongs = readRDS("data/dong.rds")

testRentData = f_crawler(2015, 2015, "r", f_getRent)
