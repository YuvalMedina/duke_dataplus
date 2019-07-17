import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as pltdates
import datetime as dt
from main_functions import readFile
import csv

nc_eno_temp = readFile("NC_Eno_WaterTemp_C.csv")
nc_eno_DO = readFile("NC_Eno_DO_mgL.csv")
nc_eno_disch = readFile("NC_Eno_Discharge_m3s.csv")

df_st_temp = nc_eno_temp['dateTimeUTC'].loc[nc_eno_temp['dateTimeUTC']=='2016-07-11 11:45:00'].index.values.astype(int)
print(df_st_temp)
df_end_temp = nc_eno_temp['dateTimeUTC'].loc[nc_eno_temp['dateTimeUTC']=='2017-10-20 18:45:00'].index.values.astype(int)
print(df_end_temp[0])
test_temp = nc_eno_temp.iloc[60000:df_end_temp[0]]
test_temp.to_csv('duke_dataplus/' + 'outlier_detect_test_temp' + '.csv')

df_st_out = nc_eno_DO['dateTimeUTC'].loc[nc_eno_DO['dateTimeUTC']=='2017-05-28 11:45:00'].index.values.astype(int)
print(df_st_out)
df_end_out = nc_eno_DO['dateTimeUTC'].loc[nc_eno_DO['dateTimeUTC']=='2017-06-02 18:45:00'].index.values.astype(int)
print(df_end_out)
test_out = nc_eno_DO.iloc[df_st_out[0]:df_end_out[0]]
test_out.to_csv('Dirty Data Log/' + 'Outliers_DO' + '.csv')

df_st_out = nc_eno_DO['dateTimeUTC'].loc[nc_eno_DO['dateTimeUTC']=='2017-05-28 11:45:00'].index.values.astype(int)
print(df_st_out)
df_end_out = nc_eno_DO['dateTimeUTC'].loc[nc_eno_DO['dateTimeUTC']=='2017-06-02 18:45:00'].index.values.astype(int)
print(df_end_out)
test_out = nc_eno_DO.iloc[df_st_out[0]:df_end_out[0]]
test_out.to_csv('Dirty Data Log/' + 'Outliers_DO' + '.csv')
