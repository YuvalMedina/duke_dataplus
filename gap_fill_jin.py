import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as pltdates
import datetime as dt
from main_functions import readFile, getData, plotGraph

def daily_avg_sqDiff(DataForm):
    #takes in a DataFrame containing all information for one siteID, returns dictionary of dataframes containing difference in averages between consecutive days
    DataForm['month'] = pd.DatetimeIndex(DataForm['dateTimeUTC']).month
    DataForm['day'] = pd.DatetimeIndex(DataForm['dateTimeUTC']).day
    variables = az_lv.variable.unique()
    byVar = {}
    for v in variables:
        values = DataForm.loc[DataForm['variable']==v]
        #values = values.groupby(['month','day']).mean()
        values = values.set_index(['regionID', 'siteID', 'dateTimeUTC', 'variable', 'flagID', 'flagComment', 'month', 'day']).groupby(['month', 'day']).apply(filter_vals).reset_index().dropna()
        values = values.drop(['month', 'day'], axis=1)
        diff_byDay = pd.DataFrame()
        diff_byDay = values.diff()
        sq_diff_byDay = np.square(diff_byDay)
        byVar[v] = sq_diff_byDay
    return byVar

def filter_vals(x):
    mean_val = x.mean()
    filtered = mean_val
    return filtered

def sum_sq_diff(diff_dict):
    rows = daily[variables[0]].shape[0]
    #get num rows
    #loop through number of rows and add them across teh dictionaries
    #each sum append to a new dataframe with dates(?)
    return

x.reindex_like(y).fillna(0) + y.fillna(0).fillna(0) # sum of x and y dataframes


def getDataSite(DataForm, region, site):
    #import numpy as np
    #import pandas as pd
    regionFile = DataForm.loc[DataForm['regionID']==region]
    return regionFile.loc[regionFile['siteID']==site]      #return dirty file (all flags are kept) for given region, site, and variable name

myfile = readFile();
DataForm = getDataSite(myfile, 'AZ', 'LV')
print(daily_avg_sqDiff(DataForm))

DataForm['month'] = pd.DatetimeIndex(DataForm['dateTimeUTC']).month
DataForm['day'] = pd.DatetimeIndex(DataForm['dateTimeUTC']).day
variables = DataForm.variable.unique()
byVar = {}

for v in variables:
    values = DataForm.loc[DataForm['variable']==v]
    #values = values.groupby(['month','day']).mean()
    values = values.set_index(['regionID', 'siteID', 'dateTimeUTC', 'variable', 'flagID', 'flagComment', 'month', 'day']).groupby(['month', 'day']).apply(filter_vals).reset_index().dropna()
    values = values.drop(['month', 'day'], axis=1)
    diff_byDay = pd.DataFrame()
    diff_byDay = values.diff()
    byVar[v] = diff_byDay
print(byVar)
