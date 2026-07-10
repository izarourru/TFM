library(optparse)
opt_list <- list(
  make_option("--what",   default = "FWI"),
  make_option("--wind",   default = "ERA5Land")
)
opt <- parse_args(OptionParser(option_list = opt_list))

what <- opt$what
wind <- opt$wind

cat("Calculating ", what, " using ", wind, " wind data\n", sep = "")

if (opt$wind == "ERA5Land") {
  ws.dir <- "/lustre/gmeteo/WORK/ARTICULOS/2024_Mirones_FWI_Emulator/data/ncml/sfcwind_ERA5Land.ncml"
  wind_var <- "sfcwind"
  n.chunks <- 17
} else if (opt$wind == "CIDE") {
  ws.dir <- "/lustre/gmeteo/WORK/urrutxuai/data/ncml/CIDE_sfcWind_1961_2021_0.1grid.ncml"
  wind_var <- "sfcWind"
  n.chunks <- 34
} else if (opt$wind == "HARMONIE") {
  ws.dir <- "/lustre/gmeteo/WORK/urrutxuai/data/ncml/HARMONIE_sfcWind_0.1grid.ncml"
  wind_var <- "sfcWind"
  n.chunks <- 34
} else {
  stop("Invalid wind option")
}

options(java.parameters = "-Xmx64g")

library(loadeR)
library(transformeR)
library(loadeR.2nc)
library(fireDanger)
library(convertR)
library(magrittr)
source("/lustre/gmeteo/WORK/urrutxuai/R/climate4R.chunk.R")

# output.dir <- file.path("/lustre/gmeteo/WORK/urrutxuai/data/data_derived/fwi")
output.dir <- file.path("/lustre/gmeteo/WORK/urrutxuai/final/data_derived/fwi")
# input.dir <-  file.path("/lustre/gmeteo/WORK/urrutxuai/data/ncml")

dir.create(output.dir, recursive = TRUE, showWarnings = F)


fwi.fun <- function(hr, pr, tas, ws){
  cat("Calculating FWI...\n")
  hr <- udConvertGrid(hr, new.units = "%")
  cat("hr converted\n")
  # pr <- udConvertGrid(pr, new.units = "mm day-1")
  # cat("pr converted\n")
  tas <- udConvertGrid(tas, new.units = "degC")
  cat("tas converted\n")
  ws <- udConvertGrid(ws, new.units = "km.h-1")
  cat("ws converted\n")
  
  # find the overlapping extent across all four grids
  lon_lim <- c(
    max(range(ws$xyCoords$x)[1], range(tas$xyCoords$x)[1], range(hr$xyCoords$x)[1], range(pr$xyCoords$x)[1]),
    min(range(ws$xyCoords$x)[2], range(tas$xyCoords$x)[2], range(hr$xyCoords$x)[2], range(pr$xyCoords$x)[2])
  )
  lat_lim <- c(
    max(range(ws$xyCoords$y)[1], range(tas$xyCoords$y)[1], range(hr$xyCoords$y)[1], range(pr$xyCoords$y)[1]),
    min(range(ws$xyCoords$y)[2], range(tas$xyCoords$y)[2], range(hr$xyCoords$y)[2], range(pr$xyCoords$y)[2])
  )
  
  # check there is actually an overlap
  if (lon_lim[1] > lon_lim[2] || lat_lim[1] > lat_lim[2]) {
    message("No spatial overlap in this chunk, skipping.")
    return(NULL)
  }
  
  tas <- subsetGrid(tas, lonLim = lon_lim, latLim = lat_lim)
  hr  <- subsetGrid(hr,  lonLim = lon_lim, latLim = lat_lim)
  pr  <- subsetGrid(pr,  lonLim = lon_lim, latLim = lat_lim)
  ws  <- subsetGrid(ws,  lonLim = lon_lim, latLim = lat_lim)
  
  gl <- intersectGrid(hr, pr, tas, ws, type = "temporal", which.return = 1:4)
  names(gl) <- c("hr", "pr", "tas", "ws")
  gl[["hr"]]$Variable$varName <- "hurs"
  gl[["pr"]]$Variable$varName <- "tp"
  gl[["tas"]]$Variable$varName <- "tas"
  gl[["ws"]]$Variable$varName <- "wss"
  mg <- do.call("makeMultiGrid", gl)
  tas <- tmin <- tmax <- hurs <- pr <- ws <- NULL
  fwi <- fwiGrid(mg, what = what, restart.annual = FALSE)
  mg <- NULL
  redim(fwi, drop = TRUE)
}

hr.dir <- "/lustre/gmeteo/WORK/ARTICULOS/2024_Mirones_FWI_Emulator/data/ncml/hurs_ERA5Land.ncml"
pr.dir <- "/lustre/gmeteo/WORK/ARTICULOS/2024_Mirones_FWI_Emulator/data/ncml/tp12_ERA5Land.ncml"
# tas.dir <- "/lustre/gmeteo/WORK/ARTICULOS/2024_Mirones_FWI_Emulator/data/ncml/t2m_ERA5Land.ncml"
tas.dir <- "/lustre/gmeteo/WORK/urrutxuai/final/ncml/ERA5-Land_tasmax.ncml"
# ws.dir <- "/lustre/gmeteo/WORK/ARTICULOS/2024_Mirones_FWI_Emulator/data/ncml/sfcwind_ERA5Land.ncml"

outfilename <- file.path(output.dir, paste0(what, "_", wind,".nc"))

if(!file.exists(outfilename)) {
  fwi.grid <- climate4R.chunk(n.chunks = n.chunks,
                              C4R.FUN.args = list(FUN = "fwi.fun",
                                                  ws = list(dataset = ws.dir, var = wind_var),
                                                  hr = list(dataset = hr.dir, var = "hurs"),
                                                  pr = list(dataset = pr.dir, var = "tp12"),
                                                  tas = list(dataset = tas.dir, var = "t2mx") #"t2m")
                              ))
  
  #guardar el fichero
  grid2nc(data = redim(fwi.grid, drop = TRUE), NetCDFOutFile = outfilename)
}
