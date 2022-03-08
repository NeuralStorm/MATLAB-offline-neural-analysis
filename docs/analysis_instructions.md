# Anlysis Goals
1. Run recfield to visualize channels and verify channel groups
2. Run psth classifier
3. Run pca psth classifier

## Running parser_main
See [the docs for parser main](./parsing_main.md) for more details on setting up your data to run through the data. Note that if you are using premade label files, you should verify that the selected channels match up with your expectations of what channels are being used.
1. Write `parser_config.csv`
2. Ensure labels files are set correctly
3. Run `parser_main` since we are starting to parse raw files
    1. Note how after `parser_main` is ran, there is a new directory called `parsed_spike` and/or `parsed_continuous` (depending on your config) in the project directory
    2. Note that the `parser_main` will fail to run for a subject if the labels file does not list all the channels found in the recording session
    3. Note that if you run this twice, it will overwrite any files that already exist on the same path

## Running recfield_main
See [the docs for recfield main](./recfield_main.md) for more details on setting up your analysis for recfield.
1. Write `conf_recfield.csv`
2. Run `recfield_main`
    1. Note that if the recfield output files already have results for a given row with the same parameters the row will not be written again. If the code or data files have been updated you may need to delete the recfield output files to get correct results.
    2. Note that if you run this twice, it will overwrite any files that already exist on the same path with one containing a combination of new rows and old rows.
    3. Note that `create_psth` must be set to true for psths to be created at this step.
    4. If you want to create graphs of the psths set `make_psth_graphs` to true.
    5. Optionally, set `plot_rf` if you want to see the results of the receptive field analysis plotted.

## Running bootstrapper_main
See [the docs for bootstrapper main](./bootstrap_classifier_main.md) for more details on setting up your analysis.
1. Write `conf_bootstrap_classifier.csv`
2. Run `bootstrap_classifier_main`
    1. Note that the psth has been created by recfield, if you are running mains in a different order or different subjects and the psth has not been created already `create_psth` must be set to true. If it is set to true existing psths will be overwritten.
    2. Note: if you decided to change your window or bin size after receptive field analysis and did not change the names of directories, this could lead to an ambigious file structure where you have mixed parameters stored in the same location
    3. `psth_type` must be set to "`psth`" or classification will be attempted on the incorrect files.

## Running pca_main
See [the docs for pca main](./pca_main.md) for details on setting up your analysis.
1. Write conf_pca.csv
2. Run `pca_main`
    1. `create_mnts` must be true to create the mnts formatted input for pca
    2. `convert_mnts_psth` must be true to output the correctly formatted .mat files to work with classification
3. Remember to look at the mnts generated as input to pca.

## Running bootstrapper_main on PCs
1. Modify conf_bootstrap_classifier.csv changing `psth_type` to "`pca`"
2. Run `bootstrap_classifier_main`

## Creating PCA Graphs
1. Modify `conf_recfield.csv` changing `psth_type` to "`pca`"
    1. You must specify a baseline window regardless of if it makes sense.
    2. Make sure `make_psth_graphs` is set to true
    3. Optionally, set `plot_rf` to true if you want to see the results of the receptive field analysis plotted.
2. Run `recfield_main`

An example of the output file structure from this process, except creating graphs of the pca output, is provided below. Note that the pca graphs would be stored under `pca_psth/psth_graphs` if they were generated.
```
Spike Codebase Example
├── conf_bootstrap_classifier.csv
├── conf_parser.csv
├── conf_pca.csv
├── conf_recfield.csv
├── labels_BPS153.csv
├── labels_BPS157.csv
├── labels_BPS158.csv
├── labels_BPS159.csv
├── labels_BPS160.csv
├── labels_BPS161.csv
├── labels_LC02.csv
├── mnts
│  ├── data
│  │  ├── BPS153
│  │  │  ├── mnts_format_BPS.153.normal.1.20180514.mat
│  │  │  ├── mnts_format_BPS.153.normal.2.20180514.mat
│  │  │  └── mnts_format_BPS.153.normal.3.20180514.mat
│  │  ├── BPS157
│  │  │  ├── mnts_format_BPS.157.normal.1.20180518.mat
│  │  │  ├── mnts_format_BPS.157.normal.2.20180518.mat
│  │  │  └── mnts_format_BPS.157.normal.3.20180518.mat
│  │  ├── BPS158
│  │  │  └── mnts_format_BPS.158.normal.3.20180521.mat
│  │  ├── BPS159
│  │  │  ├── mnts_format_BPS.159.normal.1.20180522.mat
│  │  │  ├── mnts_format_BPS.159.normal.2.20180522.mat
│  │  │  └── mnts_format_BPS.159.normal.3.20180522.mat
│  │  ├── BPS160
│  │  │  ├── mnts_format_BPS.160.normal.1.20180524.mat
│  │  │  ├── mnts_format_BPS.160.normal.2.20180524.mat
│  │  │  └── mnts_format_BPS.160.normal.3.20180524.mat
│  │  ├── BPS161
│  │  │  ├── mnts_format_BPS.161.normal.1.20180525.mat
│  │  │  ├── mnts_format_BPS.161.normal.2.20180525.mat
│  │  │  ├── mnts_format_BPS.161.normal.3.20180525.mat
│  │  │  ├── mnts_format_BPS.161.normal.4.20180525.mat
│  │  │  ├── mnts_format_BPS.161.normal.5.20180525.mat
│  │  │  └── mnts_format_BPS.161.normal.6.20180525.mat
│  │  ├── LC02
│  │  │  └── mnts_format_LC.02.OpenLoop.Day0c.112015.mat
│  │  └── mnts_log.csv
│  └── pca
│     ├── BPS153
│     │  ├── pc_analysis_BPS.153.normal.1.20180514.mat
│     │  ├── pc_analysis_BPS.153.normal.2.20180514.mat
│     │  └── pc_analysis_BPS.153.normal.3.20180514.mat
│     ├── BPS157
│     │  ├── pc_analysis_BPS.157.normal.1.20180518.mat
│     │  ├── pc_analysis_BPS.157.normal.2.20180518.mat
│     │  └── pc_analysis_BPS.157.normal.3.20180518.mat
│     ├── BPS158
│     │  └── pc_analysis_BPS.158.normal.3.20180521.mat
│     ├── BPS159
│     │  ├── pc_analysis_BPS.159.normal.1.20180522.mat
│     │  ├── pc_analysis_BPS.159.normal.2.20180522.mat
│     │  └── pc_analysis_BPS.159.normal.3.20180522.mat
│     ├── BPS160
│     │  ├── pc_analysis_BPS.160.normal.1.20180524.mat
│     │  ├── pc_analysis_BPS.160.normal.2.20180524.mat
│     │  └── pc_analysis_BPS.160.normal.3.20180524.mat
│     ├── BPS161
│     │  ├── pc_analysis_BPS.161.normal.1.20180525.mat
│     │  ├── pc_analysis_BPS.161.normal.2.20180525.mat
│     │  ├── pc_analysis_BPS.161.normal.3.20180525.mat
│     │  ├── pc_analysis_BPS.161.normal.4.20180525.mat
│     │  ├── pc_analysis_BPS.161.normal.5.20180525.mat
│     │  └── pc_analysis_BPS.161.normal.6.20180525.mat
│     ├── LC02
│     │  └── pc_analysis_LC.02.OpenLoop.Day0c.112015.mat
│     └── pca_log.csv
├── other_confs
├── parsed_spike
│  ├── BPS153
│  │  ├── BPS.153.normal.1.20180514.mat
│  │  ├── BPS.153.normal.2.20180514.mat
│  │  └── BPS.153.normal.3.20180514.mat
│  ├── BPS157
│  │  ├── BPS.157.normal.1.20180518.mat
│  │  ├── BPS.157.normal.2.20180518.mat
│  │  └── BPS.157.normal.3.20180518.mat
│  ├── BPS158
│  │  └── BPS.158.normal.3.20180521.mat
│  ├── BPS159
│  │  ├── BPS.159.normal.1.20180522.mat
│  │  ├── BPS.159.normal.2.20180522.mat
│  │  └── BPS.159.normal.3.20180522.mat
│  ├── BPS160
│  │  ├── BPS.160.normal.1.20180524.mat
│  │  ├── BPS.160.normal.2.20180524.mat
│  │  └── BPS.160.normal.3.20180524.mat
│  ├── BPS161
│  │  ├── BPS.161.normal.1.20180525.mat
│  │  ├── BPS.161.normal.2.20180525.mat
│  │  ├── BPS.161.normal.3.20180525.mat
│  │  ├── BPS.161.normal.4.20180525.mat
│  │  ├── BPS.161.normal.5.20180525.mat
│  │  └── BPS.161.normal.6.20180525.mat
│  ├── LC02
│  │  └── LC.02.OpenLoop.Day0c.112015.mat
│  └── parser_log.csv
├── pca_psth
│  ├── classifier
│  │  ├── BPS153
│  │  │  ├── psth_classifier_BPS.153.normal.1.20180514.mat
│  │  │  ├── psth_classifier_BPS.153.normal.2.20180514.mat
│  │  │  └── psth_classifier_BPS.153.normal.3.20180514.mat
│  │  ├── BPS157
│  │  │  ├── psth_classifier_BPS.157.normal.1.20180518.mat
│  │  │  ├── psth_classifier_BPS.157.normal.2.20180518.mat
│  │  │  └── psth_classifier_BPS.157.normal.3.20180518.mat
│  │  ├── BPS158
│  │  │  └── psth_classifier_BPS.158.normal.3.20180521.mat
│  │  ├── BPS159
│  │  │  ├── psth_classifier_BPS.159.normal.1.20180522.mat
│  │  │  ├── psth_classifier_BPS.159.normal.2.20180522.mat
│  │  │  └── psth_classifier_BPS.159.normal.3.20180522.mat
│  │  ├── BPS160
│  │  │  ├── psth_classifier_BPS.160.normal.1.20180524.mat
│  │  │  ├── psth_classifier_BPS.160.normal.2.20180524.mat
│  │  │  └── psth_classifier_BPS.160.normal.3.20180524.mat
│  │  ├── BPS161
│  │  │  ├── psth_classifier_BPS.161.normal.1.20180525.mat
│  │  │  ├── psth_classifier_BPS.161.normal.2.20180525.mat
│  │  │  ├── psth_classifier_BPS.161.normal.3.20180525.mat
│  │  │  ├── psth_classifier_BPS.161.normal.4.20180525.mat
│  │  │  ├── psth_classifier_BPS.161.normal.5.20180525.mat
│  │  │  └── psth_classifier_BPS.161.normal.6.20180525.mat
│  │  ├── classifier_log.csv
│  │  └── LC02
│  │     └── psth_classifier_LC.02.OpenLoop.Day0c.112015.mat
│  ├── data
│  │  ├── BPS153
│  │  │  ├── pca_format_BPS.153.normal.1.20180514.mat
│  │  │  ├── pca_format_BPS.153.normal.2.20180514.mat
│  │  │  └── pca_format_BPS.153.normal.3.20180514.mat
│  │  ├── BPS157
│  │  │  ├── pca_format_BPS.157.normal.1.20180518.mat
│  │  │  ├── pca_format_BPS.157.normal.2.20180518.mat
│  │  │  └── pca_format_BPS.157.normal.3.20180518.mat
│  │  ├── BPS158
│  │  │  └── pca_format_BPS.158.normal.3.20180521.mat
│  │  ├── BPS159
│  │  │  ├── pca_format_BPS.159.normal.1.20180522.mat
│  │  │  ├── pca_format_BPS.159.normal.2.20180522.mat
│  │  │  └── pca_format_BPS.159.normal.3.20180522.mat
│  │  ├── BPS160
│  │  │  ├── pca_format_BPS.160.normal.1.20180524.mat
│  │  │  ├── pca_format_BPS.160.normal.2.20180524.mat
│  │  │  └── pca_format_BPS.160.normal.3.20180524.mat
│  │  ├── BPS161
│  │  │  ├── pca_format_BPS.161.normal.1.20180525.mat
│  │  │  ├── pca_format_BPS.161.normal.2.20180525.mat
│  │  │  ├── pca_format_BPS.161.normal.3.20180525.mat
│  │  │  ├── pca_format_BPS.161.normal.4.20180525.mat
│  │  │  ├── pca_format_BPS.161.normal.5.20180525.mat
│  │  │  └── pca_format_BPS.161.normal.6.20180525.mat
│  │  └── LC02
│  │     └── pca_format_LC.02.OpenLoop.Day0c.112015.mat
│  └── pca_psth_log.csv
├── psth
│  ├── classifier
│  │  ├── BPS153
│  │  │  ├── psth_classifier_BPS.153.normal.1.20180514.mat
│  │  │  ├── psth_classifier_BPS.153.normal.2.20180514.mat
│  │  │  └── psth_classifier_BPS.153.normal.3.20180514.mat
│  │  ├── BPS157
│  │  │  ├── psth_classifier_BPS.157.normal.1.20180518.mat
│  │  │  ├── psth_classifier_BPS.157.normal.2.20180518.mat
│  │  │  └── psth_classifier_BPS.157.normal.3.20180518.mat
│  │  ├── BPS158
│  │  │  └── psth_classifier_BPS.158.normal.3.20180521.mat
│  │  ├── BPS159
│  │  │  ├── psth_classifier_BPS.159.normal.1.20180522.mat
│  │  │  ├── psth_classifier_BPS.159.normal.2.20180522.mat
│  │  │  └── psth_classifier_BPS.159.normal.3.20180522.mat
│  │  ├── BPS160
│  │  │  ├── psth_classifier_BPS.160.normal.1.20180524.mat
│  │  │  ├── psth_classifier_BPS.160.normal.2.20180524.mat
│  │  │  └── psth_classifier_BPS.160.normal.3.20180524.mat
│  │  ├── BPS161
│  │  │  ├── psth_classifier_BPS.161.normal.1.20180525.mat
│  │  │  ├── psth_classifier_BPS.161.normal.2.20180525.mat
│  │  │  ├── psth_classifier_BPS.161.normal.3.20180525.mat
│  │  │  ├── psth_classifier_BPS.161.normal.4.20180525.mat
│  │  │  ├── psth_classifier_BPS.161.normal.5.20180525.mat
│  │  │  └── psth_classifier_BPS.161.normal.6.20180525.mat
│  │  ├── classifier_log.csv
│  │  └── LC02
│  │     └── psth_classifier_LC.02.OpenLoop.Day0c.112015.mat
│  ├── data
│  │  ├── BPS153
│  │  │  ├── PSTH_format_BPS.153.normal.1.20180514.mat
│  │  │  ├── PSTH_format_BPS.153.normal.2.20180514.mat
│  │  │  └── PSTH_format_BPS.153.normal.3.20180514.mat
│  │  ├── BPS157
│  │  │  ├── PSTH_format_BPS.157.normal.1.20180518.mat
│  │  │  ├── PSTH_format_BPS.157.normal.2.20180518.mat
│  │  │  └── PSTH_format_BPS.157.normal.3.20180518.mat
│  │  ├── BPS158
│  │  │  └── PSTH_format_BPS.158.normal.3.20180521.mat
│  │  ├── BPS159
│  │  │  ├── PSTH_format_BPS.159.normal.1.20180522.mat
│  │  │  ├── PSTH_format_BPS.159.normal.2.20180522.mat
│  │  │  └── PSTH_format_BPS.159.normal.3.20180522.mat
│  │  ├── BPS160
│  │  │  ├── PSTH_format_BPS.160.normal.1.20180524.mat
│  │  │  ├── PSTH_format_BPS.160.normal.2.20180524.mat
│  │  │  └── PSTH_format_BPS.160.normal.3.20180524.mat
│  │  ├── BPS161
│  │  │  ├── PSTH_format_BPS.161.normal.1.20180525.mat
│  │  │  ├── PSTH_format_BPS.161.normal.2.20180525.mat
│  │  │  ├── PSTH_format_BPS.161.normal.3.20180525.mat
│  │  │  ├── PSTH_format_BPS.161.normal.4.20180525.mat
│  │  │  ├── PSTH_format_BPS.161.normal.5.20180525.mat
│  │  │  └── PSTH_format_BPS.161.normal.6.20180525.mat
│  │  ├── LC02
│  │  │  └── PSTH_format_LC.02.OpenLoop.Day0c.112015.mat
│  │  └── psth_log.csv
│  ├── psth_graphs
│  │  ├── BPS153
│  │  │  ├── BPS.153.normal.1.20180514_LAYER4_event_2.fig
│  │  │  ├── BPS.153.normal.1.20180514_LAYER4_event_3.fig
│  │  │  ├── BPS.153.normal.1.20180514_LAYER5_event_2.fig
│  │  │  ├── BPS.153.normal.1.20180514_LAYER5_event_3.fig
│  │  │  ├── BPS.153.normal.1.20180514_LAYER23_event_2.fig
│  │  │  ├── BPS.153.normal.1.20180514_LAYER23_event_3.fig
│  │  │  ├── BPS.153.normal.2.20180514_LAYER4_event_2.fig
│  │  │  ├── BPS.153.normal.2.20180514_LAYER4_event_3.fig
│  │  │  ├── BPS.153.normal.2.20180514_LAYER5_event_2.fig
│  │  │  ├── BPS.153.normal.2.20180514_LAYER5_event_3.fig
│  │  │  ├── BPS.153.normal.2.20180514_LAYER23_event_2.fig
│  │  │  ├── BPS.153.normal.2.20180514_LAYER23_event_3.fig
│  │  │  ├── BPS.153.normal.3.20180514_LAYER4_event_2.fig
│  │  │  ├── BPS.153.normal.3.20180514_LAYER4_event_3.fig
│  │  │  ├── BPS.153.normal.3.20180514_LAYER5_event_2.fig
│  │  │  ├── BPS.153.normal.3.20180514_LAYER5_event_3.fig
│  │  │  ├── BPS.153.normal.3.20180514_LAYER23_event_2.fig
│  │  │  └── BPS.153.normal.3.20180514_LAYER23_event_3.fig
│  │  ├── BPS157
│  │  │  ├── BPS.157.normal.1.20180518_LAYER4_event_2.fig
│  │  │  ├── BPS.157.normal.1.20180518_LAYER4_event_3.fig
│  │  │  ├── BPS.157.normal.1.20180518_LAYER5_event_2.fig
│  │  │  ├── BPS.157.normal.1.20180518_LAYER5_event_3.fig
│  │  │  ├── BPS.157.normal.1.20180518_LAYER23_event_2.fig
│  │  │  ├── BPS.157.normal.1.20180518_LAYER23_event_3.fig
│  │  │  ├── BPS.157.normal.2.20180518_LAYER4_event_2.fig
│  │  │  ├── BPS.157.normal.2.20180518_LAYER4_event_3.fig
│  │  │  ├── BPS.157.normal.2.20180518_LAYER5_event_2.fig
│  │  │  ├── BPS.157.normal.2.20180518_LAYER5_event_3.fig
│  │  │  ├── BPS.157.normal.2.20180518_LAYER23_event_2.fig
│  │  │  ├── BPS.157.normal.2.20180518_LAYER23_event_3.fig
│  │  │  ├── BPS.157.normal.3.20180518_LAYER4_event_2.fig
│  │  │  ├── BPS.157.normal.3.20180518_LAYER4_event_3.fig
│  │  │  ├── BPS.157.normal.3.20180518_LAYER5_event_2.fig
│  │  │  ├── BPS.157.normal.3.20180518_LAYER5_event_3.fig
│  │  │  ├── BPS.157.normal.3.20180518_LAYER23_event_2.fig
│  │  │  └── BPS.157.normal.3.20180518_LAYER23_event_3.fig
│  │  ├── BPS158
│  │  │  ├── BPS.158.normal.3.20180521_LAYER4_event_2.fig
│  │  │  ├── BPS.158.normal.3.20180521_LAYER4_event_3.fig
│  │  │  ├── BPS.158.normal.3.20180521_LAYER5_event_2.fig
│  │  │  ├── BPS.158.normal.3.20180521_LAYER5_event_3.fig
│  │  │  ├── BPS.158.normal.3.20180521_LAYER23_event_2.fig
│  │  │  └── BPS.158.normal.3.20180521_LAYER23_event_3.fig
│  │  ├── BPS159
│  │  │  ├── BPS.159.normal.1.20180522_LAYER4_event_2.fig
│  │  │  ├── BPS.159.normal.1.20180522_LAYER4_event_3.fig
│  │  │  ├── BPS.159.normal.1.20180522_LAYER5_event_2.fig
│  │  │  ├── BPS.159.normal.1.20180522_LAYER5_event_3.fig
│  │  │  ├── BPS.159.normal.2.20180522_LAYER4_event_2.fig
│  │  │  ├── BPS.159.normal.2.20180522_LAYER4_event_3.fig
│  │  │  ├── BPS.159.normal.2.20180522_LAYER5_event_2.fig
│  │  │  ├── BPS.159.normal.2.20180522_LAYER5_event_3.fig
│  │  │  ├── BPS.159.normal.2.20180522_LAYER23_event_2.fig
│  │  │  ├── BPS.159.normal.2.20180522_LAYER23_event_3.fig
│  │  │  ├── BPS.159.normal.3.20180522_LAYER4_event_2.fig
│  │  │  ├── BPS.159.normal.3.20180522_LAYER4_event_3.fig
│  │  │  ├── BPS.159.normal.3.20180522_LAYER5_event_2.fig
│  │  │  └── BPS.159.normal.3.20180522_LAYER5_event_3.fig
│  │  ├── BPS160
│  │  │  ├── BPS.160.normal.1.20180524_LAYER4_event_2.fig
│  │  │  ├── BPS.160.normal.1.20180524_LAYER4_event_3.fig
│  │  │  ├── BPS.160.normal.1.20180524_LAYER5_event_2.fig
│  │  │  ├── BPS.160.normal.1.20180524_LAYER5_event_3.fig
│  │  │  ├── BPS.160.normal.1.20180524_LAYER23_event_2.fig
│  │  │  ├── BPS.160.normal.1.20180524_LAYER23_event_3.fig
│  │  │  ├── BPS.160.normal.2.20180524_LAYER4_event_2.fig
│  │  │  ├── BPS.160.normal.2.20180524_LAYER4_event_3.fig
│  │  │  ├── BPS.160.normal.2.20180524_LAYER5_event_2.fig
│  │  │  ├── BPS.160.normal.2.20180524_LAYER5_event_3.fig
│  │  │  ├── BPS.160.normal.2.20180524_LAYER23_event_2.fig
│  │  │  ├── BPS.160.normal.2.20180524_LAYER23_event_3.fig
│  │  │  ├── BPS.160.normal.3.20180524_LAYER4_event_2.fig
│  │  │  ├── BPS.160.normal.3.20180524_LAYER4_event_3.fig
│  │  │  ├── BPS.160.normal.3.20180524_LAYER5_event_2.fig
│  │  │  ├── BPS.160.normal.3.20180524_LAYER5_event_3.fig
│  │  │  ├── BPS.160.normal.3.20180524_LAYER23_event_2.fig
│  │  │  └── BPS.160.normal.3.20180524_LAYER23_event_3.fig
│  │  ├── BPS161
│  │  │  ├── BPS.161.normal.1.20180525_LAYER4_event_2.fig
│  │  │  ├── BPS.161.normal.1.20180525_LAYER4_event_3.fig
│  │  │  ├── BPS.161.normal.1.20180525_LAYER5_event_2.fig
│  │  │  ├── BPS.161.normal.1.20180525_LAYER5_event_3.fig
│  │  │  ├── BPS.161.normal.1.20180525_LAYER23_event_2.fig
│  │  │  ├── BPS.161.normal.1.20180525_LAYER23_event_3.fig
│  │  │  ├── BPS.161.normal.2.20180525_LAYER4_event_2.fig
│  │  │  ├── BPS.161.normal.2.20180525_LAYER4_event_3.fig
│  │  │  ├── BPS.161.normal.2.20180525_LAYER5_event_2.fig
│  │  │  ├── BPS.161.normal.2.20180525_LAYER5_event_3.fig
│  │  │  ├── BPS.161.normal.2.20180525_LAYER23_event_2.fig
│  │  │  ├── BPS.161.normal.2.20180525_LAYER23_event_3.fig
│  │  │  ├── BPS.161.normal.3.20180525_LAYER4_event_2.fig
│  │  │  ├── BPS.161.normal.3.20180525_LAYER4_event_3.fig
│  │  │  ├── BPS.161.normal.3.20180525_LAYER5_event_2.fig
│  │  │  ├── BPS.161.normal.3.20180525_LAYER5_event_3.fig
│  │  │  ├── BPS.161.normal.4.20180525_LAYER4_event_2.fig
│  │  │  ├── BPS.161.normal.4.20180525_LAYER4_event_3.fig
│  │  │  ├── BPS.161.normal.4.20180525_LAYER23_event_2.fig
│  │  │  ├── BPS.161.normal.4.20180525_LAYER23_event_3.fig
│  │  │  ├── BPS.161.normal.5.20180525_LAYER4_event_2.fig
│  │  │  ├── BPS.161.normal.5.20180525_LAYER4_event_3.fig
│  │  │  ├── BPS.161.normal.5.20180525_LAYER5_event_2.fig
│  │  │  ├── BPS.161.normal.5.20180525_LAYER5_event_3.fig
│  │  │  ├── BPS.161.normal.5.20180525_LAYER23_event_2.fig
│  │  │  ├── BPS.161.normal.5.20180525_LAYER23_event_3.fig
│  │  │  ├── BPS.161.normal.6.20180525_LAYER4_event_2.fig
│  │  │  ├── BPS.161.normal.6.20180525_LAYER4_event_3.fig
│  │  │  ├── BPS.161.normal.6.20180525_LAYER5_event_2.fig
│  │  │  ├── BPS.161.normal.6.20180525_LAYER5_event_3.fig
│  │  │  ├── BPS.161.normal.6.20180525_LAYER23_event_2.fig
│  │  │  └── BPS.161.normal.6.20180525_LAYER23_event_3.fig
│  │  ├── LC02
│  │  │  ├── LC.02.OpenLoop.Day0c.112015_Left_event_1.fig
│  │  │  ├── LC.02.OpenLoop.Day0c.112015_Left_event_3.fig
│  │  │  ├── LC.02.OpenLoop.Day0c.112015_Left_event_4.fig
│  │  │  ├── LC.02.OpenLoop.Day0c.112015_Left_event_6.fig
│  │  │  ├── LC.02.OpenLoop.Day0c.112015_Right_event_1.fig
│  │  │  ├── LC.02.OpenLoop.Day0c.112015_Right_event_3.fig
│  │  │  ├── LC.02.OpenLoop.Day0c.112015_Right_event_4.fig
│  │  │  └── LC.02.OpenLoop.Day0c.112015_Right_event_6.fig
│  │  └── psth_graph_log.csv
│  └── recfield
│     ├── BPS153
│     │  ├── rec_field_BPS.153.normal.1.20180514.mat
│     │  ├── rec_field_BPS.153.normal.2.20180514.mat
│     │  └── rec_field_BPS.153.normal.3.20180514.mat
│     ├── BPS157
│     │  ├── rec_field_BPS.157.normal.1.20180518.mat
│     │  ├── rec_field_BPS.157.normal.2.20180518.mat
│     │  └── rec_field_BPS.157.normal.3.20180518.mat
│     ├── BPS158
│     │  └── rec_field_BPS.158.normal.3.20180521.mat
│     ├── BPS159
│     │  ├── rec_field_BPS.159.normal.1.20180522.mat
│     │  ├── rec_field_BPS.159.normal.2.20180522.mat
│     │  └── rec_field_BPS.159.normal.3.20180522.mat
│     ├── BPS160
│     │  ├── rec_field_BPS.160.normal.1.20180524.mat
│     │  ├── rec_field_BPS.160.normal.2.20180524.mat
│     │  └── rec_field_BPS.160.normal.3.20180524.mat
│     ├── BPS161
│     │  ├── rec_field_BPS.161.normal.1.20180525.mat
│     │  ├── rec_field_BPS.161.normal.2.20180525.mat
│     │  ├── rec_field_BPS.161.normal.3.20180525.mat
│     │  ├── rec_field_BPS.161.normal.4.20180525.mat
│     │  ├── rec_field_BPS.161.normal.5.20180525.mat
│     │  └── rec_field_BPS.161.normal.6.20180525.mat
│     ├── LC02
│     │  └── rec_field_LC.02.OpenLoop.Day0c.112015.mat
│     └── rec_field_log.csv
├── raw
│  ├── BPS153
│  │  ├── BPS.153.normal.1.20180514.plx
│  │  ├── BPS.153.normal.2.20180514.plx
│  │  └── BPS.153.normal.3.20180514.plx
│  ├── BPS157
│  │  ├── BPS.157.normal.1.20180518.plx
│  │  ├── BPS.157.normal.2.20180518.plx
│  │  └── BPS.157.normal.3.20180518.plx
│  ├── BPS158
│  │  └── BPS.158.normal.3.20180521.plx
│  ├── BPS159
│  │  ├── BPS.159.normal.1.20180522.plx
│  │  ├── BPS.159.normal.2.20180522.plx
│  │  └── BPS.159.normal.3.20180522.plx
│  ├── BPS160
│  │  ├── BPS.160.normal.1.20180524.plx
│  │  ├── BPS.160.normal.2.20180524.plx
│  │  └── BPS.160.normal.3.20180524.plx
│  ├── BPS161
│  │  ├── BPS.161.normal.1.20180525.plx
│  │  ├── BPS.161.normal.2.20180525.plx
│  │  ├── BPS.161.normal.3.20180525.plx
│  │  ├── BPS.161.normal.4.20180525.plx
│  │  ├── BPS.161.normal.5.20180525.plx
│  │  └── BPS.161.normal.6.20180525.plx
│  ├── BPS170
│  └── LC02
│     └── LC.02.OpenLoop.Day0c.112015.plx
├── res_pca_chan_eucl_classifier.csv
├── res_pca_pop_eucl_classifier.csv
├── res_psth_chan_eucl_classifier.csv
├── res_psth_cluster_analysis.csv
├── res_psth_pop_eucl_classifier.csv
└── res_psth_receptive_field.csv
```
