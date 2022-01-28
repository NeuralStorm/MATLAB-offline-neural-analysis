# sep_main

## Purpose

The `sep_main` function analyzes sensory evoked potentials.

## Usage

Once the target directory has been set up with the [required file structure](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/file_layout.md), and filenames match the [required naming conventions](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/filename_convention.md), make sure that MONA is in your Matlab path and run `sep_main` in the command window to start the program.

## SEP Workflow

![sep workflow](https://i.imgur.com/IkkzX3D.png)

## Configuration file

These are the parameters MONA will expect to see in `conf_sep.csv`:

|Parameter|Description|Format|
|----------------------|-------------|:-------:|
|`dir_name`|Name of main directory.|`String`
|`include_dir`|Whether the directory ought to be searched.|`Boolean`
|`include_sessions`|Controls which recording sessions are analyzed.|`Array`
|`sep_analysis`|Controls if auto-analysis is performed on each SEP.|`Boolean`
|`baseline_start`|Defines the beginning of the time window from which baseline measures are taken (pre-stimulation).|`Float` 
|`baseline_end`|Defines the end of the time window from which baseline measures are taken (pre-stimulation).|`Float`
|`threshold_scalar`|# of standard deviations added to background average to generate a threshold.|`Float`
|`early_response_start`|Start time of response window 1 (post-stimulation).|`Float`
|`early_response_start`|End time of response window 1 (post-stimulation).|`Float`
|`late_response_start`|Start time of response window 2 (post-stimulation).|`Float`
|`late_response_end`|End time of response window 2 (post-stimulation).|`Float`
|`make_sep_graphs`|Controls whether SEP figures are generated.|`Boolean`
|`sub_rows`|Defines # of rows displayed in the SEP subplots.|`Integer`
|`sub_cols`|Defines # of columns displayed in the SEP subplots.|`Integer`
|`visible_plot`|Controls whether plots are displayed as plotting routine proceeds.|`Boolean`
