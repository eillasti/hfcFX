
library(highfrequency)
library(data.table)
library(xts)
library(rugarch)

crncy = "USDCAD"
filename = paste("/data/", "USDCAD", ".csv", sep = "")
colClasses = c("character", "numeric", "numeric", "numeric", "numeric")
dtRaw = fread(filename, sep = ",", header = FALSE, colClasses = colClasses)
setnames(dtRaw, c("TimeChr", "BID", "OFR", "BIDSIZ", "OFRSIZ"))
Time = as.POSIXct(strptime(dtRaw$TimeChr, format="%Y.%m.%d %H:%M:%OS"))
dtRaw[, TimeChr := 0]
dtRaw[, Time := Time]
filename_dtRaw = paste("/data/", crncy, "_raw", ".RData", sep = "")
save(dtRaw, file=filename_dtRaw)
rm(dtRaw)
gc()

Price = (dtRaw$BID + dtRaw$OFR) / 2
xtsFX = xts(Price, Time)
filename_xtsFX = paste("/data/", crncy, "_ticks", ".RData", sep = "")
save(xtsFX, file=filename_xtsFX)
rm(xtsFX)

xtsFXs = aggregatePrice(xtsFX, on = "seconds", k=1, marketopen = "00:00:01", marketclose = "23:59:59")
filename_xtsFXs = paste("/data/", crncy, "_seconds", ".RData", sep = "")
save(xtsFXs, file=filename_xtsFXs)

xtsFXm = aggregatePrice(xtsFX, on = "minutes", k=1, marketopen = "00:00:01", marketclose = "23:59:59")
filename_xtsFXm = paste("/data/", crncy, "_minutes", ".RData", sep = "")
save(xtsFXm, file=filename_xtsFXm)

xtsR = makeReturns(xtsFXs)


# 
# 
# install.packages("rugarch", dependencies = "Suggests")
# 
# install.packages("ks")
# ?install.packages
# library(rugarch)
# 
# spotVol = spotvol(xtsFXs, 
#                   method = "GARCH", 
#                   garchorder = c(1,1),
#                   dist = "norm",
#                   P1 = 2, 
#                   P2 = 2,
#                   on = "seconds", 
#                   k = 5,
#                   marketopen = "00:00:01", 
#                   marketclose = "23:59:59")
# 
# 
# xtsVol = rKernelCov()
# 
# ?rKernelCov
# 
# gc()
# 
# xtsRV1sec = rKernelCov(r["2007-01"], makeReturns = FALSE, kernel.param = 1, align.period = 1)
# xtsRV2sec = rKernelCov(r["2007-01"], makeReturns = FALSE, kernel.param = 1, align.period = 2)
# xtsRV4sec = rKernelCov(r["2007-01"], makeReturns = FALSE, kernel.param = 1, align.period = 4)
# xtsRV8sec = rKernelCov(r["2007-01"], makeReturns = FALSE, kernel.param = 1, align.period = 8)
# xtsRV16sec = rKernelCov(r["2007-01"], makeReturns = FALSE, kernel.param = 1, align.period = 16)
# 
# plot(sqrt(xtsRV1sec * 365))
# lines(sqrt(xtsRV2sec * 365))
# lines(sqrt(xtsRV4sec * 365))
# lines(sqrt(xtsRV8sec * 365))
# lines(sqrt(xtsRV16sec * 365))
# 
# xtsRV2sec[1]
# xtsRV4sec[1]
# 
# rKernel.available
# 
# xtsFXs = aggregatePrice(xtsFX, on = "seconds", k=1, marketopen = "00:00:01", marketclose = "23:59:59")
# 
# 
# xtsFX1 = xtsFX[1:1000000]
# r1 = r[1:10000000]
# r1[1]
# r2 = r1["2004-01-01"]
# r2
# r1[10000000]
# m1 = harModel(r1)
# summary(m1)
# harModel(data, periods = c(1, 5, 22), periodsJ = c(1,5,22), leverage=NULL,
#          RVest = c("rCov", "rBPCov"), type = "HARRV", jumptest = "ABDJumptest",
#          alpha = 0.05, h = 1, transform = NULL, ...
# 
# m2 = rKernelCov(xtsFX1, makeReturns = TRUE)
# m2
# 
# data(sample_tdata)
# rvKernel = rKernelCov( rdata = sample_tdata$PRICE, period = 5, align.by ="minutes",
#                        align.period=5, makeReturns=TRUE)
# sample_tdata[8000]
# 
# m2
#          
#          rKernelCov(rdata, cor = FALSE, kernel.type = "rectangular", kernel.param = 1,
#                     kernel.dofadj = TRUE, align.by = "seconds", align.period = 1,
#                     cts = TRUE, makeReturns = FALSE, type = NULL, adj = NULL,
#                     q = NULL, ...)
#          
#          
# p[1]
# ?xts
# aggregatePrice(ts,FUN = previoustick,on="minutes",k=1,
#                marketopen = "09:30:00", marketclose = "16:00:00", tz = "GMT"
# 
# 
# 
# dt1 = dt[1:1000]
# 
# Time = as.POSIXct(strptime(dt1$Time, format="%Y.%m.%d %H:%M:%OS"))
# Time[1]
# length(Time)
# as.POSIXct(dt1[1]$Time, format = )
# 
# as.POSIXct("2004.01.01 00:00:01.779", format = "%Y.%m.%d %H:%M:%OS")
# 
# ?as.POSIXct
# ?strptime
# str(dt)
# 
# loadData <- function(file) {
#   data <- read.csv(file, sep = ",")
#   data$Time <- as.POSIXct(strptime(data$Time, format="%d.%m.%Y %H:%M:%OS"))
#   data <- as.xts(data[,2:6], order.by=data$Time)
#   data[data$Volume != 0,]
# }
