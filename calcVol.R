library(highfrequency)
library(xts)
library(doParallel)
library(plyr)
registerDoParallel(cores = 16)
crncy = list("AUDUSD", "EURUSD", "GBPUSD", "NZDUSD", "USDCAD", "USDCHF", "USDJPY", "USDNOK", "USDSEK")
# crncy = "AUDUSD"
calcRV = function(x){
#   ewe
  1
}
calcRVcrncy = function(crncy){
  print(paste("Start processing", crncy))
  
  filename_xtsFX_split = paste("/data/", crncy, "_seconds_split", ".RData", sep = "")
  load(filename_xtsFX_split)
  gc()
  
  
  
#   ls_values = {foreach(i = 1:length(xtsFX_split)) %dopar% calcRV(xtsFX_split[[i]])}
  ls_values = llply(xtsFX_split[1:10], calcRV, .parallel = TRUE, .inform = TRUE)
  3460
  
  
  
  calcRV(xtsFX_split[3460])
  
  i = 3168

  

  Values = unlist(ls_values)
  rm(ls_values); gc()
#   Values = unlist(llply(xtsFX_split, calcRV, .parallel = TRUE))
  Dates = ldply(xtsFX_split, function(x) index(x[1]))[[1]]
  rm(xtsFX_split);gc()
  xtsRV = xts(Values, Dates)
  filename_xtsRV = paste("/data/", crncy, "_RV", ".RData", sep = "")
  save(xtsRV, file = filename_xtsRV)
  
  print(paste("Finished processing", crncy))
  gc()
}

l_ply(crncy, calcRVcrncy)