library(highfrequency)
library(xts)
library(doParallel)
library(plyr)
registerDoParallel(cores = 16)
crncy = list("AUDUSD", "EURUSD", "GBPUSD", "NZDUSD", "USDCAD", "USDCHF", "USDJPY", "USDNOK", "USDSEK")
# crncy = "AUDUSD"

estHARcrncy = function(crncy){
  filename_xtsRV = paste("/data/", crncy, "_RV", ".RData", sep = "")
  load(filename_xtsRV)
#   
#   xtsFX_daily = apply.daily(xtsFX, tail, 1)
#   x[endpoints(x, "weeks")]
  
  model = harModel(xtsRV, periods = c(1, 5, 22, 50), RVest = "rCov", type = "HARRV")
#   
#   dRV = foreach(t = 23:length(xtsRV), .packages = c("highfrequency", "xts")) %dopar% {
# #     if (index(xtsRV)[t] > as.POSIXct("2004-07-01")) {
# #       xtsKnown = xtsRV[1:(t-1)]
#    predict(model)[t-22]
# #    length(   predict(model))
# #     } else {
#       NA
# #     }
#   }
#   xtsdRV = xts(dRV, index(xtsRV))

  xtsdRV = c(xtsRV[1:50] * NA, residuals(model))

  
  filename_xtsdRV = paste("/data/", crncy, "_dRV", ".RData", sep = "")
  save(xtsRV, file = filename_xtsdRV) 
  xtsdRV
}

ls_xtsdRV = llply(crncy, estHARcrncy, .parallel = TRUE)
l_ply(ls_xtsdRV, plot)

xtsdRV = Reduce("+", ls_xtsdRV[-4], ls_xtsdRV[[1]] * 0) / length(ls_xtsdRV)
filename_xtsdRV = paste("/data/", "GlobalFX", "_dRV", ".RData", sep = "")
save(xtsdRV, file = filename_xtsdRV) 

?Reduce

plot(xtsdRV[1:3336] > 0)
# xtsFX[endpoints(xtsFX, "weeks")]
xtsFXr_v = ldply(xtsFX_split, function(x) {
  log(last(as.numeric(x),1)) - log(first(as.numeric(x),1))[1]
#   index(x)[1]
  })[[1]]
Dates = ldply(xtsFX_split, function(x) index(x)[1] )[[1]]
xtsFXr = xts(xtsFXr_v, Dates)

x1 = merge(xtsFXr,xtsdRV)
plot(x1)
names(x1) = c("r", "dRV")
library(data.table)
x2 = as.data.frame(x1[1:3300])
x2 = data.table(x2)
x2[, ldRV := c(NA, dRV[1:(length(dRV)-1)])]
m = lm("r ~ ldRV", x2)
summary(m)
summary(x2)
sd(x2$r ) * sqrt(250)

plot(x2$dRV, type = "l")

