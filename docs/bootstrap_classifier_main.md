# bootstrap_classifier_main

## Summary

The `bootstrap_classifier_main` function serves to run a Euclidean distance PSTH classifier on parsed neural data and optionally bootstrap it. The program requires the [Parallel Computing Toolbox](https://www.mathworks.com/products/parallel-computing.html). Once this dependency is installed, the target directory has been set up with the [required file structure](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/file_layout.md), and filenames match the [required naming conventions](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/filename_convention.md), make sure that MONA is in your Matlab path and run `bootstrap_classifier_main` in the command window to start the program.

## Program Workflow

1. Preliminary Handling
    1. Request project directory containing config, labels, and parsed data.
    2. Read in bootstrap classifier configuration (`conf_bootstrap_classifier.csv`) and subject labels (`labels_subjID.csv`).
    3. Generate relative response matrix using parsed neural data.

2. Classification
    1. Run Euclidean Distance PSTH classifier.
    2. Run bootstrap (Optional, only if `bootstrap_iterations` > 0).

## Configuration File

The particular variables MONA will expect to find in `conf_bootstrap_classifier.csv` are:

|Variable Name|Description| Format |
|:-----------:|:--:| :----------:|
|`dir_name`|Name of directory containing data. Typically the subject ID.|`String`
|`include_dir`|Whether to include this directory in the classification.|`Boolean`
|`include_sessions`|Which recording sessions to include in the analysis.|`Integer`
|`psth_type`|Determines the type of PSTH used.|`psth`/`pca`/`ica`
|`bin_size`|Temporal resolution of data, or temporal resolution of relative response|`Numerical`
|`window_start`|Start of global event centered around trial onset.|`Numerical`
|`window_end`|End of global event centered around trial onset.|`Numerical`
|`response_start`|Start of the response window.|`Numerical`
|`response_end`|End of the response window.|`Numerical`
|`create_psth`|Whether to create PSTH from parsed spike data.|`Boolean`
|`trial_range`|If creating relative response, selects which trials are used to generate it.|`Numerical`
|`include_events`|If creating relative response, selects which events are used to generate it.|`String`
|`combine_chan_groups`|If `0`, keeps `chan_groups` separate. If `1`, combine all `chan_groups` together before classifying.|`Boolean`
|`boot_iterations`|# of bootstrap iterations to run.|`Integer`

## Output

The bootstrap classifier analysis will output a csv file containing the results across subjects and session files called `res_type_chan_eucl_classifier.csv` and `res_type_pop_eucl_classifier.csv` on the top level of the project directory, where `type` will be replaced by the value set for `psth_type` in the configuration file. The `chan` file is the performance of classifying with each channel separately while the `pop` file is the performance of using each `chan_group` to classify.

In addition to a number of variables that reflect the settings defined in the configuration file, both of these `.csv` files share the following columns:

|Variable Name| Description |
|:-----------| :----------|
|`chan_group`|Name of channel group specified in labels file.|
|`performance`|Classification Accuracy.|
|`mutual_info`|Mutual information as calculated from confusion matrix generated during leave-one-out classification.|
|`boot_perf`|Averaged bootstrapped performance after shuffling trial labels n times (n = boot_iterations).|
|`boot_mutual_info`|Averaged bootstrapped mutual information after shuffling trial labels n times (n = boot_iterations).|
|`corrected_info`|The `mutual_info` minus the `boot_mutual_info`.|

### res_type_chan_eucl_classifier.csv

The channel `.csv` further contains these specific columns:

|Variable Name| Description |
|:-----------| :----------|
|`channel`|Channel name.|
|`user_channels`|List of user defined channel names retrieved from labels if applicapable.|
|`recording_notes`|List of user notes retrieved from labels if applicapable.|

### res_type_pop_eucl_classifier.csv

The population `.csv` further contains these specific columns:

|Variable Name| Description |
|:-----------:| :----------:|
|`synergy_redundancy`|Difference between population and channel information.|
|`synergestic`|If `synergy_redundancy` > 0, synergistic = 1. Otherwise 0.|
