# predictor variables

# predictor variables
pre_env<-stack("../data/predictors_variable/mat_env_05g_s0_eco.grd")

# names_pre<-c("Soil moisture", "Snow cover","Elevation","Slope","Aspect")
# names(pre_env)<-names_pre

names_pre<-c("Average_GCW", "Average_snow","Elevation","Slope","Aspect")
names(pre_env)<-names_pre
##########################


## running random forest SDMs
# reading the thinned presence records
blk_pre <-read.csv("../data/presence.csv")%>%
  mutate(presence=1)

# extracting predictor variables information for presence data
pre_extract <- cbind(raster::extract(pre_env, blk_pre[,c('long_degrees', 'lat_degrees')]),presence=blk_pre$presence,longitude=blk_pre$long_degrees,
                     latitude=blk_pre$lat_degrees)%>%
  na.omit()%>%
  as.data.frame()

# reading the absence points
# selecting equal sample size to presence data
blk_abs <- read.csv("../data/absence.csv")%>%
  mutate(presence=0)%>%
  slice_sample(n=length(pre_extract$presence)) # selecting equal number

# extracting predictor variables information for absence data
abs_extract <- cbind(raster::extract(pre_env, blk_abs[,c('long_degrees', 'lat_degrees')]),presence=blk_abs$presence, longitude=blk_abs$long_degrees,
                     latitude=blk_abs$lat_degrees)%>%
  na.omit()%>%
  as.data.frame()


# loading library if not loaded earlier
library(ENMeval)

# running get.block function available to library ENMeval

blk.latLon<-get.block(pre_extract,abs_extract)

# adding block variable with block value
pre_extract$block<-blk.latLon$occs.grp
abs_extract$block<-blk.latLon$bg.grp

# combining presence and absence data information
pre_abs <- rbind(pre_extract,abs_extract)%>%
  as.data.frame()

# adding id variables to have serial number
pre_abs$id<-1:nrow(pre_abs)

library(dplyr)

# getting training data of 80%
rf_training<-both%>%
  group_by(block,presence)%>%
  dplyr::sample_frac(size=0.8)

# getting testing data of 20%
rf_testing<-dplyr::anti_join(both,train, by='id')


## setting for weighting the presence and absence data
prNum <- as.numeric(table(pre_abs$presence)["1"]) # number of presences
# the sample size in each class; the same as presence number
smpsize <- c("0" = prNum, "1" = prNum)

library(randomForest)
# running the models
blk_rf <- randomForest(rf_training[,1:5], 
                       rf_training[,6],
                       ntree=1000,
                       samsize=samsize,
                       replace=TRUE)

# getting probability values on area of interest
blk_rf_predict <- predict(pre_env, blk_rf)


# getting variable importance

var_imp<-varImpPlot(blk_rf)


# Use testing data for model evaluation
library(dismo)
rf_eva <- dismo::evaluate(rf_testing[rf_testing$presence==1, ], rf_testing[rf_testing$presence==0, ], blk_rf)
rf_eva
# getting threshold value
dismo::threshold(rf_eva)

# writeRaster(blk_rf_predict, "../data_output/four_mod_tiff/rf_predict_training.grd",format = "raster", overwrite=TRUE)


##################
###############

## running models using GBM



# Here, we used above crated training and testing data frame for GBM analysis

library(dismo)
prNum <- as.numeric(table(rf_training$presence)["1"]) # number of presences
bgNum <- as.numeric(table(rf_training$presence)["0"]) # number of backgrounds
wt <- ifelse(rf_training$presence == 1, 1, prNum / bgNum)

blk_gbm <- gbm.step(data=rf_training, 
                    gbm.x = 1:5, 
                    gbm.y = 6,
                    family = "bernoulli",
                    tree.complexity = 5,
                    learning.rate = 0.01,
                    bag.fraction = 0.5,
                    max.trees = 10000,
                    n.trees = 50, 
                    n.folds = 5, # 5-fold cross-validation
                    site.weights = wt,
                    silent = TRUE)



# getting probability values on area of interest
blk_gbm_predict <- predict(blk_gbm, newdata=pre_env, type="response")

# Use testing data for model evaluation
gbm_eva <- dismo::evaluate(rf_testing[rf_testing$presence==1, ], gbm_testing[rf_testing$presence==0, ], blk_rf)

gbm_eva

# getting threshold value
dismo::threshold(gbm_eva)


# writeRaster(blk_gbm_predict, "../data_output/four_mod_tiff/gbm_predict_training.grd",format = "raster", overwrite = TRUE)


#########################################
#### Running models using GAM

library(mgcv)
prNum <- as.numeric(table(rf_training$presence)["1"]) # number of presences
bgNum <- as.numeric(table(rf_training$presence)["0"]) # number of backgrounds
wt <- ifelse(rf_training$presence == 1, 1, prNum / bgNum)

# creating formula
form <-presence~s(Average_GCW)+s(Average_snow)+s(Elevation)+s(Slope)+s(Aspect)

blk_gam <- mgcv::gam(formula=as.formula(form),
                     data=rf_training,
                     family=binomial(link="logit"),
                     method="REML",
                     weights = wt)
# getting probability values on area of interest

blk_gam_predict <- predict(pre_env,blk_gam, type="response")

# Use testing data for model evaluation
gam_eva <- dismo::evaluate(rf_testing_t[rf_testing$presence==1, ], rf_testing_t[rf_testing$presence==0, ], blk_gam)
gam_eva

# getting threshold value
dismo::threshold(gam_eva)

writeRaster(blk_gam_predict, "../data_output/four_mod_tiff/gam_predict_training.grd",format = "raster", overwrite=TRUE)
