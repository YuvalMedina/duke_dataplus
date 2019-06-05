import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as pltdates
import datetime as dt
import scipy as sy
import scipy.fftpack as syfp
import pylab as pyl

from main_functions import readFile, getData, plotGraph

myfile = readFile()

#given a data form, and a start and end, which are dates in the same format as in the main .csv file
def gapFill(DataForm, start_date, end_date):
    duration = dt.timedelta(end_date) - dt.timedelta(start_date)
    start_hour = start_date.hours
    start_minute = start_date.minutes
    i = 0
    while(DataForm['dateTimeUTC'].iloc[i].hours != start_hour & DataForm['dateTimeUTC'].iloc[i].minutes != start_minute):
        i++
    averages = dict()
    while(DataForm['dateTimeUTC'].iloc[i] < DataForm['dateTimeUTC'].iloc[-1] - duration):       #index -1 means the last index in the dataform
        if(DataForm['dateTimeUTC'].iloc[i] == start_date):
            while(DataForm['dateTimeUTC'].iloc[i] <= end_date):         #loop through to skip the gap
                i++
        else:
            dictindex = DataForm['dateTimeUTC'].iloc[i]             #dictindex is the starting timestamp for each period we take the average of
            j = 0
            while(DataForm['dateTimeUTC'].iloc[i] < dictindex + duration):      #while our current date is within our current period
                currentdate = DataForm['dateTimeUTC'].iloc[i]
                while(DataForm['dateTimeUTC'].iloc[i] == currentdate):          #loop through one set of variables for one specific timestamp (currentdate)
                    key = [currentdate, DataForm['variable'].iloc[i]]           #a tuple containing the starting date, and the variable for one entry in the averages dictionary
                    averages[key] = (averages[key] * j + DataForm['value'].iloc[i]) / (j+1)     #update the average
                j++          #j is the number of elements we count for each variable (we increment it after looping through one complete set of different variables for one timestamp)
