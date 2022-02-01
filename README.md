# Matlab Offline Neural Analysis (MONA)

## Important Note

The Moxon Neurorobotics Laboratory maintains a [Codebase Master Document](https://ucdavis.box.com/s/icsjygmi2bkcv1275xskigibiewahd3p) that introduces users to key concepts that are helpful for properly understanding, installing, and using this program. It is highly recommended that new users and lab members review the document in its entirety before proceeding.


## Content Guide

- **[Purpose](#Purpose)**: Explanation of program purpose, its required inputs, and its expected outputs.
- **[Pipeline](#Pipeline)**: Ordered list of what the program does when.
- **[Terminology](#Terminology)**: Index of key terms commonly used in MONA documentation.
- **[Usage Guide](#Usage-Guide)**: How to use the program.
    - **[Installation](#Installation)**: How to install the program.
    - **[Dependencies](#Dependencies)**: Dependencies required to run the MONA pipeline.
    - **[Labels File](#Labels-File)**: Explanation of the labels file and its contents.
    - **[Config File](#Config-File)**: Explanation of the config file and its contents.
    - **[Running the Program](#Running-Program)**: Breakdown of how the program is run.

## <a name="Purpose">Purpose</a>

This program takes raw neural data, parses it, runs a number of analyses, and visualizes aspects of the processed data. MONA is intentionally modular and most of its functions and plots are entirely optional, and it is **strongly** recommended that users read this documentation as well as any linked readmes in their entirety so as to understand how to prepare a directory for use with MONA, how to opt in and out of specific options, and what purpose each main function serves.

MONA accepts the following types of files, **which must be provided by the user**:
|Terminology          |Contents                                                |Accepted File Formats|
|---------------------|--------------------------------------------------------|:---------------------:|
|Raw neural data|Contains the raw data to be converted and analyzed.                  |`.plx`/`.pl2`/`.rhd`/`.rhs` [^dataform]     |
|Labels file          |Contains channel mapping information.                   |`.csv`    |
|Config file          |Contains modifiable parameters and arguments.           |`.csv`    |

[^dataform]: Please note that spike data will generally use the `.plx`/`.pl2` formats, while continuous data will generally use the `.rhd`/`.rhs` formats.

Once properly run, complete pipeline will create a number of directories and output files, indexed [here](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/file_layout.md).

[^rrm]: Within the PSTH format files, users can find relative response matrices for the various regions included in a recording, event information featuring the timestamps and trial indices of different event types, channel information featuring the names assigned to each channel and some of the configurable parameters associated with each of them (e.g. was a given channel configured to be included in any analyses?), and some further mapping information.

## <a name="Pipeline">Pipeline</a>

The program is divided into a number of modular components that each handle a different part of the greater pipeline, and which can each be run either on their own or through a batch process.

![MONA Flowchart](https://imgur.com/ni2EvR3.png)

## <a name="Terminology">Terminology</a>

We generally seek to describe selections of data using precise words. While there may not always be a perfect word that can capture all the possibilities of what a user might encounter throughout the course of using MONA, you can find an index of common terms whose use and meaning has been standardized for the purposes of this documentation [here](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/terminology.md).

## <a name="Usage-Guide">Usage Guide</a>

### <a name="Installation">Installation</a>

To install this program, follow the steps outlined in the Git tutorial within the [Codebase Master Document](https://ucdavis.box.com/s/icsjygmi2bkcv1275xskigibiewahd3p).

### <a name="Dependencies">Dependencies</a>

In order to function properly, MONA requires that users install the following prerequisites:

|Dependencies|Description|Link|
|:-|:-|:-
|Statistics and Machine Learning Toolbox|Analyzes and models data.|[Mathworks Store](https://www.mathworks.com/products/statistics.html).
|Curve Fitting Toolbox|Fits curves and surfaces to data.|[Mathworks Store](https://www.mathworks.com/products/curvefitting.html).
|Scrollsubplot|Extends subplot to infinite canvas.|[Matlab Central](https://www.mathworks.com/matlabcentral/fileexchange/7730-scrollsubplot).
|Parallel Computing Toolbox|Enables parallel computations on multi-core PCs.|[Mathworks Store](https://www.mathworks.com/products/parallel-computing.html).

### <a name="Labels-File">Labels File</a>

As electrodes may be placed in different locations within the brain, label files are needed to allow end users to communicate some organization of these electrodes and the different groups they comprise to the program. Each label file must specify _**all**_ of the channels that are expected to appear in the raw neural data. For more on labels files and how they should be formatted, click [here](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/labels_file.md).

### <a name="Config File">Config File</a>

The configuration files define a number of parameters that control whichever main function (e.g. `parser_main.m`/`recfield_main.m`) is being run. Unlike the labels files, of which only one is necessary for each subject, the program requires a different config file for each such function, generally named `conf_<func>.m`, e.g. `conf_parser.csv`/`conf_recfield.csv`. For details on what the configuration file of each function should look like, click on the appropriate markdown (`.md`) file here:

- [parsing_main.md](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/parsing_main.md): Parses raw neural data into browseable `.mat` files.
- [recfield_main.md](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/recfield_main.md): Perform receptive field analysis, optionally cluster analysis & plotting of PSTH and recfield metrics.
- [bootstrap_classifier_main.md](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/bootstrap_classifier_main.md): Runs a PSTH classifier on parsed neural data and optionally bootstraps it.
- [dropping_classifier_main.md](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/dropping_classifier_main.md): Drops select channels to test for impact of channel population on classification performance. 
- [window_classify_main.md](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/window_classify_main.md): Adds bins to response start or end to test for optimal classification window.
- [shannon_info_main.md](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/shannon_info_main.md): Calculates spike timing & spike count entropy and mutual information.
- [spike_extraction_main.md](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/spike_extraction_main.md): Extracts spikes from continuous neural data.
- [sep_main.md](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/sep_main.md): Analyzes sensory evoked potentials in parsed continuous data.
- [pca_main.md](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/pca_main.md): Performs principal component analysis, optionally filters principal components.
- [ica_main.md](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/ica_main.md): Performs independent component analysis.

### <a name="running-program">Running the Program</a>

The Matlab Offline Neural Analysis program has a number of requirements regarding the file layout of the target directory, and these must be followed if the program is to run successfully. The layout should consist of a top level project folder containing the labels file for each subject and the configuration file for each main function. The project folder also contains a folder labeled `raw`, which should contain all of the directories listed in the configuration file. These should generally be named after individual subjects. For an example and further information regarding the layout, click [here](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/file_layout.md).

There is a similar requirement for the naming conventions of each of the files in the `raw` directory. File names should consist of the study ID, the animal ID, the experimental group, the experimental condition, the recording session, the date, and key notes. More on that [here](https://github.com/NeuralStorm/MATLAB-offline-neural-analysis/blob/kevin-docs/docs/filename_convention.md).

Once the project directory is properly set up, calling `parser_main` in Matlab will open a file window. After the project directory is defined, the parser will generate new directories containing the raw data parsed into `.mat` files. From there, the process can be repeated with any other main function, each of which will either create its own directory, populate the graph directory, or both.

|**Warning!**|
|:-|
|If you re-run the program after previously generating files, MONA will **overwrite** existing files in the working directory. To avoid this, save your output after using any main function.
