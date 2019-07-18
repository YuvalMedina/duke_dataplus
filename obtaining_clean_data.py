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
nc_cbp = pd.read_csv("NC_CBP_sensorData.csv")
nc_cbp.head()

nc_cbp_DO = pd.DataFrame(columns=['dateTimeUTC', 'value'])
nc_cbp_DO['dateTimeUTC'] = nc_cbp['DateTime_UTC']
nc_cbp_DO['value'] = nc_cbp['DO_mgL']

nc_cbp_waterTemp = pd.DataFrame(columns=['dateTimeUTC', 'value'])
nc_cbp_waterTemp['dateTimeUTC'] = nc_cbp['DateTime_UTC']
nc_cbp_waterTemp['value'] = nc_cbp['WaterTemp_C']

df_st_sens = nc_cbp_DO['dateTimeUTC'].loc[nc_cbp_DO['dateTimeUTC']=='2019-05-01 11:45:00'].index.values.astype(int)
print(df_st_sens)
df_end_sens = nc_cbp_DO['dateTimeUTC'].loc[nc_cbp_DO['dateTimeUTC']=='2019-06-12 18:45:00'].index.values.astype(int)
print(df_end_sens)
test_sens= nc_cbp_DO.iloc[df_st_sens[0]:df_end_sens[0]]
test_sens.to_csv('Dirty Data Log/' + 'Sensor Out of Water_DO' + '.csv')

df_st_sens_2 = nc_cbp_waterTemp['dateTimeUTC'].loc[nc_cbp_waterTemp['dateTimeUTC']=='2019-05-01 11:45:00'].index.values.astype(int)
print(df_st_sens_2)
df_end_sens_2 = nc_cbp_waterTemp['dateTimeUTC'].loc[nc_cbp_waterTemp['dateTimeUTC']=='2019-06-12 18:45:00'].index.values.astype(int)
print(df_end_sens_2)
test_sens_2= nc_cbp_waterTemp.iloc[df_st_sens[0]:df_end_sens[0]]
test_sens_2.to_csv('Dirty Data Log/' + 'Sensor Out of Water_waterTemp' + '.csv')

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

df_st_out_2 = nc_eno_disch['dateTimeUTC'].loc[nc_eno_disch['dateTimeUTC']=='2017-05-28 11:45:00'].index.values.astype(int)
print(df_st_out_2)
df_end_out_2 = nc_eno_disch['dateTimeUTC'].loc[nc_eno_disch['dateTimeUTC']=='2017-06-02 18:45:00'].index.values.astype(int)
print(df_end_out_2)
test_out_2 = nc_eno_disch.iloc[df_st_out_2[0]:df_end_out_2[0]]
test_out_2.to_csv('Dirty Data Log/' + 'Outliers_discharge' + '.csv')
