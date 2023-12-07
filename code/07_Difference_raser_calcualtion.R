## Calculation of difference between SDM result and unmixing raster

## black mats raster
unmix<-raster("../data//PERCENTAGE_black-mat.tif")
unmix<-unmix>=0.05

## sdm produced ensemble raster
sdm<-raster("..data/sdm.tif")
sdm<-sdm>=500
sdm[sdm==1]<-2

diff<-sdm-unmix

diff.df<-as.data.frame(diff,xy=TRUE)

table(diff.df$layer)
# where,
# 2-1=1,presence of blackmats in both sdm and unmix raster
# 2-0=2, presence of blackmats only in sdm raster
# 0-1=-1, absence of blackmats in sdm but presence in unmix raster
# 0-0=0, absence of blackmats in sdm and also absence in unmix raster

