##########################################################################
##### predictor variables used in predicting
##### distribution of black mats

# load soil moisture raster layer
moisture <- raster("data/soil_moisture.tif")

# load snow raster layer
snow <- raster("ata/snow.tif")

# load elevation raster layer
elevation <-raster("data/elevation.tif")

# load slope raster layer
slope <- raster("data/slope.tif")

# load aspect raster layer
aspect <- raster("data/aspect.tif")

# stack all the raster layer into one object

pre_env <- stack(moisture,snow,elevation,slope,aspect)

###########################################################################
###### produce correlation matrix among predictor varibles

## loading presence/absence data frame for SDM analysis
blk_mat_pre_abs<-read.csv("data_output/mat_pre_abs_new.csv")

pre_env <- stack(moisture,snow,elevation,slope,aspect)

# extracting the environmental varible according to occurrence record
presvals_all <- raster::extract(pre_env, blk_mat_pre_abs[,c('longitude', 'lattitude')])

# running correlation among the predictor varibles
cor_mats<- presvals_all %>%
  na.omit()%>%
  cor()

# saving correlation matrix in the data_output subfolder
write.csv(cor_mats, "data_output/cor_mats.csv")