#########################################################################
##### This block of code contains thinning process of the black mats 
##### presence and absences coordinates 
##### thinning for presence and absences coordinates were done sperately

# read the classified data frame as csv file
blk.data.st<- read.csv("data_output/blk.data.st.csv")

# presence data frame to thin separately
blk.data.st.df_presence<-as.data.frame(blk.data.st)%>%
  filter(cat %in% c("Present"))%>%
  mutate(species="mat")

# absence data frame to thin separately
blk.data.st.df_absence<-as.data.frame(blk.data.st)%>%
  filter(cat %in% c("Absent"))%>%
  mutate(species="mat")%>%
  slice_sample(n=30000) # 30 thousands points to reduce calcualtion time

# setting path to save thinned data sets
thin_path<-("data_output")

# thinning for presece data frame with 20m distance
thin(blk.data.st.df_presence, lat.col="latitude", long.col="longitude", spec.col="species", thin.par=0.02, reps=1, out.dir=thin_path, out.base="presence_mat_new")

# thinning for absence data frame with 20m distance
thin(blk.data.st.df_absence, lat.col="lat_degrees", long.col="long_degrees", spec.col="species", thin.par=0.02, reps=1, out.dir=thin_path, out.base="absence_mat_new")

# Selected one thousands presence points for SDM analysis
presence.mat<-read.csv("../data/thinned_data/presence_mat_new_thin1.csv")%>%
  slice_sample(n=1000)%>%
  mutate(presence=1)

# Selected ten thousands absences points fpr SDM analysis
absence.mat<-read.csv("..data/thinned_data/absence_mat_mew_thin1.csv")%>%
  slice_sample(n=10000)%>%
  mutate(presence=0)

## Combine presence and absence points into a a singel dataframe for SDM analysis
mat_pre_abs_new <-rbind(presence.mat,absence.mat)

## saving presence/absence data frame for SDM analysis
write.csv(mat_pre_abs_new,
          "..data/thinned_data/mat_pre_abs_new.csv")