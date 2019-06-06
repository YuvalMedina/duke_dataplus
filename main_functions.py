import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as pltdates
import datetime as dt

def readFile():
    myfile = pd.read_csv("flagged_sites.csv", sep=',', parse_dates=[2])
    myfile['dateTimeUTC'] = pd.to_datetime(myfile['dateTimeUTC'], format='%Y-%m-%d %H:%M:%S')
    return myfile

#can leave any one of these fields empty
def getData(DataForm, region="", site="", variable=""):
    #import numpy as np
    #import pandas as pd
    file = DataForm
    if region:
        file = file.loc[file['regionID']==region]
    if site:
        file = file.loc[file['siteID']==site]
    if variable:
        file = file.loc[file['variable']==variable]
    return file      #return dirty file (all flags are kept) for given region, site, and variable name

def plotGraph(DataForm, region="", site="", variable=""):
    #import these libraries in the following way, in order for this to work:
    #import matplotlib.pyplot as plt
    #import matplotlib.dates as pltdates
    #import datetime as dt
    #use on data extracted using 'getData' helper function
    file = DataForm
    if region:
        file = file.loc[file['regionID']==region]
    if site:
        file = file.loc[file['siteID']==site]
    if variable:
        file = file.loc[file['variable']==variable]
    fig1, ax1 = plt.subplots();
    ax1.plot_date(file.dateTimeUTC, file.value)
    region_name = file.loc[:, 'regionID']
    site_name = file.loc[:,'siteID']
    variable_name = file.loc[:,'variable']
    ax1.set_title(region_name.iloc[0] + ', ' + site_name.iloc[0] + ', ' + variable_name.iloc[0])
    return
