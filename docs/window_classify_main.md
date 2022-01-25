## Summary

The `window_classify_main` function serves to . Once the required file structure outlined in the [general MONA documentation](https://github.com/NeuralStorm/docs/tree/kev-rewrites/offline_analysis) is set up and filenames match the naming conventions described in the aforementioned documentation, make sure that MONA is in your Matlab path and run `window_classify_main` in the command window to start the program.

## Program Workflow

1. Preliminary Handling
    1. Request project directory containing config, labels, and parsed data.
    2. Read in bootstrap classifier configuration (`conf_window_classify.csv`) and subject labels (`labels_subjID.csv`).
    3. Generate relative response matrix using parsed neural data.

2. Classification

## Configuration File

The particular variables MONA will expect to find in `conf_window_classify.csv` are:

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
|`boot_iterations`|# of bootstrap iterations to run.|`Integer`
|`combine_chan_groups`|If `0`, keeps `chan_groups` separate. If `1`, combine all `chan_groups` together before classifying.|`Boolean`
|`window_direction`|Specific window direction.|`to_response_end`/`?`

## Output
