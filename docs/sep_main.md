# sep_main

## Summary

The `sep_main` function analyzes sensory evoked potentials. Once the target directory has been set up with the [required file structure](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/file_layout.md), and filenames match the [required naming conventions](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/filename_convention.md), make sure that MONA is in your Matlab path and run `sep_main` in the command window to start the program.

## SEP Analysis Workflow

![sep workflow](https://i.imgur.com/IkkzX3D.png)

## Configuration file

These are the parameters MONA will expect to see in `conf_sep.csv`:

|Parameter|Description|Format|
|----------------------|-------------|:-------:|
|`dir_name`|Name of main directory.|`String`|
|`include_dir`|Whether the directory ought to be searched.|`Boolean`|
|`include_sessions`|Controls which recording sessions are analyzed. [^incs]|`Array`|
