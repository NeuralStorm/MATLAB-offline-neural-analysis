# recfield_main
## Steps in recfield_main
1. Select project directory with config, labels, and data
    * conf_recfield.csv
    * labels_subjID.csv
2. Format relative response matrix from neural data
3. Run receptive field analysis  
    * If cluster_analysis is true, run cluster analysis
4. Plot PSTH and receptive field measures and save to graph directory
---
# Running recfield_main  
1. Make sure data is organized in proper file structure. [See here for more details.](https://github.com/moxon-lab-codebase/docs/blob/main/offline_analysis/file_layout.md)
2. Make sure filenames match [naming convention.](https://github.com/moxon-lab-codebase/docs/blob/main/offline_analysis/filename_convention.md)
3. Make sure offline codebase is on your Matlab path. [Click here for details on adding dependencies](https://github.com/moxon-lab-codebase/docs/blob/main/matlab_basics/adding_dependencies.md).
4. Make sure you have these other dependencies as well:
    * [Curve Fitting Toolbox](https://www.mathworks.com/products/curvefitting.html): This allows for the smooth function to be called during significance check.
    * [Parallel Computing Toolbox](https://www.mathworks.com/products/parallel-computing.html): This is used to help speed up plotting the PSTHS. This is not needed if you skip graphing
    * [Scrollsubplot](https://www.mathworks.com/matlabcentral/fileexchange/7730-scrollsubplot): The scrollsubplot is required for plotting the PSTHs. This is not needed if you skip graphing.
5. [Make a labels file for each subject.](https://github.com/moxon-lab-codebase/docs/blob/main/offline_analysis/labels_file.md)
    * labels_subjID.csv
6. Set up config file. See config section below for more details.
    * conf_recfield.csv
7. Run `recfield_main` in Matlab's command window and select path to project directory.

## Config
    * conf_recfield.csv
### Global Variable
|Variable Name|Type| Description |
|:-----------:|:--:| :----------:|
|dir_name|char/str|Name of directory with data. Typically subject ID|
|include_dir|boolean|Controls if directory passes through main|
|include_sessions|int|Controls if a given recording session file is analyzed|
|psth_type|char/str|Determines if psth, pca, or ica data is used|
|bin_size|numerical|Temporal resolution of data is binning, or temporal resolution of relative response|
|window_start|numerical|Start of global event centered around trial onset|
|window_end|numerical|End of global event centered around trial onset|
|baseline_start|numerical|Start of baseline window|
|baseline_end|numerical|End of baseline window|
|response_start|numerical|Start of response window|
|response_end|numerical|End of response window|

### Creating relative response
|Variable Name|Type| Description |
|:-----------:|:--:| :----------:|
|creaste_psth (should change name)|boolean|Controls if creating relative response from parsed spike data|
|trial_range|numerical|If creating relative response, selects which trials are used to make relative response|
|include_events|char/str|If creating relative response, selects which events are used to make relative response|

### Receptive Field Analysis
|Variable Name|Type| Description |
|:-----------:|:--:| :----------:|
|mixed_smoothing|boolean|True: fbl, lbl, and duration metrics found on smoothed psth. False: All metrics are found on smoothed psth|
|span|int|Controls smoothing of psth with moving average filter. Span < 3: No smoothing, Span >= 3: smoothing (if even, span = span - 1. See [Matlab's smooth documentation](https://www.mathworks.com/help/curvefit/smooth.html) for more detail)|
|threshold_scalar|numerical|Scales standard deviation of baseline psth|
|consec_bins|numerical|Number of consecutive bins required above threshold for significant response|
|sig_check (should change to be strings)|Numerical|0: no stat test, 1: paired t-test, 2: paired ks-test. Compares baseline psth and response psth to see if they are significantly different|
|sig_alpha (should change name)|numerical|Controls alpha for statistical tests|
### Cluster Analysis
|Variable Name|Type| Description |
|:-----------:|:--:| :----------:|
|cluser_analysis|boolean|True: does cluster analysis False: skips cluster analysis|
|bin_gap|numerical|consecutive number of bins below threshold needed to differentiate between clustered responses in response window|
### Graphing PSTH
|Variable Name|Type| Description |
|:-----------:|:--:| :----------:|
|make_psth_graphs|boolean|True: Make psth graphs False: Skips graphing|
|plot_rf|boolean|True: Plot metrics from recfield analysis False: Skips plotting metrics|
|sub_cols|int|number of visible columns shown on channel subplot|
sub_rows|int|number of visible rows shown on channel subplot|
### Normalized Variance
|Variable Name|Type| Description |
|:-----------:|:--:| :----------:|
|epsilon|numerical|Number to ensure there is no division of 0 when finding normalized variance|
|norm_var_scaling|numerical|This is variable C in the normalized variance paper. Scales std, see paper for more details|

## Receptive Field Output
The receptive field analysis will output a csv file containing the results across subjects and session files called `res_type_receptive_field.csv` on the top level of the project directory, where type = psth_type set in config.
### Filename Info

|Variable Name| Description |
|:-----------:| :----------:|
|filename|Name of file where data was from|
|animal_id|subject id in filename|
|exp_group|subject experimental group in filename|
|exp_condition|subject experimental condition in filename|
|optional_info|any optional info in filename|
|date|date in filename|
|record_session|session in filename|
### Receptive Field Params
All of these columns are set in the config described above.

|Variable Name| Description |
|:-----------:| :----------:|
|bin_size|see above|
|window_start|see above|
|window_end|see above|
|baseline_start|see above|
|baseline_end|see above|
|response_start|see above|
|response_end|see above|
|sig_alpha|see above|
|mixed_smoothing|see above|
|sig_check|see above|
|consec_bins|see above|
|span|see above|
|threshold_scalar| see above|
### Receptive Field Results
For more details on how these are calculated, [please see this notebook.](https://github.com/moxon-lab-codebase/docs/blob/main/offline_analysis/receptive_field_analysis.ipynb)

|Variable Name| Description |
|:-----------:| :----------:|
|chan_group|Name of channel group specified in labels file|
|channel|Name of channel|
|event|Name of event|
|significant|boolean that describes if channel had significant response|
|background_rate|average background activity in baseline window|
|background_std|standard deviation of background activity in baseline window|
|response_window_firing_rate|average response activity in response window|
|response_window_tot_spikes|sum of response activity in response window|
|threshold|threshold applied to response window to determine if response is significantly different from baseline|
|first_latency|latency of first bin above threshold in response|
|last_latency|latency of last bin above threshold in response|
|duration|time from first to last latency|
|peak_latency|time of peak in response|
|peak_response|magnitude of peak in response|
|corrected_peak|peak magnitude with background firing rate subtracted|
|response_magnitude|sum of activity between first and last bin|
|corrected_response_magnitude|response magnitude with background firing rate subtracted|
|tot_sig_events|total significant events for given channel|
|principal_event|event with largest response magnitude|
|norm_response_magnitude|response magnitude normalized against principal event|
|brf_s|same as background rate, but in unit of time instead of bins|
|bfr_var|variance of baseline window in unit of time|
|fano|fano factor of baseline window|
|norm_var|normalized variance of baseline window|

## Cluster Analysis Output
If selected, the cluster analysis will also output a csv file containing the results across subjects and session files called `res_type_cluster_analysis.csv` on the top level of the project directory, where type = psth_type set in config.

### Filename Info

|Variable Name| Description |
|:-----------:| :----------:|
|filename|Name of file where data was from|
|animal_id|subject id in filename|
|exp_group|subject experimental group in filename|
|exp_condition|subject experimental condition in filename|
|optional_info|any optional info in filename|
|date|date in filename|
|record_session|session in filename|
### Receptive Field Params
All of these columns are set in the config described above.

|Variable Name| Description |
|:-----------:| :----------:|
|bin_size|see above|
|window_start|see above|
|window_end|see above|
|baseline_start|see above|
|baseline_end|see above|
|response_start|see above|
|response_end|see above|
|sig_alpha|see above|
|mixed_smoothing|see above|
|sig_check|see above|
|consec_bins|see above|
|span|see above|
|threshold_scalar| see above|

### Cluster Analysis Results
These metrics are calculated the same way as the receptive field metrics are, but applied to a "cluster" response. Each calculation is prefaced with which cluster it came from and there are three clusters reported: first, last, and primary cluster (example columns: first_duration, primary_duration, and last_duration for each cluster). The primary cluster is the cluster with the biggest response and used for the normalization calculations for the other clusters.

|Variable Name| Description |
|:-----------:| :----------:|
|chan_group|Name of channel group specified in labels file|
|channel|Name of channel|
|event|Name of event|
|tot_clusters|Total clusters in channel PSTH found|
|cluster_first_latency|latency of first bin above threshold in response|
|cluster_last_latency|latency of last bin above threshold in response|
|cluster_duration|time from first to last latency|
|cluster_peak_latency|time of peak in response|
|cluster_peak_response|magnitude of peak in response|
|cluster_corrected_peak|peak magnitude with background firing rate subtracted|
|cluster_response_magnitude|sum of activity between first and last bin|
|cluster_corrected_response_magnitude|response magnitude with background firing rate subtracted|
|cluster_norm_response_magnitude|Normalized response magnitude to cluster with largest response magnitude|