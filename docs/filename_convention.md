# Require Filename Conventions   

MONA assumes that the files contained within the directories it is fed obey these naming conventions:

**Example file names:**   
`CSM001_control_opto_1_20190101_option.plx`   
`CSM030_Ex_Week01_20200811_GRFtilt.plx`   
`CSM031_NoEx_Week02_20200817_Tilt.plx`   

**Representing:**    
`EXA001_ExperimentalGroup_ExperimentalCondition_#_YYYYMMDD_option.ext`   

Where:
- `EXA` is the study ID.
- `001` is the animal ID.
- `ExperimentalGroup` could be control, sham, etc.
- `ExperimentalCondition` could be OpenLoop, Opt, etc.
- `#` refers to the recording session.
- `YYYYMMDD` is the recording date.
- `Option` refers to any additional notes.
- `Ext` is the file extension.
