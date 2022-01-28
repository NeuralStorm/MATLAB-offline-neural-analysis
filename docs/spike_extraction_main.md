# spike_extraction_main

## Summary

This function attempts to extract spikes from continuous neural data to enable use of MONA's other analytical routines. Once the target directory has been set up with the [required file structure](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/file_layout.md), and filenames match the [required naming conventions](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/filename_convention.md), make sure that MONA is in your Matlab path and run `spike_extraction_main` in the command window to start the program.

## Configuration Table
|Variable Name| Description |Format|
|:-----------|:--|:----------:|
|`spike_thresh`|Spike detection threshold (# of standard deviations to add to average background).|`Boolean`
|`spike_baseline_start`|Start time of the background window used to generate an average background threshold for spike detection (pre-stimulus).|`Float`
|`spike_baseline_end`|End time of the background window used to generate an average background threshold for spike detection (pre-stimulus).|`Float`
