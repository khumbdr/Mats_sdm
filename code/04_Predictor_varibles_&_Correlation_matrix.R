##########################################################################
##### This block of code will work on the raster layers that will be
##### predictor variables of SDM analysis

# load soil moisture raster layer
moisture <- raster("../data/soil_moisture.tif")

# load snow raster layer
snow <- raster("../data/snow.tif")

# load elevation raster layer
elevation <-raster("../data/elevation.tif")

# load slope raster layer
slope <- raster("../data/slope.tif")

# load aspect raster layer
aspect <- raster("../data/aspect.tif")

# stack all the raster layer into one object

pre_env <- stack(moisture,snow,elevation,slope,aspect)

###########################################################################
###### This block of code will produce correlation matrix

## loading presence/absence data frame for SDM analysis
blk_mat_pre_abs<-read.csv("..data/thinned_data/mat_pre_abs_new.csv")

pre_env <- stack(moisture,snow,elevation,slope,aspect)

presvals_all <- raster::extract(pre_env, blk_mat_pre_abs[,c('long_degrees', 'lat_degrees')])
