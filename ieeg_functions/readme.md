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
# Questions
* For classification: Should response window be -2 to 0s or -1 to 0s?
* How should we control selection of PCs?
    * Currently select 3 PCs
    * Should we be setting a threshold of percent variance for PCs?
* Should we run the powerbands versions of all our pools?
    * Mirror processing steps right before PCA (downsampling, smoothing, z-scoring, and slicing)
* Why do we only z-score over time dimension?

# Pipeline
## Overview
1. Organize chan_group and powers according to pool set in config
     * Debug: pool 1: All powerbands for LPFC and OFC separately
     * pool 2: high bands: LPFC + OFC, low bands: LPFC + OFC
2. downsample and smooth according to span and downsample rate in config
    * Debug: Downsampled to 50ms bin size typically
3. take z-score accoring to use z score in config
    * Z-score taken for each trial separately (ie: we only z-score the time dimension for each channel and trial)
4. Slice out global window defined by window start and window end in config
    * Debug: -2s to 0s from -3s to 2s window given
5. Format altered power data into MNTS format
6. PCA on MNTS format
    * Debug: Selection of top 3 pcs
7. format PC score into PSTH format  
---End of IEEG Main---  
The following is controlled by a psth_bootstrapper_main
8. Combine power-chan_group PCs
9. Slice out response window and classify
    * Debug: -2s to 0s response window

## Classifying
Classifying is a bit more complicated when it comes to the parameter search. The pipeline is detailed below.

### Bin Analysis
1. Organize chan_group and powers according to pool set in config
     * Debug: pool 1: All powerbands for LPFC and OFC separately
     * pool 2: high bands: LPFC + OFC, low bands: LPFC + OFC
2. downsample and smooth according to span and downsample rate in config
    * Manually change span and downsample_rate
    * Current selected bin sizes: 20, 50, and 100ms
3. take z-score accoring to use z score in config
    * Z-score taken for each trial separately (ie: we only z-score the time dimension for each channel and trial)
4. Slice out global window defined by window start and window end in config
    * Debug: -2s to 0s from -3s to 2s window given
5. Format altered power data into MNTS format
6. PCA on MNTS format
    * Debug: Selection of top 3 pcs
7. format PC score into PSTH format  
---End of IEEG Main---  
The following is controlled by a psth_bootstrapper_main
8. Combine power-chan_group PCs
9. Slice out response window and classify

### Window Analysis
1. Organize chan_group and powers according to pool set in config
     * Debug: pool 1: All powerbands for LPFC and OFC separately
     * pool 2: high bands: LPFC + OFC, low bands: LPFC + OFC
2. downsample and smooth according to span and downsample rate in config
    * Debug: Downsampled to 50ms bin size typically
3. take z-score accoring to use z score in config
    * Z-score taken for each trial separately (ie: we only z-score the time dimension for each channel and trial)
4. Slice out global window defined by window start and window end in config
    * Debug: -2s to 0s from -3s to 2s window given
5. Format altered power data into MNTS format
6. PCA on MNTS format
    * Debug: Selection of top 3 pcs
7. format PC score into PSTH format  
---End of IEEG Main---  
The following is controlled by a window main (work in progress)
8. Combine PCs from different pools
9. Loop over different possible response windows
    * to_response_start: Expand window towards -2s stepping by bin size
    * to_response_end: Expand window towards 0s stepping by bin size

### Channel Dropping
1. Organize chan_group and powers according to pool set in config
     * Debug: pool 1: All powerbands for LPFC and OFC separately
     * pool 2: high bands: LPFC + OFC, low bands: LPFC + OFC
2. downsample and smooth according to span and downsample rate in config
    * Debug: Downsampled to 50ms bin size typically
3. take z-score accoring to use z score in config
    * Z-score taken for each trial separately (ie: we only z-score the time dimension for each channel and trial)
4. Slice out global window defined by window start and window end in config
    * Debug: -2s to 0s from -3s to 2s window given
5. Format altered power data into MNTS format
6. PCA on MNTS format
    * Debug: Selection of top 3 pcs
7. format PC score into PSTH format  
---End of IEEG Main---  
The following is controlled by a component dropping main (work in progress)
8. Combine power-chan_group PCs
9. Order PCs by % variance (max -> min)
10. Drop max pc and redefine population PSTH until all channels are dropped
    * Slice out response window and classify
