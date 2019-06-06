import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as pltdates
import datetime as dt
import scipy as sy
import scipy.fftpack as syfp
import pylab as pyl
import math

from main_functions import readFile, getData, plotGraph

myfile = readFile()

#given a data form, and a start and end dates as well as 'gapvariable', the variable whose data is missing in those dates
#fill the gap!
def gapFill(DataForm, start_date, end_date, gapvariable):
    duration = end_date-start_date
    start_hour = start_date.hour
    start_minute = start_date.minute
    i = 0
    while(DataForm['dateTimeUTC'].iloc[i].hour != start_hour & DataForm['dateTimeUTC'].iloc[i].minute != start_minute):
        i += 1
    averages = dict()       #dictionary of averages for each variable and date
    myaverage = dict()      #dictionary of averages for each variable in OUR date (the gap)
    while(DataForm['dateTimeUTC'].iloc[i] < DataForm['dateTimeUTC'].iloc[-1] - duration):       #index -1 means the last index in the dataform
        if(DataForm['dateTimeUTC'].iloc[i] == start_date):
            j = 0
            while(DataForm['dateTimeUTC'].iloc[i] <= end_date):         #loop through to get the gap average
                myaverage[DataForm['variable'].iloc[i]] = (myaverage[DataForm['variable'].iloc[i]] * j + DataForm['value'].iloc[i]) / (j+1)
                i += 1
                j += 1
        else:
            dictindex = DataForm['dateTimeUTC'].iloc[i]             #dictindex is the starting timestamp for each period we take the average of
            j = 0
            while(DataForm['dateTimeUTC'].iloc[i] < dictindex + duration):      #while our current date is within our current period
                currentdate = DataForm['dateTimeUTC'].iloc[i]
                while(DataForm['dateTimeUTC'].iloc[i] == currentdate):          #loop through one set of variables for one specific timestamp (currentdate)
                    if(DataForm['variable'].iloc[i] != gapvariable):
                        key = [dictindex, DataForm['variable'].iloc[i]]           #a tuple containing the starting date, and the variable for one entry in the averages dictionary
                        averages[key] = (averages[key] * j + DataForm['value'].iloc[i]) / (j+1)     #update the average
                    i += 1
                j += 1         #j is the number of elements we count for each variable (we increment it after looping through one complete set of different variables for one timestamp)
    squared_differences = dict()
    variable_averages = dict()
    variable_stddevs = dict()
    for key in np.unique(DataForm['variable']):         #calculate std_devs and means for each variable (used to standardize squared differences)
        this_variable = DataForm.loc[DataForm['variable'] == key]
        variable_averages[key] = np.mean(this_variable['value'])
        variable_stddevs[key] = np.std(this_variable['value'])
    for key in averages:
        squared_differences[key[0]] += (averages[key] - myaverage[key[1]])**2 / variable_stddevs[key[1]]        #calculate standardized squared_differences
    closest_date = min(squared_differences, key = squared_differences.get)
    fill_with = DataForm.loc[(DataForm['dateTimeUTC'] >= closest_date) & (DataForm['dateTimeUTC'] < closest_date + duration) & (DataForm['variable']==gapvariable)]
    fill_with['dateTimeUTC'].add(dt.timedelta(start_date) - dt.timedelta(closest_date))
    DataForm.append(fill_with, ignore_index=True)
    return DataForm

riverdata = getData(myfile, 'AZ', 'LV', 'WaterTemp_C')
plotGraph(riverdata)

filled = gapFill(riverdata, dt.datetime(2018,6,7),dt.datetime(2018,7,11),'WaterTemp_C')
plotGraph(filled)
