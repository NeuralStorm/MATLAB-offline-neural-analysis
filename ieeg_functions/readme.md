# Running the ieeg_main
The most important part is to make sure the files are laid out correctly. The code assumes the following structure:  

```
Project_ABC
    ├──ieeg_config.csv
    ├──pre_processed
    |    ├──ABC001
    |    |    └──power_struct data from fieldtrip (TODO: add pre-proc docs)
    |    ├──ABC###
    |    |    └──power_struct data from fieldtrip
    ├──tfr_plots (tfr = time frequency repesentation)
    |    ├──ABC###
    |    |    └──matlab figure of tfr
    ├──meshes
    |    ├──ABC###
    |    |    └──elec.mat
    |    | *.pial
    |    | *pial*.mat
```

Assuming the above structure is correct and the codebase is on Matlab's path then you can run the analysis using the commands listed below. Each main will pop up a gui for the user to select the parent direct to run the pipeline on (for example, Project_ABC above). See the section below on the current pipeline for more details on how the pipeline works.
```m
% Run ieeg pipeline
ieeg_main 
% Run classifier and bootstrapper on pca psth data
bootstrap_psth_main
```


# Current pipeline
1. Organize regions and powers according to config file
2. downsample and smooth according to span and downsample rate in config
3. take z-score accoring to use z score in config
4. Slice out global window defined by window start and window end in config
5. Format altered power data into MNTS format
6. PCA on MNTS format
7. format PC score into PSTH format  
---End of IEEG PIPELINE---  
The following is controlled by a psth_bootstrapper_main
8. Slice out response window and classify

## Classifying
Classifying is a bit more complicated when it comes to the parameter search. The pipeline is detailed below.
### Window Analysis
1. Organize regions and powers according to config file
2. downsample and smooth according to span and downsample rate in config
3. take z-score accoring to use z score in config
4. Slice out global window defined by window start and window end in config
5. Format altered power data into MNTS format
6. PCA on MNTS format
7. format PC score into PSTH format  
---End of IEEG PIPELINE---  
The following is controlled by a window main (work in progress)
8. Loop over different possible response windows
    * Slice out response window according to values set in loop and classify

### Bin Analysis (TBD)
1. Organize regions and powers according to config file
2. Loop over different possible downsample rates to alter bin size
    * downsample and smooth according to span and downsample rate in config
3. take z-score accoring to use z score in config
4. Slice out global window defined by window start and window end in config
5. Format altered power data into MNTS format
6. PCA on MNTS format
7. format PC score into PSTH format  
---End of IEEG PIPELINE---  
The following is controlled by a psth_bootstrapper_main
8. Slice out response window and classify

### Component Dropping (TBD)
1. Organize regions and powers according to config file
2. downsample and smooth according to span and downsample rate in config
3. take z-score accoring to use z score in config
4. Slice out global window defined by window start and window end in config
5. Format altered power data into MNTS format
6. PCA on MNTS format
7. format PC score into PSTH format  
---End of IEEG PIPELINE---  
The following is controlled by a component dropping main (work in progress)
8. Drop components based on some criteria (highest/lowest variance, randomly, etc)
9. Redefine population psth
    * Slice out response window and classify