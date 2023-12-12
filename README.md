# Mats_sdm folder contains following sub-folders and files
Subfolders:
  code: This sub-folder includes scripts that are used in the data managment and SDM analysis.
        The subfolder include following files
          1. 01_Setupu_&libraries: code used for creating folders and laoding libraries required for analysis.
          2. 02_Occurrence_record_from_raster_layer: code used for getting species occurrence records (as a data frame)
                                                     from raster layer.
          3. 03_Thinning_of_occurrence_record: code used for thinning the species occurrence records to reduce
                                                spatial autocorrelation.
          4. 04_Predictor_varibles_&_Correlation_matrix: codes to get the correlation matrix among the predictor varibles
                                                         used in the SDM analysis.
          5. 05_BIOMOD_setting_&_modeling: codes for setting ensemble modeling using BIOMOD R package.
          6. 06_Plots_from_modeling: codes for creating plots from the modleing output.
          7. 07_Difference_raster_calcualtion: code to calculate the difference between two raster layers (SDM output and unmixing output).
  data: This sub-folder includes data needed for SDM analyais and data managment process.
          1. mat_pre_abs_new: species occurrence record used for ensemble SDM modleing.
          2. fryxell_basin_AOI_newupdated: shape file for AOI (fryxell basin region).
          3. lake_fryxell_outline: shape file for lake fryxell.
  data_output: This sub-folder inlcudes files that are generated during data processing and analysis.
          1. absence_mat_new_thin1: absence points after thinnning process.
          2. cor_mats: correlation matrix after correlation analysis among predictor variables.
          3. presence_mat_new_thin1: presence points after thinning process.
  figure_output: This- subfolder includes figures created for the manuscript.
          1. Figure1E:ensemble probability map for black mats distribution.
          2. FigureS1: predictor varibles used in predicting black mats distribution.
          3. FigureS2: model evaluations scores of TSS adn ROC.
          4. FigureS3: percentage contribution of selected predictor variables for the distribution of black 
                       microbial mats
          5. FigureS4: Response curve of environmental variables to show their relationship with predicted 
                       distribution of black microbial mats.
          6. FiguresS5: Probability occurrence of black microbial mats from ten single algorithms selected for 
                        the distribution modeling. 

  
    
