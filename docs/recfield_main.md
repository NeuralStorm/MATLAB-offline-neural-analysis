# recfield_main

## Summary

The `recfield_main` function performs a receptive field analysis, and will optionally perform a cluster analysis, as well as plot a peri-stimulus time histogram. The program requires the [Curve Fitting Toolbox](https://www.mathworks.com/products/curvefitting.html) for smoothing, and if graphing is enabled, the [Scrollsubplot](https://www.mathworks.com/matlabcentral/fileexchange/7730-scrollsubplot) to plot the PSTHs and the [Parallel Computing Toolbox](https://www.mathworks.com/products/parallel-computing.html) to speed that process up.

Once these dependencies are installed, the target directory has been set up with the [required file structure](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/file_layout.md), and filenames match the [required naming conventions](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/filename_convention.md), make sure that MONA is in your Matlab path and run `recfield_main` in the command window to start the program.

## Program Workflow

1. Preliminary Handling
    1. Request project directory containing config, labels, and parsed data.
    2. Read in receptive field analysis configuration (`conf_recfield.csv`) and subject labels (`labels_subjID.csv`).
    3. Generate relative response matrix using parsed neural data.
    4. Save relative response matrix to PSTH format file.

2. Actual Analysis
    1. Receptive Field Analysis
    2. Cluster Analysis (Optional.)

3. Plotting Routines
    1. Plot peri-stimulus time histogram.
    2. Plot receptive field measures.
    3. Save all plots to the graph directory.

## Configuration file

These are the parameters MONA will expect to see in `conf_recfield.csv`:

|Parameter|Description|Format|
|----------------------|-------------|:-------:|
|`dir_name`|Name of main directory.|`String`|
|`include_dir`|Whether the directory ought to be searched.|`Boolean`|
|`include_sessions`|Controls which recording sessions are analyzed. [^incs]|`Array`|
|`psth_type`|Whether to use PSTH files, PCA PSTH files, or ICA PSTH files.|`PSTH`/`PCA`/`ICA`|
|`bin_size`|Bin size of the histogram.|`Float`/`Int`|
|`window_start`|Time window prior to beginning of the event. [^negn]|`Float`/`Int`|
|`window_end`|Time window after beginning of the event. [^posn]|`Float`/`Int`|
|`baseline_start`|Start of baseline window used in the analysis. [^negpre]|`Float`/`Int`|
|`baseline_end`|End of baseline window used in the analysis. [^negpre]|`Float`/`Int`|
|`response_start`|Start of response window used in the analysis.|`Float`/`Int`|
|`response_end`|End of response window used in the analysis.|`Float`/`Int`|
|`create_psth`|Whether to create relative response from parsed spike data.|`Boolean`|
|`trial_range`|Inclusive range of trials to use if creating relative response. Uses all if empty.|`Array`|
|`include_events`|Events to be used if creating relative response. Uses all if empty.|`Array`|
|`update_psth_windows`|Controls whether the response and baseline windows are updated.|`Boolean`
|`span`|# of bins over which to smooth values with moving average filter. [^span]|Odd `Int`|
|`threshold_scalar`|Scales background firing rate standard deviation of baseline PSTH.|`Int`
|`consec_bins`|# of consecutive bins that must cross the threshold for significance.|`Int`
|`sig_check`|Selects statistical check for significant response. [^sigch].|`0`/`1`/`2`
|`sig_alpha`|Defines the alpha for the statistical test chosen by `sig_check`.|`Float`
|`mixed_smoothing`|Defines which PSTH is used to calculate response metrics. [^mixsm]|`Boolean`
|`cluster_analysis`|Controls whether or not to run cluster analysis.|`Boolean`
|`bin_gap`|Controls # of consecutive bins that must be below threshold before a new cluster can be designated.|`Int`
|`make_psth_graphs`|Defines whether PSTH graphs are generated.|`Boolean`
|`plot_rf`|Defines whether to plot receptive field analysis metrics.|`Boolean`
|`sub_cols`|# of visible columns shown on channel subplot.|`Int`
|`sub_rows`|# of visible rows shown on channel subplot.|`Int`
|`rf_analysis`|Whether graphs should include threshold, first, and last bin latency.|`Boolean`
|`cluster_analysis`|Whether to plot cluster rather than the overall response.|`Boolean`
|`cluster_flag`|Controls which cluster is plotted. [^clufl]|`String`
|`epsilon`|Constant used to prevent division by zero when finding normalized variance.|`Float`
|`norm_var_scaling`|C variable in the normalized variance paper. Scales std, see paper for more details.|`Float`

[^span]: If less than 3, no smoothing is done. If greater than 3, smoothes with moving average filter. If an even number, span will be equal to that number minus 1. See [Matlab's smooth documentation](https://www.mathworks.com/help/curvefit/smooth.html) for more detail.
[^sigch]: If zero, no test is performed. If one, does a paired t test. If two, does a paired ks test. Compares baseline psth and response psth to see if they are significantly different.
[^mixsm]: If true, fbl, lbl, and duration metrics found on smoothed psth. If false, all metrics are found on smoothed psth. 
[^clufl]: If `first`, plots first cluster. If `primary`, plots primary cluster based on response magnitude. If `last`, plots last cluster.

## Output

### Receptive Field Analysis Output

The receptive field analysis will output a csv file containing the results across subjects and session files called `res_type_receptive_field.csv` on the top level of the project directory, where `type` will be replaced by the value set for `psth_type` in the configuration file. For more details on how these are calculated, [please see this notebook.](https://github.com/moxon-lab-codebase/docs/blob/main/offline_analysis/receptive_field_analysis.ipynb) Values to be expected in the results include:

|Variable Name|Description |
|:-----------|:----------|
|`chan_group`|Name of channel group specified in labels file.|
|`channel`|Channel name.|
|`event`|Event name.|
|`significant`|Boolean describing whether channel saw significant response.|
|`background_rate`|Average background activity in baseline window.|
|`background_std`|Standard deviation of background activity in baseline window.|
|`response_window_firing_rate`|Average response activity in response window.|
|`response_window_tot_spikes`|Sum of response activity in response window.|
|`threshold`|Threshold applied to response window to determine response significance relative to baseline.|
|`first_latency`|Latency of first bin above threshold in response.|
|`last_latency`|Latency of last bin above threshold in response.|
|`duration`|Time from first to last latency.|
|`peak_latency`|Time of response peak.|
|`peak_response`|Magnitude of response peak.|
|`corrected_peak`|Peak magnitude minus background firing rate.|
|`response_magnitude`|Sum of activity between first and last bin.|
|`corrected_response_magnitude`|Response magnitude minus background firing rate.|
|`tot_sig_events`|Total # of significant events for a given channel.|
|`principal_event`|Event with largest response magnitude.|
|`norm_response_magnitude`|Response magnitude normalized against principal event.|
|`brf_s`|Same as background rate, but in unit of time instead of bins.|
|`bfr_var`|Variance of baseline window in unit of time.|
|`fano`|[Fano factor](https://en.wikipedia.org/wiki/Fano_factor) of baseline window.|
|`norm_var`|Normalized variance of baseline window.|

### Cluster Analysis Output

If selected, the cluster analysis will also output a `.csv` file containing the results across subjects and session files called `res_type_cluster_analysis.csv` on the top level of the project directory, where `type` will be replaced by the value set for `psth_type` in the configuration file.

These metrics are calculated the same way as the receptive field metrics are, but applied to a "cluster" response. Each calculation is prefaced with which cluster it came from, of which three are reported: first, last, and primary cluster (Column names may vary for each cluster, e.g. `first_duration`, `primary_duration`, and `last_duration`). The primary cluster is the cluster with the biggest response and used for the normalization calculations for the other clusters. Values to be expected in these results include:

|Variable Name| Description |
|:-----------:| :----------:|
|`chan_group`|Name of channel group specified in labels file.|
|`channel`|Channel name.|
|`event`|Event name.|
|`tot_clusters`|Total clusters in channel PSTH found.|
|`cluster_first_latency`|Latency of first bin above threshold in response.|
|`cluster_last_latency`|Latency of last bin above threshold in response.|
|`cluster_duration`|Time from first to last latency.|
|`cluster_peak_latency`|Time of response peak.|
|`cluster_peak_response`|Magnitude of response peak.|
|`cluster_corrected_peak`|Peak magnitude minus background firing rate.|
|`cluster_response_magnitude`|Sum of activity between first and last bin.|
|`cluster_corrected_response_magnitude`|Response magnitude minus background firing rate.|
|`cluster_norm_response_magnitude`|Normalized response magnitude to cluster with largest response magnitude.|
