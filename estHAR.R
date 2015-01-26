library(highfrequency)
library(xts)
library(doParallel)
registerDoParallel(cores = 32)
crncy = list("AUDUSD", "EURUSD", "GBPUSD", "NZDUSD", "USDCAD", "USDCHF", "USDJPY", "USDNOK", "USDSEK")


estHARcrncy = function(crncy){
  filename_xtsRV = paste("/data/", crncy, "_RV", ".RData", sep = "")
  load(xtsRV)
  
  dRV = foreach(t = 1:length(xtsRV)) %dopar% {
    if (index(xtsRV)[t] > as.Date("2004-07-01")) {
      xtsKnown = xtsRV[1:t-1]
      model = harModel(xtsRV, periods = c(1, 5, 22), RVest = "rCov", type = "HARRV")
      predict(model, newdata = xtsRV[1:t])[t]
    } else {
      NA
    }
  }
  xtsdRV = xts(dRV, index(xtsRV))
  
  filename_xtsdRV = paste("/data/", crncy, "_dRV", ".RData", sep = "")
  save(xtsRV, filename_xtsdRV) 
}

ls_xtsdRV = llply(crncy, estHARcrncy, .parallel = TRUE)

xtsdRV = Reduce("+", ls_xtsdRV, ls_xtsdRV * 0) / length(ls_xtsdRV)
filename_xtsdRV = paste("/data/", "GlobalFX", "_dRV", ".RData", sep = "")
save(xtsRV, filename_xtsdRV) 

?Reduce
