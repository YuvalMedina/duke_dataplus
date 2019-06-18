import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as pltdates
import datetime as dt

def readFile(name):
    myfile = pd.read_csv(name, sep=',', parse_dates=[2])
    myfile['dateTimeUTC'] = pd.to_datetime(myfile['dateTimeUTC'], format='%Y-%m-%d %H:%M:%S')
    myfile['value'] = pd.to_numeric(myfile['value'])
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
    ax1.plot_date(file['dateTimeUTC'], file['value'])
    if((region != '') & (site != '') & (variable != '')):
        ax1.set_title(file.iloc[1][0] + ', ' + file.iloc[1][1] + ', ' + file.iloc[1][3])
    return

#myfile = readFile("flagged_sites.csv")
#plotGraph(myfile, region="NC", site="Eno", variable="WaterPres_kPa")
