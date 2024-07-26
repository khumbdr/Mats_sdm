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

## model tuning
myBiomodOptions_random <- BIOMOD_ModelingOptions(
  GAM = list( family = binomial(link='logit'),
              interaction.level = 0,
              method="REML"),
  GBM = list( distribution = 'bernoulli',
              n.trees = 1800,
              interaction.depth = 5,
              shrinkage = 0.01,
              bag.fraction = 0.5,
              train.fraction = 1,
              cv.folds = 5,
              keep.data = FALSE,
              verbose = FALSE,
              perf.method = 'cv'),
  RF = list( ntree = 1000,
             mtry = 5,
             nodesize = 1,
             maxnodes = NULL),
  MAXENT = list( path_to_maxent.jar = 'C:/Users/Khum/Downloads/maxent/maxent/maxent.jar', # this path specify the folder containing the maxent.jar file. 
                 memory_allocated = 512,
                 background_data_dir = 'default',
                 maximumbackground = 'default',
                 maximumiterations = 500,
                 visible = FALSE,
                 linear = TRUE,
                 quadratic = TRUE,
                 product = FALSE,
                 threshold = FALSE,
                 hinge = FALSE,
                 lq2lqptthreshold = 80,
                 l2lqthreshold = 10,
                 hingethreshold = 15,
                 beta_threshold = -1,
                 beta_categorical = -1,
                 beta_lqp = -1,
                 beta_hinge = -1,
                 betamultiplier = 0.5,
                 defaultprevalence = 0.5))


myBiomodOptions <- myBiomodOptions_random

myBiomodData <- BIOMOD_FormatingData(resp.var = myResp,
                                     expl.var = pre_env,
                                     resp.xy = myRespXY,
                                     resp.name = myRespName)
myBiomodData
#plot(myBiomodData)



# Model single models
myBiomodModelOut <- BIOMOD_Modeling(bm.format = myBiomodData,
                                    bm.options = myBiomodOptions,
                                    modeling.id = 'AllModels',
                                    models = c('GAM','GBM','RF','MAXENT'),
                                    CV.strategy = 'block',
                                    CV.perc = 80,
                                    # data.split.table = myBiomodCV,
                                    var.import = 3,
                                    metric.eval = c('TSS','ROC'),
                                    do.full.models = FALSE)


# Model ensemble models
myBiomodEM <- BIOMOD_EnsembleModeling(bm.mod = myBiomodModelOut,
                                      models.chosen = 'all',
                                      em.by = 'all',
                                      em.algo = c('EMmean'),
                                      metric.select = c('TSS'),
                                      metric.select.thresh = c(0.7),
                                      metric.eval = c('TSS', 'ROC'),
                                      var.import = 3,
                                      EMci.alpha = 0.05,
                                      EMwmean.decay = 'proportional')

# Project single models
myBiomodProj <- BIOMOD_Projection(bm.mod = myBiomodModelOut,
                                  proj.name = 'Current',
                                  new.env = pre_env,
                                  models.chosen = 'all',
                                  metric.binary = 'all',
                                  metric.filter = 'all',
                                  build.clamping.mask = TRUE,
                                  compress=FALSE)


# Project ensemble models (from single projections)
myBiomodEMProj <- BIOMOD_EnsembleForecasting(bm.em = myBiomodEM, 
                                             bm.proj = myBiomodProj,
                                             models.chosen = 'all',
                                             metric.binary = 'all',
                                             metric.filter = 'all')
