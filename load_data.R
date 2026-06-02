library(loadeR)

load_data <- function(year, lonLim, latLim, what, dataset, mask = TRUE) {
  if (dataset == "ERA5") {
    if (what == "Wind") {
      var <- "sfcwind"
      f <- "/lustre/gmeteo/WORK/ARTICULOS/2024_Mirones_FWI_Emulator/data/ncml/sfcwind_ERA5Land.ncml"
    } else {
      var <- what
      f <- paste0("/lustre/gmeteo/WORK/urrutxuai/data/data_derived/fwi/", what, "_ERA5Land.nc")
    }
  } else if (dataset == "CIDE") {
    if (what == "Wind") {
      var <- "sfcWind"
      f <- "/lustre/gmeteo/WORK/urrutxuai/data/ncml/CIDE_sfcWind_1961_2021_0.1grid.ncml"  
    } else {
      var <- what
      f <- paste0("/lustre/gmeteo/WORK/urrutxuai/data/data_derived/fwi/", what, "_CIDE.nc")
    }
  } else if (dataset == "HARMONIE") {
    if (what == "Wind") {
      var <- "sfcWind"
      f <- "/lustre/gmeteo/WORK/urrutxuai/data/ncml/HARMONIE_sfcWind_0.1grid.ncml"
    } else {
      var <- what
      f <- paste0("/lustre/gmeteo/WORK/urrutxuai/data/data_derived/fwi/", what, "_HARMONIE.nc")
    }
  }
  
  dat <- loadGridData(f, var = var, latLim = latLim, lonLim = lonLim, years = year)
  
  if (mask == TRUE && dataset == "ERA5" && identical(latLim, c(36, 44)) && identical(lonLim, c(-9.5, 4.3))) {
    load("/lustre/gmeteo/WORK/urrutxuai/R/mask_2d.RData")
    dat$Data <- sweep(dat$Data, c(2, 3), mask_2d, FUN = "*")
  }
  
  return(dat)
}