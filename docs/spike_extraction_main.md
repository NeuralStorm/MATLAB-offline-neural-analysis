# spike_extraction_main

## Purpose

This function attempts to extract spikes from continuous neural data to enable use of MONA's other analytical routines.

## Usage

Once the target directory has been set up with the [required file structure](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/file_layout.md), and filenames match the [required naming conventions](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/filename_convention.md), make sure that MONA is in your Matlab path and run `spike_extraction_main` in the command window to start the program.

## Configuration Table

These are the parameters MONA will expect to see in `conf_spike_extract.csv`:

|Variable Name| Description |Format|
|:-----------|:--|:----------:|
|`spike_thresh`|Spike detection threshold (# of standard deviations to add to average background).|`Boolean`
|`spike_baseline_start`|Start time of the background window used to generate an average background threshold for spike detection (pre-stimulus).|`Float`
|`spike_baseline_end`|End time of the background window used to generate an average background threshold for spike detection (pre-stimulus).|`Float`
|`filter_data`|Controls whether continuous data is filtered.|`Boolean`
|`notch_filt`|Controls whether [notch filter](https://www.everythingrf.com/community/what-is-a-notch-filter) is used when filtering.|`Boolean`
|`notch_freq`|Notch filter frequency.|`Integer`
|`notch_bandwidth`|Notch filter bandwidth.|`Integer`
|`filt_type`|Filter type.|`bandpass`/`high`/`low`
|`filt_order`|Filter order.|`Integer`
|`filt_freq`|Filter's frequency parameters. One integer for high & low, two for bandpass.|`Integer`
|`use_raw`|Controls whether filtered or raw data is used for analysis.|`Boolean`
|`create_sep`|Controls whether an SEP is created.|`Boolean`|
|`trial_range`|Which trials to include. Uses all if blank.|`Integers`
