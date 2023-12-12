

# Creating folders and sub-folder to store data, code, and figures

dir.create("code")
dir.create("data")
dir.create("data_output")
dir.create("figure_output")


# Loading required libraries needed for raster calculation, species distribution modeling
library(raster)
library(dplyr)# for data management
library(rgdal)
library(sf) # spatial data reading and management
library(ggplot2) # for making plots
library(readxl)
library(spThin) # for thinning species occurrence record
library(biomod2) # for SDM modeling
library(tidyr)
library(ggspatial)
library(mapmisc)
library(ggsn)





