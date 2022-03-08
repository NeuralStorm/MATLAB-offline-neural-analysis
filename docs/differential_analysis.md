# Purpose
Often the choice of parameters is arbitrary and needs to be validated in some fashion. The classic example is choosing a bin size for the psth classifier where you have to test several bin sizes and see how the performance changes. You may also want to compare how information changes with classification of specific channel groups or using all channel groups. In this document, we will cover how to approach changing parameters.

# Step 1

## Running with different bin sizes, channel selection, etc
Start by following the [analysis instructions](./analysis_instructions.md) using the initial config and label files.

This should produce a file structure like the following (sub directory contents ommited)
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
│  ├── ...
├── parsed_spike
│  ├── ...
├── pca_psth
│  ├── ...
├── psth
│  ├── ...
├── raw
│  ├── ...
├── res_pca_chan_eucl_classifier.csv
├── res_pca_pop_eucl_classifier.csv
├── res_psth_chan_eucl_classifier.csv
├── res_psth_cluster_analysis.csv
├── res_psth_pop_eucl_classifier.csv
└── res_psth_receptive_field.csv
```

# Step 2

* Rename your label, result, config and data files/directories so they won't conflict with the next analysis.  
* Keep copies of config and labels files.

Note: Keeping copies of the data or result files/directories can result in appended data or partially overwritten folders where it is unclear what data was generated with which parameters.

Your file structure should now look like the following (sub directory contents ommited)
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
├── conf_bootstrap_classifier_run1.csv
├── conf_parser_run1.csv
├── conf_pca_run1.csv
├── conf_recfield_run1.csv
├── labels_BPS153_run1.csv
├── labels_BPS157_run1.csv
├── labels_BPS158_run1.csv
├── labels_BPS159_run1.csv
├── labels_BPS160_run1.csv
├── labels_BPS161_run1.csv
├── labels_LC02_run1.csv
├── mnts_run1
│  ├── ...
├── parsed_spike
│  ├── ...
├── pca_psth_run1
│  ├── ...
├── psth_run1
│  ├── ...
├── raw
│  ├── ...
├── res_pca_chan_eucl_classifier_run1.csv
├── res_pca_pop_eucl_classifier_run1.csv
├── res_psth_chan_eucl_classifier_run1.csv
├── res_psth_cluster_analysis_run1.csv
├── res_psth_pop_eucl_classifier_run1.csv
└── res_psth_receptive_field_run1.csv
```

# Step 3

Follow the [analysis instructions](./analysis_instructions.md) using the updated labels and config files.

Your file structure should now look like the following (sub directory contents ommited)
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
├── conf_bootstrap_classifier_run1.csv
├── conf_parser_run1.csv
├── conf_pca_run1.csv
├── conf_recfield_run1.csv
├── labels_BPS153_run1.csv
├── labels_BPS157_run1.csv
├── labels_BPS158_run1.csv
├── labels_BPS159_run1.csv
├── labels_BPS160_run1.csv
├── labels_BPS161_run1.csv
├── labels_LC02_run1.csv
├── mnts
│  ├── ...
├── parsed_spike
│  ├── ...
├── pca_psth
│  ├── ...
├── psth
│  ├── ...
├── raw
│  ├── ...
├── mnts_run1
│  ├── ...
├── parsed_spike
│  ├── ...
├── pca_psth_run1
│  ├── ...
├── psth_run1
│  ├── ...
├── raw
│  ├── ...
├── res_pca_chan_eucl_classifier.csv
├── res_pca_pop_eucl_classifier.csv
├── res_psth_chan_eucl_classifier.csv
├── res_psth_cluster_analysis.csv
├── res_psth_pop_eucl_classifier.csv
└── res_psth_receptive_field.csv
├── res_pca_chan_eucl_classifier_run1.csv
├── res_pca_pop_eucl_classifier_run1.csv
├── res_psth_chan_eucl_classifier_run1.csv
├── res_psth_cluster_analysis_run1.csv
├── res_psth_pop_eucl_classifier_run1.csv
└── res_psth_receptive_field_run1.csv
```

# Step 4

You can now compare the run1 results with the new results. You can repeat this process starting at Step 2 for each parameter set you want to perform the analysis with.

For example comparing the bin sizes 5ms, 10ms, 20ms and 50ms your file system may look like the following

```
Spike Codebase Example
├── conf_bootstrap_classifier_5ms.csv
├── conf_bootstrap_classifier_10ms.csv
├── conf_bootstrap_classifier_20ms.csv
├── conf_bootstrap_classifier_50ms.csv
├── conf_pca_5ms.csv
├── conf_pca_10ms.csv
├── conf_pca_20ms.csv
├── conf_pca_50ms.csv
├── conf_recfield_5ms.csv
├── conf_recfield_10ms.csv
├── conf_recfield_20ms.csv
├── conf_recfield_50ms.csv
├── labels_BPS153_5ms.csv
├── labels_BPS153_10ms.csv
├── labels_BPS153_20ms.csv
├── labels_BPS153_50ms.csv
├── labels_BPS157_5ms.csv
├── labels_BPS157_10ms.csv
├── labels_BPS157_20ms.csv
├── labels_BPS157_50ms.csv
├── labels_BPS158_5ms.csv
├── labels_BPS158_10ms.csv
├── labels_BPS158_20ms.csv
├── labels_BPS158_50ms.csv
├── labels_BPS159_5ms.csv
├── labels_BPS159_10ms.csv
├── labels_BPS159_20ms.csv
├── labels_BPS159_50ms.csv
├── labels_BPS160_5ms.csv
├── labels_BPS160_10ms.csv
├── labels_BPS160_20ms.csv
├── labels_BPS160_50ms.csv
├── labels_BPS161_5ms.csv
├── labels_BPS161_10ms.csv
├── labels_BPS161_20ms.csv
├── labels_BPS161_50ms.csv
├── labels_LC02_5ms.csv
├── labels_LC02_10ms.csv
├── labels_LC02_20ms.csv
├── labels_LC02_50ms.csv
├── mnts_5ms
│  ├── ...
├── mnts_10ms
│  ├── ...
├── mnts_20ms
│  ├── ...
├── mnts_50ms
│  ├── ...
├── parsed_spike
│  ├── ...
├── pca_psth_5ms
│  ├── ...
├── pca_psth_10ms
│  ├── ...
├── pca_psth_20ms
│  ├── ...
├── pca_psth_50ms
│  ├── ...
├── psth_5ms
│  ├── ...
├── psth_10ms
│  ├── ...
├── psth_20ms
│  ├── ...
├── psth_50ms
│  ├── ...
├── raw
│  ├── ...
├── res_pca_chan_eucl_classifier_5ms.csv
├── res_pca_chan_eucl_classifier_10ms.csv
├── res_pca_chan_eucl_classifier_20ms.csv
├── res_pca_chan_eucl_classifier_50ms.csv
├── res_pca_pop_eucl_classifier_5ms.csv
├── res_pca_pop_eucl_classifier_10ms.csv
├── res_pca_pop_eucl_classifier_20ms.csv
├── res_pca_pop_eucl_classifier_50ms.csv
├── res_psth_chan_eucl_classifier_5ms.csv
├── res_psth_chan_eucl_classifier_10ms.csv
├── res_psth_chan_eucl_classifier_20ms.csv
├── res_psth_chan_eucl_classifier_50ms.csv
├── res_psth_cluster_analysis_5ms.csv
├── res_psth_cluster_analysis_10ms.csv
├── res_psth_cluster_analysis_20ms.csv
├── res_psth_cluster_analysis_50ms.csv
├── res_psth_pop_eucl_classifier_5ms.csv
├── res_psth_pop_eucl_classifier_10ms.csv
├── res_psth_pop_eucl_classifier_20ms.csv
├── res_psth_pop_eucl_classifier_50ms.csv
├── res_psth_receptive_field_5ms.csv
├── res_psth_receptive_field_10ms.csv
├── res_psth_receptive_field_20ms.csv
└── res_psth_receptive_field_50ms.csv
```
