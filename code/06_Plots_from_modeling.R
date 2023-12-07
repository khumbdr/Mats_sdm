#########################################################################
#### This group of code will get the figures related to SDM outputs



# Response curve figure

rescur<-bm_PlotResponseCurves(bm.out = myBiomodModelOut,
                              models.chosen = get_built_models(myBiomodModelOut)[c(2,10,8,1,5)],
                              fixed.var = 'mean',
                              colors=NA)

# restoring data of response curve
rescur_l<-rescur[[1]]

#restoring data into data.frame
rescur_df<-as.data.frame(rescur_l)

recurve_fig<-rescur_df%>%
  mutate(expl.name=factor(expl.name,levels=c("Soil moisture","Snow cover","Elevation","Slope","Aspect")))%>%
  ggplot()+
  geom_line(aes(x=expl.val,y=pred.val, color=pred.name))+
  facet_wrap(~expl.name,scales = "free")+
  theme(panel.background=element_rect(color="black",fill=NA),
        legend.title=element_blank(),
        legend.key=element_blank())+
  scale_color_manual(labels=c("GBM","MAXENT","MARS","BLM","ANN"),
                     values=c("red","green","black","purple","blue"))+
  labs(x="",y="")

recurve_fig
ggsave("../figure/response_curve.jpg", width=8, height=5, dpi=500)

##### getting importance of variables 
get_value<-get_variables_importance(myBiomodModelOut, as.data.frame = TRUE)

var_imp_fig<-var_imp%>%
  group_by(Expl.var)%>%
  summarise(av=mean(Var.imp))%>%
  ggplot()+
  geom_bar(aes(x=reorder(Expl.var,-av),y=av*100), stat="identity", width=0.6)+
  labs(x="Predictor variables",y="% contribution")+
  theme(panel.background=element_rect(color="black",fill=NA),
        axis.text.x=element_text(angle=90))

var_imp_fig
ggsave("../figure_output/models_value.png",
       width=3.5,height=3.5,dpi=500,units="in")


#### getting model values of SDM modeling

mod_eva<-bm_PlotEvalMean(bm.out=myBiomodModelOut)[1]

model_fig<- mod_eva%>%
  mutate(tab.name=factor(tab.name,levels=c("GBM","MAXENT","MARS","GLM","ANN","FDA","GAM","CTA","RF","SRE")))%>%
  ggplot(aes(x=tab.mean1,y=tab.mean2,color=tab.name))+
  geom_point()+
  geom_errorbar(aes(ymin=tab.mean2-tab.sd2,
                    ymax=tab.mean2+tab.sd2))+
  geom_errorbar(aes(xmin=tab.mean1-tab.sd1,
                    xmax=tab.mean1+tab.sd1))+
  geom_hline(yintercept=0.70, linetype="dotted")+
  scale_color_manual(values=c("red","green","black","purple","blue","grey","orange","pink","violet", "yellow"))+
  theme(panel.background=element_rect(color="black",fill=NA),
        legend.key=element_blank(),
        legend.title=element_blank())+
  labs(x="ROC",y="TSS")

model_fig

ggsave("../figure_output/Evaluation_plot.jpeg",
       width=4.5,height=3.5, units="in", dpi=500)
