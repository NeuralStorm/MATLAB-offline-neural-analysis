# ica_main

## Purpose

The `ica_main` function performs independent component analysis.

## Usage

Once the target directory has been set up with the [required file structure](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/file_layout.md), and filenames match the [required naming conventions](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/filename_convention.md), make sure that MONA is in your Matlab path and run `ica_main` in the command window to start the program.

## Configuration File

The particular variables MONA will expect to find in `conf_ica.csv` are:

|Variable Name|Description| Format |
|:-----------|:--| :----------:|
|`dir_name`|Name of main directory.|`String`|
|`include_dir`|Whether the directory ought to be searched.|`Boolean`|
|`include_sessions`|Controls which recording sessions are analyzed. [^incs]|`Array`|
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
|`ic_analysis`|?|?
|`convert_mnts_psth`|?|?
|`create_mnts`|Whether to create MNTS.|`Boolean`
|`apply_z_score`|?|?
|`use_mnts`|?|?
|`ic_pc`|# of PCs to use in ICA. `0` = no PCA.|`Integer`
|`extended`|Perform tanh() "extended-ICA" with sign estimation this # of training blocks. If greater than `0`, automatically estimate the number of sub-Gaussian sources. If less, fix # of sub-Gaussian comps to -#.|`Integer`
|`sphering`|Flag sphering of data|`on`/`off`
|`anneal`|Annealing constant between (0,1], controls convergence speed.|`Float`
|`anneal_deg`|Degrees weight change for annealing.|`Integer`
|`stop`|Defines the weight change value at which training will be stopped.|`Float`
|`max_steps`|Maximum number of ICA training steps.|`Integer`
|`bias`|Whether to perform bias adjustment.|`on`/`off`
|`momentum`|Training momentum, must be between (0,1].|`Float`
|`rnd_reset`|Reset the random seed. If `off`, ICA will always return the same decomposition|`on`/`off`
|`verbose`|Toggle ASCII message throughout run.|`on`/`off`
