def readFile():
    myfile = pd.read_csv("flagged_sites.csv", sep=',', parse_dates=[2])
    myfile['dateTimeUTC'] = pd.to_datetime(myfile['dateTimeUTC'], format='%Y-%m-%d %H:%M:%S')
    return myfile

def getData(DataForm, region, site, variable):
    #import numpy as np
    #import pandas as pd
    regionFile = DataForm.loc[DataForm['regionID']==region]
    siteFile = regionFile.loc[regionFile['siteID']==site]
    return siteFile.loc[siteFile['variable']==variable]      #return dirty file (all flags are kept) for given region, site, and variable name

def plotGraph(DataForm):
    #import these libraries in the following way, in order for this to work:
    #import matplotlib.pyplot as plt
    #import matplotlib.dates as pltdates
    #import datetime as dt
    #use on data extracted using 'getData' helper function
    fig1, ax1 = plt.subplots();
    ax1.plot_date(DataForm.dateTimeUTC, DataForm.value)
    region = DataForm.loc[:, 'regionID']
    site = DataForm.loc[:,'siteID']
    variable = DataForm.loc[:,'variable']
    ax1.set_title(region.iloc[0] + ', ' + site.iloc[0] + ', ' + variable.iloc[0])
    return
