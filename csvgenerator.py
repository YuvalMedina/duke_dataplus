import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as pltdates
import datetime as dt

from main_functions import readFile, getData, plotGraph

myfile = readFile("flagged_sites.csv")

for region in myfile['regionID'].unique():
    regionfile = myfile.loc[myfile['regionID']==region]
    for site in regionfile['siteID'].unique():
        sitefile = regionfile.loc[regionfile['siteID']==site]
        for variable in sitefile['variable'].unique():
            subsection = sitefile.loc[sitefile['variable']==variable]
            del subsection['regionID']
            del subsection['siteID']
            del subsection['variable']
            subsection.to_csv('csv_files/' + region + '_' + site + '_' + variable + '.csv')
