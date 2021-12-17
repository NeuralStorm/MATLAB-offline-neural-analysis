All files that are being ran through the codebase have an assumed filename convention. Currently that convention looks like this:

EXA = Study ID; 001 = Animal ID; ExperimentalGroup = control, sham, etc; ExperimentalCondition = OpenLoop, Opt, etc.; # = recording session; YYYYMMDD = date; option = additional desired info; ext = file extension

EXA001_ExperimentalGroup_ExperimentalCondition_#_YYYYMMDD_option.ext

ex: EXA001_control_opto_1_20190101_option.ext and their type requirements are the following: str_str_str_int_int_string.plx

NOTE: Recording session type requirement will change from int to string in future versions.