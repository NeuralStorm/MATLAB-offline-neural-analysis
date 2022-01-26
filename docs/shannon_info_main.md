## Summary

The `shannon_info_main` function serves to calculate the entropy and mutual information of spike counts and timings found in response windows across trial in parsed neural data. Once the target directory has been set up with the [required file structure](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/file_layout.md), and filenames match the [required naming conventions](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/filename_convention.md), make sure that MONA is in your Matlab path and run `shannon_info_main` in the command window to start the program.

## Program Workflow

1. Preliminary Handling
    1. Request project directory containing config, labels, and parsed data.
    2. Read in shannon information configuration (`conf_shannon_info.csv`) and subject labels (`labels_subjID.csv`).
    3. Generate relative response matrix using parsed neural data.

2. Information Theory
    1. Calculate Shannon Mutual Information

## Configuration File

The particular variables MONA will expect to find in `conf_shannon_info.csv` are:

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

## Output

The Shannon Info Analysis will output a csv file containing the results across subjects and session files called `res_type_shannon_info.csv` on the top level of the project directory, where `type` will be replaced by the value set for `psth_type` in the configuration file. In addition to a number of variables that reflect the settings defined in the configuration file, this `.csv` will contain:

|Variable Name| Description |
|:-----------:| :----------:|
|`entropy_time`|[Entropy](https://en.wikipedia.org/wiki/Entropy_(information_theory)) calculated from all the unique timing patterns found in response window across trials.|
|`entropy_count`|Entropy calculated from unique spike counts found in response window across trials.|
|`mutual_info_time`|[Mutual information](https://en.wikipedia.org/wiki/Mutual_information) for events based on unique timing patterns across trials and events.|
|`mutual_info_count`|Mutual information for events based on unique counts across trials and events.|
