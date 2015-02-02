library(highfrequency)
library(xts)
library(doParallel)
library(plyr)
registerDoParallel(cores = 16)
crncy = list("AUDUSD", "EURUSD", "GBPUSD", "NZDUSD", "USDCAD", "USDCHF", "USDJPY", "USDNOK", "USDSEK")
# crncy = "GBPUSD"
calcRV = function(x){
  rKernelCov(x, kernel.type = "Epanechnikov", kernel.param=50, align.period = 5, makeReturns = TRUE)
}
calcRVcrncy = function(crncy){
  print(paste("Start processing", crncy))
  
  filename_xtsFX_split = paste("/data/", crncy, "_seconds_split", ".RData", sep = "")
  load(filename_xtsFX_split)
  
  ls_values = llply(xtsFX_split, calcRV, .parallel = TRUE, .inform = TRUE, 
                    .paropts = list(".packages" = "highfrequency")) #3460
  
  if (length(ls_values) != length(xtsFX_split)) stop(paste("Lengths differ when processing", crncy))
  
  Values = unlist(ls_values)
#   rm(ls_values); gc()
  Dates = llply(xtsFX_split, function(x) index(x[1]))

  rm(xtsFX_split);gc()
  xtsRV = xts(Values, Dates)
 
  filename_xtsRV = paste("/data/", crncy, "_RV", ".RData", sep = "")
  save(xtsRV, file = filename_xtsRV)
  
  print(paste("Finished processing", crncy))
}

l_ply(crncy, calcRVcrncy)