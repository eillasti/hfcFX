library(highfrequency)
library(xts)
library(doParallel)
library(plyr)
registerDoParallel(cores = 16)
crncy = list("AUDUSD", "EURUSD", "GBPUSD", "NZDUSD", "USDCAD", "USDCHF", "USDJPY", "USDNOK", "USDSEK")
# crncy = "AUDUSD"
calcRV = function(x){
  RV = rKernelCov(x, kernel.type = "Epanechnikov", kernel.param=50, align.period = 5, makeReturns = TRUE)
}
calcRVcrncy = function(crncy){
  print(paste("Start processing", crncy))
  
  filename_xtsFX = paste("/data/", crncy, "_ticks", ".RData", sep = "")
  load(filename_xtsFX)
  
  xtsFX_split1 = split.xts(xtsFX, f = "days")
  rm(xtsFX); gc();
  
  xtsFX_split = llply(xtsFX_split1, 
                      function(x) aggregatePrice(x, on = "seconds", k=1, 
                                                 marketopen = "00:00:01", 
                                                 marketclose = "23:59:59"),
                      .parallel = TRUE)
  rm(xtsFX_split1); gc();
  
  filename_xtsFX_split = paste("/data/", crncy, "_seconds_split", ".RData", sep = "")
  save(xtsFX_split, file = filename_xtsFX_split)
}

l_ply(crncy, calcRVcrncy)