# ica_main

## Summary

The `ica_main` function performs independent component analysis on feature sets stored in an MNTS file format. Once the target directory has been set up with the [required file structure](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/file_layout.md), and filenames match the [required naming conventions](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/filename_convention.md), make sure that MONA is in your Matlab path and run `ica_main` in the command window to start the program.

## Configuration File

The particular variables MONA will expect to find in `conf_ica.csv` are:

|Variable Name|Description| Format |
|:-----------|:--| :----------:|
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
