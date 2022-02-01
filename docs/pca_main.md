# pca_main

## Purpose

The `pca_main` function performs principal component analysis on feature sets stored in an MNTS file format and optionally filters principal components.

## Usage

Once the target directory has been set up with the [required file structure](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/file_layout.md), and filenames match the [required naming conventions](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/filename_convention.md), make sure that MONA is in your Matlab path and run `pca_main` in the command window to start the program.

## Configuration File

The particular variables MONA will expect to find in `conf_pca.csv` are:

|Variable Name|Description| Format |
|:-----------|:--| :----------:|
|`pc_analysis`|?|?
|`convert_mnts_psth`|
|`create_mnts`|Whether to create MNTS.|`Boolean`
|`apply_z_score`|?|?
|`use_mnts`|?|?
|`feature_filter`|If `all`, keep all PCs after PCA. If `pcs`, keep # specified by `feature_value`. If `percent_var`, use PCs that meet % set by `feature_value` |`all`/`pcs`/`percent_var`
|`feature_value`|If `feature_filter` = `pcs`, # of PCs to keep. If `percent_var`, % of variance explained by PCs to be kept.|`Integer`
|`use_z_mnts`|If `0`, use MNTS for PCA input. If `1`, use `z_mnts`.|`Boolean`

## Output

The function will output `pca_results`, which will contain the following fields for each feature set run through PCA:

|Variable Name| Description |
|:-----------| :----------|
|`component_variance`|Name of channel group specified in labels file.|
|`eigenvalues`|Vector with eigenvalues.|
|`coeff`|Matrix containing coefficient weights used to scale MNTS into PC space. [^dims]|
|`estimated_mean`|Vector with estimated means for each feature.|
|`mnts`|MNTS mapped into PC space with feature filter applied.|

There will also be a log file called `pc_log`.

[^dims]: Columns correspond to components, rows to features.
