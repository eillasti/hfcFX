library(highfrequency)
library(xts)
library(doParallel)
registerDoParallel(cores = 32)
crncy = list("AUDUSD", "EURUSD", "GBPUSD", "NZDUSD", "USDCAD", "USDCHF", "USDJPY", "USDNOK", "USDSEK")

calcRV = function(x){
  RV = rKernelCov(x, kernel.type = "Epanechnikov", kernel.param=50, align.period = 5, makeReturns = TRUE)
}
calcRVcrncy = function(crncy){
  filename_xtsFX = paste("/data/", crncy, "_ticks", ".RData", sep = "")
  load(filename_xtsFX)
  
  xtsFX_split = split.xts(xtsFX)
  Values = unlist(llply(crncy, calcRV, .parallel = TRUE))
  Dates = ldply(xtsFX_split, function(x) index(x[1]))[[1]]
  xtsRV = xts(Values, Dates)
  filename_xtsRV = paste("/data/", crncy, "_RV", ".RData", sep = "")
  save(xtsRV, filename_xtsRV)
}

