#########################################################################
#### producing figures used in manuscript

# ensemble suitable maps for black mats
# this is mapped average over four separate maps from four algorithms
en.map<-raster("data/ensemble_map.tif")
fryxell_aoi <- read_sf("data/fryxell_basin_AOI_newupdated.shp")

# converting into data frame
mats_prob<-as.data.frame(en.map, xy=TRUE)

# making a plot
Figure1E<-mats_prob%>%
  na.omit()%>%
  ggplot()+
  geom_sf(data=fryxell_aoi$geometry, fill=NA)+
  geom_raster(mapping=aes(x=x,y=y,fill=layer/1000))+
  scale_fill_gradientn(colours=c("darkgreen","yellow","red"))+
  theme(panel.background=element_rect(color="black",fill=NA),
        legend.title=element_blank())+
  labs(x="longitude", y="lattitude")+
  scalebar(x.min = 163.30, x.max = 163.36,
           y.min = -77.64, y.max = -77.65,
           dist = 1, dist_unit = "km", st.color = "black",
           transform = TRUE, model = "WGS84", st.size=2, height=0.05, st.dist=0.1, border.size=0.2)+
  annotation_north_arrow(location = "tl", which_north = "true", 
                         pad_x = unit(0.02, "in"), pad_y = unit(0.1, "in"),
                         height=unit(0.8, "cm"),
                         style = north_arrow_fancy_orienteering)

Figure1E


ggsave("figure_output/Figure1E.jpeg",
       width=6,height=5, units="in", dpi=500)


#############################################################
# figure for predictor varibles

# reading the predictor variables as stacked raster layer
moisture <- raster("data/soil_moisture.tif")
snow <- raster("ata/snow.tif")
elevation <-raster("data/elevation.tif")
slope <- raster("data/slope.tif")
aspect <- raster("data/aspect.tif")
pre_env <- stack(moisture,snow,elevation,slope,aspect)

png("figure_output/FigureS1.png",
    width=6,height=4,units="in",res=500)
plot(pre_env)

dev.off()

#############################################

#### getting model values of SDM modeling

mod_eva<-bm_PlotEvalMean(bm.out=myBiomodModelOut)[1]
# OR
mod_eva <-read.csv("../Mats_sdm/data_output/mod_AUC&TSS.csv")


FigureS2<- mod_eva%>%
  mutate(tab.name=factor(tab.name,levels=c("RF","GBM","GAM")))%>%
  ggplot(aes(x=tab.mean1,y=tab.mean2,color=tab.name))+
  geom_point()+
  geom_errorbar(aes(ymin=tab.mean2-tab.sd2,
                    ymax=tab.mean2+tab.sd2))+
  geom_errorbar(aes(xmin=tab.mean1-tab.sd1,
                    xmax=tab.mean1+tab.sd1))+
  geom_hline(yintercept=0.70, linetype="dotted")+
  scale_color_manual(values=c("red","green","black"))+
  theme(panel.background=element_rect(color="black",fill=NA),
        legend.key=element_blank(),
        legend.title=element_blank())+
  labs(x="ROC",y="TSS")

FigureS2

ggsave("figure_output/FigureS2.jpeg",
       width=4.5,height=3.5, units="in", dpi=500)


##############################################
##### getting importance of variables 
get_value<-get_variables_importance(myBiomodModelOut, as.data.frame = TRUE)

FigureS3<-var_imp%>%
  group_by(Expl.var)%>%
  summarise(av=mean(Var.imp))%>%
  ggplot()+
  geom_bar(aes(x=reorder(Expl.var,-av),y=av*100), stat="identity", width=0.6)+
  labs(x="Predictor variables",y="% contribution")+
  theme(panel.background=element_rect(color="black",fill=NA),
        axis.text.x=element_text(angle=90))

FigureS3
ggsave("figure_outputt/FigureS3.png",
       width=3.5,height=3.5,dpi=500,units="in")

########################################
# Response curve figure
rescur<-bm_PlotResponseCurves(bm.out = myBiomodModelOut,
                              fixed.var = 'mean',
                              colors=NA)

# restoring data of response curve
rescur_l<-rescur[[1]]

#restoring data into data.frame
rescur_df<-as.data.frame(rescur_l)

FigureS4<-rescur_df%>%
  mutate(expl.name=factor(expl.name,levels=c("Soil moisture","Snow cover","Elevation","Slope","Aspect")))%>%
  ggplot()+
  geom_line(aes(x=expl.val,y=pred.val, color=pred.name))+
  facet_wrap(~expl.name,scales = "free")+
  theme(panel.background=element_rect(color="black",fill=NA),
        legend.title=element_blank(),
        legend.key=element_blank())+
  scale_color_manual(labels=c("RF","GBM","GAM"),
                     values=c("red","green","black"))+
  labs(x="",y="")

FigureS4
ggsave("figure_output/FigureS4.jpg", width=8, height=5, dpi=500)


## habitat suitability maps for all the models used in SDM analysis

# stack all the models output raster
gam.map<-"data/gam.map.tif"
gbm.map<-"data/gbm.map.tif"
rf.map<-"data/rf.map.tif"

# stacj all models maps
mod_all<-stack(gam.map,bgm.map,rf.map)
mod_names<-c("GAM","GBM","RF")
names(mod_all)<-mod_names

# creating the dataframe
all_mod_df1<-as.data.frame(mod_all, xy=TRUE)

# managing the data in the form of tidy data forom
all_mod_plong1<-all_mod_df1%>%
  tidyr::pivot_longer(col=c("GAM","GBM","RF"), names_to="layer")%>%
  mutate(value=value/1000)

FigureS5<-all_mod_plong1%>%
  na.omit()%>%
  ggplot()+
  geom_sf(data=ty$geometry, fill=NA)+
  geom_raster(mapping=aes(x=x,y=y,fill=value))+
  scale_fill_gradientn(colours=c("darkgreen","yellow","red"))+
  facet_wrap(~layer, ncol=3)+
  theme(panel.background=element_rect(color="black",fill=NA),
        axis.text.x = element_text(angle=92, vjust=1),
        legend.title=element_blank())+
  labs(x="longitude", y="lattitude")+
  scale_x_continuous(breaks=c(163.00,163.10,163.20,163.30))+
  scale_y_continuous(breaks=c(-77.58,-77.62,-77.64,-77.66))

FigureS5

ggsave("figure_output/FigureS5.jpeg",
       width=9,height=9, units="in", dpi=500)
