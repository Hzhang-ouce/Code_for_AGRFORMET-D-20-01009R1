## Files introduction
The files in `.xls` format in the folder `example_data` are the example data. 
The files in `.mat` format in the folder `mat` are the processed example data.
The files in `.xlsx` format in the folder `xls` are the files saving the model summary and parameters.
The files in `.m` format in the folder `m_file` are the MATLAB program files used in the study.

The users only need to set the paths according to the following `Path setting` and run `xls2mat.m` and `main. m` in turn to finish data preprocessing and curve fitting.



## Paths setting
Please set `LoadInDataPath` on Line 11 of the file `xls2mat.m` to the folder `example_data`. (Path 1)
Please set `MatOutPutDataPath` on Line 12 of the file `xls2mat.m` to the path where you want to save the `.mat` format files. (Path 2)
Please set `MatOutPutDataPath` on Line 11 of the file `Main.m` to Path 2.
Please set `ExcelOutPutDataPath` on Line 12 of the file `Main.m` to the path where you want to save the `.xlsx` format files which saves the model summary and parameters (Path 3).