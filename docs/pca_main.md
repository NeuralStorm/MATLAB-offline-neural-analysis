# pca_main
## Steps in pca_main
1. Select project directory with config, labels, and data
    * conf_pca.csv
    * labels_subjID.csv
2. Format multineuron timeseries (mnts) matrix from neural data
3. Run PCA
4. Option to reformat resulting pc mapped datat into relative response for use in other analyses (ie: psth classifier).
---
# Running pca_main
1. Make sure data is organized in proper file structure. [See here for more details.](https://github.com/moxon-lab-codebase/docs/blob/main/offline_analysis/file_layout.md)
2. Make sure filenames match [naming convention.](https://github.com/moxon-lab-codebase/docs/blob/main/offline_analysis/filename_convention.md)
3. Make sure offline codebase is on your Matlab path. [Click here for details on adding dependencies](https://github.com/moxon-lab-codebase/docs/blob/main/matlab_basics/adding_dependencies.md).
4. [Make a labels file for each subject.](https://github.com/moxon-lab-codebase/docs/blob/main/offline_analysis/labels_file.md)
    * labels_subjID.csv
5. Set up config file. See config section below for more details.
    * conf_pca.csv
6. Run `pca_main` in Matlab's command window and select path to project directory.

## Config
    * conf_pca.csv
### Global Variable
|Variable Name|Type| Description |
|:-----------:|:--:|:-----------:|
|dir_name|char/str|Name of directory with data. Typically subject ID|
|include_dir|boolean|Controls if directory passes through main|
|include_sessions|int|Controls if a given recording session file is analyzed|
|bin_size|numerical|Temporal resolution of data is binning, or temporal resolution of relative response|
|window_start|numerical|Start of global event centered around trial onset|
|window_end|numerical|End of global event centered around trial onset|

### Creating mnts
|Variable Name|Type| Description |
|:-----------:|:--:|:-----------:|
|creaste_mnts|boolean|1: creates mnts from `parsed_spike` before running pca. Note: if there are mntss already along the `mnts/data/subjId/` path, these files will be overwritten. 0: loads the mnts data from `mnts/data/subjId/`.|
|trial_range|numerical|If creating relative response, selects which trials are used to make relative response|
|include_events|char/str|If creating relative response, selects which events are used to make relative response|

### PCA
|Variable Name|Type| Description |
|:-----------:|:--:|:-----------:|
|pc_analysis|boolean|0 = skips pca (useful if there is mnts data that you want to convert into the rr format for other analyses), <br/>1 = runs pca|
|apply_z_score|boolean|0. Does not apply z-score to the columns of mnts (columns are typically all the trials observed for a given channel) <br/>1. Applies z-score to the columns of the mtns matrix before pca. Note: you typically want this to be true to help PCA isolate out componenents with meaningful variance|
|feature_filter|string|"all": keep all pcs after PCA, <br/>"pcs": Keep # of pcs set in feature_value, <br/>"percent_var": Use min number of PCs that meet set % in feature_value|
|feature_value|int or float|"all": unused, <br/>"pcs": int > 0 specifying how many pcs to keep, <br/>"percent_var": % of variance desired to be explained by pcs|

### Format RR
|Variable Name|Type| Description |
|:-----------:|:--:|:-----------:|
|convert_mnts_psth|boolean|1: convert mnts matrix into rr matrix for later use. <br/>0: Does not convert a specified mnts to rr|
|use_mnts|boolean|Ignored if `convert_mnts_psth` is set to false<br/>In most cases, this should be set to false (0) since the user generally wants to convert the PC mapped data into the rr format<br/>1: convert mnts input matrix for pca (`mnts/data/subj`) into rr format. Useful if your data has not been formatted in the rr matrix before. <br/>0: Converts PC mapped mnts, from PCA, into the rr format (`mnts/pca/subj`)|