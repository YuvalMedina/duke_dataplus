import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as pltdates
import datetime as dt
from main_functions import readFile, getData, plotGraph
from itertools import groupby

def getDataSite(DataForm, region, site):
    #import numpy as np
    #import pandas as pd
    regionFile = DataForm.loc[DataForm['regionID']==region]
    return regionFile.loc[regionFile['siteID']==site]      #return dirty file (all flags are kept) for given region, site, and variable name

index = pd.date_range('1/1/2000', periods=9, freq='T')
series = pd.Series(range(9), index=index)
series.resample('3T').sum()

myfile = readFile();
DataForm = getData(myfile, 'AZ', 'LV', 'WaterTemp_C')
plotGraph(DataForm)
DataForm.head()

DataForm.asfreq('15M')
all_gaps = DataForm[pd.isnull(DataForm["value"])]
all_gaps.head()

dates = all_gaps.dateTimeUTC.toList()
dates_diff = [dates[i + 1] - dates[i] for i in range(len(dates)-1)]
gap_info = [(sum(1 for _ in gp), x) for x, gp in groupby(dates_diff)]





def find_gap(DataForm):
    #takes in DataFrame with gaps for one region and siteID
    #returns dictionary with variables as keys containing start and end dates of gaps
        #if only one day of missing value, start and end date are the same
    all_gaps = DataForm[pd.isnull(DataForm["value"])]
    variables = all_gaps.variable.unique()      #gets all variables with gaps
    for v in variables:
        i=0
        values = all_gaps.loc[all_gaps['variable']==v]      #gets new DataFrame with only info on missing values
        dates = values['dateTimeUTC'].toList()
        dates_diff = [dates[i + 1] - dates[i] for i in range(len(dates)-1)]
        gap_info = [(sum(1 for _ in gp), x) for x, gp in groupby(dates_diff)]
        start_date = values['dateTimeUTC'].iloc[0]
        i+=1
        if(values['value'].iloc[i].isnull()):
            while(values['value'].iloc[i].isnull()):
                i+=1
            end_date = values['dateTimeUTC'].iloc[i]
        else:
            gap_var[v] = [start_date, start_date]
        gap_var[v] = [start_data, end_date]
    return gap_var



def daily_stand_avg(DataForm, start_date, end_date):
    #takes in a DataFrame containing all information for one siteID, returns dictionary of dataframes containing difference in averages between consecutive days
    DataForm['month'] = pd.DatetimeIndex(DataForm['dateTimeUTC']).month
    DataForm['day'] = pd.DatetimeIndex(DataForm['dateTimeUTC']).day
    start_hour = start_date.hours
    start_minute = start_date.minutes
    no_gap = pd.DataFrame()
    i=0
    while(DataForm['dateTimeUTC'].iloc[i].hours != start_hour & DataForm['dateTimeUTC'].iloc[i].minutes != start_minute):
        no_gap.append(DataForm.iloc[i])     #appends data before gap starts to no_gap dataframe
    while(DataForm['dateTimeUTC'].iloc[i]>=)
    variables = DataForm.variable.unique()
    byVar = {}
    for v in variables:
        values = DataForm.loc[DataForm['variable']==v]
        #values = values.groupby(['month','day']).mean()
        values = values.set_index(['regionID', 'siteID', 'dateTimeUTC', 'variable', 'flagID', 'flagComment', 'month', 'day']).groupby(['month', 'day']).apply(filter_vals).reset_index()
        values = values.drop(['month', 'day'], axis=1)
        values['value'] = (values.value - values.value.mean()) / values.value.std()
        #diff_byDay = pd.DataFrame()
        #diff_byDay = values.diff()
        #sq_diff_byDay = np.square(diff_byDay)
        #byVar[v] = sq_diff_byDay
        byVar[v] = values
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


DataForm = getDataSite(myfile, 'AZ', 'LV')
print(daily_stand_avg(DataForm))

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
