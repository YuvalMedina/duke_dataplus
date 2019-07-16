import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib
import matplotlib.pyplot as plt
import matplotlib.animation as animation

from main_functions import readFile, getData, plotGraph

gpppath = 'all_daily_model_results'
region = 'NC'
site = 'Eno'
start_date = dt.datetime.strptime('2017-01-01', '%Y-%m-%d')   #2017-01-01
end_date = dt.datetime.strptime('2017-12-29', '%Y-%m-%d')   #2017-12-29

mygpp = pd.read_csv("all_daily_model_results.csv", sep=',', skiprows=[1], parse_dates=['year', 'solar_date'], dtype={'GPP':np.float64, 'GPP_lower':np.float64,
                                                                        'GPP_upper':np.float64, 'ER':np.float64, 'ER_lower':np.float64,
                                                                        'ER_upper':np.float64, 'K600':np.float64, 'K600_lower':np.float64,
                                                                        'K600_upper':np.float64}, na_values=['\\N'])
mygpp = mygpp.loc[(mygpp['region']==region) & (mygpp['site']==site)]
mygpp = mygpp.loc[(mygpp['solar_date'] >= start_date) & (mygpp['solar_date'] <= end_date)]
READINGS = mygpp['GPP'].count()      #number of readings of gpp from river! from OC is 687
FRAMESIZE = 1          #how slow we're going through, when one, we go 1frame/0.1sec
#optimal frame for discharge (lightning and pinknoises) is 20 (1frame/2sec)
#for all others, frame=1 is great

path = region + '_' + site + '_' + "sensorData"
variable = "DO_mgL"

myfile = pd.read_csv('csv_files/' + 'Complete_Sensor_Data/' + path + '.csv', sep=',')
myfile['DateTime_UTC'] = pd.to_datetime(myfile['DateTime_UTC'], format='%Y-%m-%d %H:%M:%S')
myfile['value'] = pd.to_numeric(myfile['value'])
myvalues = myfile.loc[(myfile['DateTime_UTC'] >= start_date) & (myfile['DateTime_UTC'] <= end_date)]
myvalues = myvalues.loc[myfile['variable'] == variable]

%matplotlib notebook
title = region + ', ' + site + ', ' + 'GPP'
y = np.array(mygpp['GPP'])
x = np.array(mygpp['solar_date'])
gppplot = pd.DataFrame(y,x)

Writer = animation.writers['ffmpeg']
writer = Writer(fps=READINGS/FRAMESIZE*10, metadata=dict(artist='Me'), bitrate=1800)

fig = plt.figure(figsize=(10,6))
plt.title(title)
plt.plot_date(x,y)
