import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as pltdates
import datetime as dt
from main_functions import readFile, getData, plotGraph
from itertools import groupby

myfile = readFile();

def plotGraph(DataForm, region="", site="", variable=""):
    file = DataForm
    if region:
        file = file.loc[file['regionID']==region]
    if site:
        file = file.loc[file['siteID']==site]
    if variable:
        file = file.loc[file['variable']==variable]
    region_name = file.loc[:, 'regionID']
    site_name = file.loc[:,'siteID']
    variable_name = file.loc[:,'variable']
    ax1.set_title(region_name.iloc[0] + ', ' + site_name.iloc[0] + ', ' + variable_name.iloc[0])
    return

def get_flaggedData(DataForm, region="", site="", variable=""):
    #import numpy as np
    #import pandas as pd
    file = DataForm
    if region:
        file = file.loc[file['regionID']==region]
    if site:
        file = file.loc[file['siteID']==site]
    if variable:
        file = file.loc[file['variable']==variable]
    return file.loc[(file['flagID']!='\\N')]

def get_stormData(DataForm, region="", site="", variable=""):
    #import numpy as np
    #import pandas as pd
    file = DataForm
    if region:
        file = file.loc[file['regionID']==region]
    if site:
        file = file.loc[file['siteID']==site]
    if variable:
        file = file.loc[file['variable']==variable]

def get_keyWord_Data(DataForm, region="", site="", variable="", keyWord=""):
    #import numpy as np
    #import pandas as pd
    file = DataForm
    if region:
        file = file.loc[file['regionID']==region]
    if site:
        file = file.loc[file['siteID']==site]
    if variable:
        file = file.loc[file['variable']==variable]
    if keyWord:
        file = file[file['flagComment'].str.contains(keyWord, case=False)==True]
    return file

out_of_water = get_keyWord_Data(myfile,region = 'NC',site = 'NHC',variable = 'WaterTemp_C',keyWord = "error")
out_of_water.variable.unique()
nc_ueno = getData(myfile, 'NC', 'NHC', 'WaterTemp_C')
fig1, ax1 = plt.subplots();

ax1.plot_date(nc_ueno.dateTimeUTC, nc_ueno.value, mfc = 'b', mec = 'b')
ax1.plot_date(out_of_water.dateTimeUTC, out_of_water.value, mfc = 'r', mec = 'r')

all_flagged = get_flaggedData(myfile)
all_flagged.flagComment.unique()

nc_eno_dirty = get_flaggedData(myfile, 'NC', 'Eno')
az_LV_dirty = get_flaggedData(myfile, 'AZ', 'LV')
nc_eno_storm = get_stormData(myfile, 'NC', 'Eno')
nc_NHC_storm = get_stormData(myfile, 'NC', 'NHC')
az_LV_storm = get_stormData(myfile, 'AZ', 'LV')
az_LV_dirty.flagComment.unique()
all_storm = get_stormData(myfile)

all_storm.siteID.unique()
plotGraph(nc_NHC_storm)

plotGraph(myfile, 'NC', 'NHC','WaterPres_kPa')
plotGraph(nc_eno_storm)
plotGraph(nc_eno_dirty, variable = 'Discharge_m3s')
