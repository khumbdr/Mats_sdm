################################################################

##### masking of black mats abundance raster into AOI

# loading Area of Interest (AOI) polygon
fryxell_aoi <- read_sf("data/fryxell_basin_AOI_newupdated.shp")

# loading polygon of lake Fryxell & glaciers
# and projected to AOI
lake_outline <- read_sf("data/lake_fryxell_outline.shp")%>%
  st_transform(crs(fryxell_aoi))

# erase polygon i.e. polygon of AOI without lake Fryxell & glacier
fryxell_diff <-st_difference(fryxell_aoi,lake_outline)

# load blackmat raster layer that is bigger than AOI
# blk_mat <- raster("data/PERCENTAGE_black-mat.tif")
blk_mat <- raster("C:/Users/Khum/Documents/mbm_updated_data/response/PERCENTAGE_black-mat.tif")

# projecting erase polygon into blackmat raster layer
fryxell_diff_msk<-fryxell_diff%>%
  st_transform(crs(blk_mat))

# masking blackmat raster layer into AOI
blk_mat_msk<-mask(blk_mat,fryxell_diff_msk)

#####################################################################

######################################################################
##### converting black mats abundance raster layer into data frame
##### with black mats occurrence records

# converting masked raster into data frame with coordinates and pixel values
blk.data.st<-as.data.frame(blk_mat_msk,xy=TRUE)%>%
  rename(longitude="x",
         latitude="y")%>%
  rename(layer="PERCENTAGE_black.mat")

# classification of pixel into presence and absence coordinates
# for detail about the classification reasons and process see
# main manuscript
blk.data.st$cat <-
  cut(blk.data$layer,
      breaks=c(0,0.001,0.05,1),
      labels=c("Absent","NA","Present"))

# save the classified data frame as csv file
write.csv(blk.data.st,"data_output/blk.data.st.csv") # did not save into github due to its large size.

