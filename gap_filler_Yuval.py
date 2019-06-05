import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as pltdates
import datetime as dt
import scipy as sy
import scipy.fftpack as syfp
import pylab as pyl

myfile = pd.read_csv("flagged_sites.csv", sep=',', parse_dates=True)

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
    dates = [dt.datetime.strptime(d,'%Y-%m-%d %H:%M:%S').date() for d in DataForm.dateTimeUTC]
    datenums = pltdates.date2num(dates)
    fig1, ax1 = plt.subplots();
    ax1.plot_date(dates, DataForm.value)
    region = DataForm.loc[:, 'regionID']
    site = DataForm.loc[:,'siteID']
    variable = DataForm.loc[:,'variable']
    ax1.set_title(region.iloc[0] + ', ' + site.iloc[0] + ', ' + variable.iloc[0])
    return

#given a data form, and a start and end, which are dates in the same format as in the main .csv file
def gapFill(DataForm, start, end):
    start_date = dt.datetime.strptime(start,'%Y-%m-%d %H:%M:%S').date()
    end_date = dt.datetime.strptime(end,'%Y-%m-%d %H:%M:%S').date()
    duration = dt.timedelta(end_date) - dt.timedelta(start_date)
    duration /= dt.timedelta(minutes=15)
    start_hour = start_date.hours
    start_minute = start_date.minutes
    startindex = 0
    for i in xrange(96):        #how many 15 minute intervals exist in one day
        thisdate = dt.datetime.strptime(DataForm.iloc[i,0],'%Y-%m-%d %H:%M:%S').date()
        if(thisdate.hours = start_hour & thisdate.minutes = start_minute):
            startindex = i
            break
        #need to fix this loop (and all loops) because DataForm will have multiple entries for one date!
    i = 0
    square_difs = np.array((len(DataForm)-startindex)/96, 1)
    skipindex = ( dt.timedelta(start_date) - dt.timedelta(dt.datetime.strptime(DataForm.iloc[startindex,0],'%Y-%m-%d %H:%M:%S').date()) ) / dt.timedelta(minutes = 15)
    while i < len(square_difs):
        if(i = skipindex):
            i += 96
            continue
        sum = 0
        for j in xrange(96):

        i += 96
