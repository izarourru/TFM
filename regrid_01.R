library(loadeR)
library(transformeR)
library(loadeR.2nc)
library(convertR)


# regrid harmonie to era5-land grid
var_name <- "sfcWind"

# folder to regrid
folder <- "/lustre/gmeteo/WORK/urrutxuai/data/HARMONIE-AROME/data/wss"

output_folder <- "/lustre/gmeteo/WORK/urrutxuai/data/HARMONIE_0.1grid"
dir.create(output_folder, showWarnings = FALSE)

# example grid
f_era5 <- "/lustre/gmeteo/WORK/ARTICULOS/2024_Mirones_FWI_Emulator/data/ncml/sfcwind_ERA5Land.ncml"
wss <- loadGridData(f_era5,
                    var = "sfcwind",
                    year = 2000,
                    season = 1)

# list of files to regrid
files <- list.files(folder, full.names = TRUE, pattern = ".nc")


new_grid <- getGrid(wss)
old_grid <- getGrid(loadGridData(files[1], var = var_name, season = 1))

new_grid$x <- round(old_grid$x, 1)
new_grid$y <- round(old_grid$y, 1)

wss <- NULL


for (f in files) {
  
  # load data
  dat <- loadGridData(f, var = var_name)
  
  # regrid
  dat_regridded <- interpGrid(dat, new.coordinates = new_grid, method = "nearest")
  
  # save regridded data
  output_file <- file.path(output_folder, sub("\\.nc$", "_0.1grid.nc", basename(f)))
  grid2nc(dat_regridded, NetCDFOutFile = output_file)
}
