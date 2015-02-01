library(highfrequency)
library(xts)
library(doParallel)
library(plyr)
registerDoParallel(cores = 16)
crncy = list("AUDUSD", "EURUSD", "GBPUSD", "NZDUSD", "USDCAD", "USDCHF", "USDJPY", "USDNOK", "USDSEK")
# crncy = "GBPUSD"
toSeconds1 = function(x) {
  aggregatePrice(x, on = "seconds", k=1, marketopen = "00:00:01",
                 marketclose = "23:59:59")
}
calcRVcrncy = function(crncy){
  print(paste("Start processing", crncy))
  
  filename_xtsFX = paste("/data/", crncy, "_ticks", ".RData", sep = "")
  load(filename_xtsFX)
  
  xtsFX_split1 = split.xts(xtsFX, f = "days")
  rm(xtsFX); gc();
  
  xtsFX_split = llply(xtsFX_split1, 
                      toSeconds1,
                      .parallel = TRUE,
                      .paropts = list(".packages" = "highfrequency"))
  if (any(unlist(llply(xtsFX_split, is.null)))) stop(paste("Something went wrong when processing", crncy))
  
  rm(xtsFX_split1); gc();
  
  filename_xtsFX_split = paste("/data/", crncy, "_seconds_split", ".RData", sep = "")
  save(xtsFX_split, file = filename_xtsFX_split)
}

l_ply(crncy, calcRVcrncy)