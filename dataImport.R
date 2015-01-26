library(doParallel)
registerDoParallel(cores = 9)

crncy = c("AUDUSD", "EURUSD", "GBPUSD", "NZDUSD", "USDCAD", "USDCHF", "USDJPY", "USDNOK", "USDSEK")

processData = function(crncy){
  library(highfrequency)
  library(data.table)
  library(xts)
  library(rugarch)
  filename = paste("/data/", crncy, ".csv", sep = "")
  colClasses = c("character", "numeric", "numeric", "numeric", "numeric")
  dtRaw = fread(filename, sep = ",", header = FALSE, colClasses = colClasses)
  setnames(dtRaw, c("TimeChr", "BID", "OFR", "BIDSIZ", "OFRSIZ"))
  Time = as.POSIXct(strptime(dtRaw$TimeChr, format="%Y.%m.%d %H:%M:%OS"))
  Price = (dtRaw$BID + dtRaw$OFR) / 2
  dtRaw[, TimeChr := NULL]
  dtRaw[, Time := Time]
  filename_dtRaw = paste("/data/", crncy, "_raw", ".RData", sep = "")
  save(dtRaw, file=filename_dtRaw)
  rm(dtRaw)
  gc()
  
  xtsFX = xts(Price, Time)
  names(xtsFX) = crncy
  filename_xtsFX = paste("/data/", crncy, "_ticks", ".RData", sep = "")
  save(xtsFX, file=filename_xtsFX)
  rm(Price, Time)
#   gc()
#   print(crncy)
  
#   
#   xtsFXs = aggregatePrice(xtsFX, on = "seconds", k=1, marketopen = "00:00:01", marketclose = "23:59:59")
#   filename_xtsFXs = paste("/data/", crncy, "_seconds", ".RData", sep = "")
#   save(xtsFXs, file=filename_xtsFXs)
# #   rm(xtsFXs)
#   
#   xtsFXm = aggregatePrice(xtsFX, on = "minutes", k=1, marketopen = "00:00:01", marketclose = "23:59:59")
#   filename_xtsFXm = paste("/data/", crncy, "_minutes", ".RData", sep = "")
#   save(xtsFXm, file=filename_xtsFXm)
#   
#   xtsVolm = rKernelCov(xtsFX)
}
library(doParallel)
foreach(i=1:8) %dopar% processData(crncy[i])

# 
# for (i=1:9) {
#   crncy = crncy[i]
#   filename_xtsFXm = paste("/data/", crncy, "_minutes", ".RData", sep = "")
#   load(filename_xtsFXm)
#   xtsFX = xtsFXm
#   names(xtsFX) = "FX"
#   if (i == 1) {
#     xtsVol = xtsFX
#     names(xtsFX) = "FX"
#     xtsVol$Vol = xtsVol$FX * xtsVol$FX
#     xtsVol$N = as.integer(is.na(xtsVol$FX))
#     xtsVol$FX = NULL
#   } else {
#     xtsVol = merge(xtsVol, xtsFX_i, all = TRUE)
#     names(xtsVol) = c("Vol", "N", "FX")
#     xtsVol$Vol = xtsVol$FX + xtsVol$FX * xtsVol$FX
#     xtsVol$N = xtsVol$N + as.integer(is.na(xtsVol$FX))
#     xtsVol$FX = NULL
#   }
# }
# xtsVolm = xtsVolm / 9
# 
# 
# for (i=1:9) {
#   crncy = crncy[i]
#   filename_xtsFXm = paste("/data/", crncy, "_minutes", ".RData", sep = "")
#   xtsFXm_i = load(filename_xtsFXm)
#   xtsVolm = merge(xtsVolm, xtsFX_i)
# }
# xtsVolm = xtsVolm / 9
# 
# xtsCskww
