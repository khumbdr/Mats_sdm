#############################################################################################
##### This block of code will set up to run SDM in BIOMOD2 in R software

# reading presence/absence data
blk_mat_pre_abs<-read.csv("data_output/mat_pre_abs_new.csv")

# reading the predictor variables as stacked raster layer
moisture <- raster("data/soil_moisture.tif")
snow <- raster("ata/snow.tif")
elevation <-raster("data/elevation.tif")
slope <- raster("data/slope.tif")
aspect <- raster("data/aspect.tif")
pre_env <- stack(moisture,snow,elevation,slope,aspect)

# Select the name of the studied species
myRespName <- 'blackmat'

# Get corresponding presence/absence data
myResp <- as.numeric(blk_mat_pre_abs[, 'presence'])

# Get corresponding XY coordinates
myRespXY <- blk_mat_pre_abs[, c('longitude', 'lattitude')]



myBiomodData <- BIOMOD_FormatingData(resp.var = myResp,
                                     expl.var = pre_env,
                                     resp.xy = myRespXY,
                                     resp.name = myRespName)
myBiomodData
#plot(myBiomodData)

# Create default modeling options
myBiomodOptions <- BIOMOD_ModelingOptions()
myBiomodOptions


# Model single models
myBiomodModelOut <- BIOMOD_Modeling(bm.format = myBiomodData,
                                    bm.options = myBiomodOptions,
                                    modeling.id = 'AllModels',
                                    nb.rep = 5,
                                    data.split.perc = 80,
                                    # data.split.table = myBiomodCV,
                                    var.import = 3,
                                    metric.eval = c('TSS','ROC'),
                                    do.full.models = FALSE)



myBiomodEM <- BIOMOD_EnsembleModeling(bm.mod = myBiomodModelOut,
                                      models.chosen = 'all',
                                      em.by = 'all',
                                      metric.select = c('TSS'),
                                      metric.select.thresh = c(0.7),
                                      metric.eval = c('TSS', 'ROC'),
                                      var.import = 1,
                                      prob.mean = TRUE,
                                      prob.median = FALSE,
                                      prob.cv = FALSE,
                                      prob.ci = FALSE,
                                      prob.ci.alpha = 0.05,
                                      committee.averaging = TRUE,
                                      prob.mean.weight = FALSE,
                                      prob.mean.weight.decay = 'proportional',
                                      seed.val = 42)


# Project single models
myBiomodProj <- BIOMOD_Projection(bm.mod = myBiomodModelOut,
                                  proj.name = 'Current',
                                  new.env = pre_env,
                                  models.chosen = 'all',
                                  metric.binary = 'all',
                                  metric.filter = 'all',
                                  build.clamping.mask = TRUE)


# Project ensemble models (from single projections)
myBiomodEMProj <- BIOMOD_EnsembleForecasting(bm.em = myBiomodEM, 
                                             bm.proj = myBiomodProj,
                                             models.chosen = 'all',
                                             metric.binary = 'all',
                                             metric.filter = 'all')
