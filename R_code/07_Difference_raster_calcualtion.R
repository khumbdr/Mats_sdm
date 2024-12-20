## comparing the distributions of black mats between SDM result and unmixing raster

## black mats raster
unmix<-raster("data//PERCENTAGE_black-mat.tif")
unmix<-unmix>=0.05

## sdm produced ensemble raster
sdm<-raster("data/sdm.tif")
sdm<-sdm>=460
sdm[sdm==1]<-2

# difference between two raster layers
diff<-sdm-unmix

# converting into data frame
diff.df<-as.data.frame(diff,xy=TRUE)

# callating number of pixel in each classification
table(diff.df$layer)
# where,
# 2-1=1,presence of black mats in both sdm and unmix raster
# 2-0=2, presence of black mats only in sdm raster
# 0-1=-1, absence of black mats in sdm but presence in unmix raster
# 0-0=0, absence of black mats in sdm and also absence in unmix raster

