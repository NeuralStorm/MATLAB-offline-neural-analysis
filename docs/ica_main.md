# ica_main
## Steps in ica_main
1. Select project directory with config, labels, and data
    * conf_ica.csv
    * labels_subjID.csv
2. Format multineuron timeseries (mnts) matrix from neural data
3. Run ICA
4. Option to reformat resulting ic mapped datat into relative response for use in other analyses (ie: psth classifier).
---
# Running ica_main
1. Make sure data is organized in proper file structure. [See here for more details.](./file_layout.md)
2. Make sure filenames match [naming convention.](./filename_convention.md)
3. Make sure offline codebase is on your Matlab path. [Click here for details on adding dependencies](https://github.com/moxon-lab-codebase/docs/blob/main/matlab_basics/adding_dependencies.md).
4. Add [EEGLab](https://www.mathworks.com/matlabcentral/fileexchange/56415-eeglab?s_tid=srchtitle) to your path as well. (`runica` is used to run ICA)
5. [Make a labels file for each subject.](./labels_file.md)
    * labels_subjID.csv
6. Set up config file. See config section below for more details.
    * conf_pca.csv
7. Run `ica_main` in Matlab's command window and select path to project directory.

## Config
    * conf_ica.csv
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

### ICA
Note: Documentation taken from Matlab when running "help runica". See EEGlab's documentation for more details.
|Variable Name|Type| Description |Variable use|
|:-----------:|:--:| :----------:|:----------:|
|ic_pc|int|# of pcs to use in ICA. 0 = no PCA|calc_ica|
|extended|int|perform tanh() "extended-ICA" with sign estimation N training blocks. If N > 0, automatically estimate the number of sub-Gaussian sources. If N < 0, fix number of sub-Gaussian comps to -N [faster than N>0] (default|0 -> off)| calc ic|
|sphering|string|['on'/'off'] flag sphering of data (default -> 'on')|calc ic|
|anneal|float|annealing constant (0,1] (defaults -> 0.90, or 0.98, extended) controls speed of convergence|calc ic|
|anneal_deg|int|degrees weight change for annealing (default -> 70)|calc ic|
|stop|float|stop training when weight-change < this (default -> 1e-6 if less than 33 channel and 1E-7 otherwise)|calc ic|
|max_steps|int|max number of ICA training steps    (default -> 512)|calc ics|
|bias|string|['on'/'off'] perform bias adjustment    (default -> 'on')|calc ic|
|momentum|float|[0<f<1] training momentum (default -> 0)|calc ic|
|rnd_reset|string|['on'|'off'] reset the random seed. Default is off (although it used to be on prior to 2015. This means that ICA will always return. the same decomposition unless this option is set to 'on'.|calc ic|
|verbose|string|give ascii messages ('on'/'off') (default -> 'on')|calc ic|

### Format RR
|Variable Name|Type| Description |
|:-----------:|:--:|:-----------:|
|convert_mnts_psth|boolean|1: convert mnts matrix into rr matrix for later use. <br/>0: Does not convert a specified mnts to rr|
|use_mnts|boolean|Ignored if `convert_mnts_psth` is set to false<br/>In most cases, this should be set to false (0) since the user generally wants to convert the PC mapped data into the rr format<br/>1: convert mnts input matrix for pca (`mnts/data/subj`) into rr format. Useful if your data has not been formatted in the rr matrix before. <br/>0: Converts PC mapped mnts, from PCA, into the rr format (`mnts/pca/subj`)|