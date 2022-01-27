# sep_main

## Summary

The `sep_main` function analyzes sensory evoked potentials. Once the target directory has been set up with the [required file structure](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/file_layout.md), and filenames match the [required naming conventions](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/filename_convention.md), make sure that MONA is in your Matlab path and run `sep_main` in the command window to start the program.

## Program Workflow

1. Preliminary Handling
    1. Request project directory containing config, labels, and parsed data.
    2. Read in SEP analysis configuration (`conf_sep.csv`) and subject labels (`labels_subjID.csv`).

2. Create SEP table.
3. Get unique channel groups and calculate total bins.
4. Create time vector for sliced window.
    1. Calculate baseline SEP.
    2. Calculate early response.
    3. Calculate late window.
    4. Store results in table.

## Configuration file

These are the parameters MONA will expect to see in `conf_sep.csv`:

|Parameter|Description|Format|
|----------------------|-------------|:-------:|
|`dir_name`|Name of main directory.|`String`|
|`include_dir`|Whether the directory ought to be searched.|`Boolean`|
|`include_sessions`|Controls which recording sessions are analyzed. [^incs]|`Array`|
