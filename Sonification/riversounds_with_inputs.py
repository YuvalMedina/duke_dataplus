import argparse
import random
from pythonosc import osc_message_builder
from pythonosc import udp_client
import socket
import time
import math

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as pltdates
import datetime as dt

from main_functions import readFile, getData, plotGraph

region = 'NC'
site = 'Eno'
start_date = dt.datetime.strptime('2017-01-01', '%Y-%m-%d')   #2017-01-01
end_date = dt.datetime.strptime('2017-12-29', '%Y-%m-%d')   #2017-12-29

mygpp = pd.read_csv("all_daily_model_results.csv", sep=',', skiprows=[1], parse_dates=['year', 'solar_date'], dtype={'GPP':np.float64, 'GPP_lower':np.float64,
                                                                        'GPP_upper':np.float64, 'ER':np.float64, 'ER_lower':np.float64,
                                                                        'ER_upper':np.float64, 'K600':np.float64, 'K600_lower':np.float64,
                                                                        'K600_upper':np.float64}, na_values=['\\N'])
mygpp = mygpp.loc[(mygpp['region']==region) & (mygpp['site']==site)]
mygpp = mygpp.loc[(mygpp['solar_date'] >= start_date) & (mygpp['solar_date'] <= end_date)]
READINGS = len(mygpp['GPP'])      #number of readings of gpp from river! from OC is 687
FRAMESIZE = 1          #how slow we're going through, when one, we go 1frame/0.1sec
#optimal frame for discharge (lightning and pinknoises) is 20 (1frame/2sec)
#for all others, frame=1 is great

#parameters:
#change to user input at some point!
path = region + '_' + site + '_' + "sensorData"


myfile = pd.read_csv('csv_files/' + 'Complete_Sensor_Data/' + path + '.csv', sep=',')
myfile['DateTime_UTC'] = pd.to_datetime(myfile['DateTime_UTC'], format='%Y-%m-%d %H:%M:%S')
myfile['value'] = pd.to_numeric(myfile['value'])
myfile = myfile.loc[(myfile['DateTime_UTC'] >= start_date) & (myfile['DateTime_UTC'] <= end_date)]
#myvalues holds the variable for the timespan of gpp

def getVariable(variable):
    if(variable == "GPP"):
        return mygpp['GPP']
    else:
        temp = myfile.loc[myfile['variable'] == variable]
        return temp['value']


#recording GPP
variable = "GPP"
FRAMESIZE = 1

myvalues = getVariable(variable)

myMean = np.mean(myvalues)
myStd = np.std(myvalues)
myMin = myMean - 4*myStd
myMax = myMean + 4*myStd
myRange = myMax - myMin

myvalues = abs( ((myvalues - myMin)/myRange )**2) * 500 + 200

myvalues.fillna(0)

if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("--ip", default='127.0.0.1',
                        help="The ip of the OSC server")
    parser.add_argument("--port", type=int, default=57120,
                        help="The port the OSC server is listening on")
    args = parser.parse_args()

    client = udp_client.SimpleUDPClient(args.ip, args.port)

    client.send_message("/variable", variable)
    client.send_message("/region", region)
    client.send_message("/site", site)
    client.send_message("/start", 0)

    for x in range(len(myvalues)):
        client.send_message("/gpp", myvalues.iloc[x])
        time.sleep(0.1)

    client.send_message("/stop", 0)



#recording dissolved oxygen
variable = "DO_mgL"
FRAMESIZE = 1

myvalues.fillna(0)
skipby = math.floor(myvalues.size / READINGS * FRAMESIZE)

std_devs = list()

for x in range(math.floor(READINGS / FRAMESIZE)):
    temp = list()
    for y in range(skipby):
        temp.append(myvalues.iloc[x * skipby + y])
    std_devs.append(np.std(temp))

myMean = np.mean(std_devs)
myStd = np.std(std_devs)
myMin = myMean - 4*myStd
myMax = myMean + 4*myStd
myRange = myMax - myMin
std_devs = abs( ((std_devs - myMin)/myRange )**3)

if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("--ip", default='127.0.0.1',
                        help="The ip of the OSC server")
    parser.add_argument("--port", type=int, default=57120,
                        help="The port the OSC server is listening on")
    args = parser.parse_args()

    client = udp_client.SimpleUDPClient(args.ip, args.port)

    client.send_message("/variable", variable)
    client.send_message("/start", 0)

    for x in range(len(std_devs)):
        client.send_message("/DO", std_devs[x])
        time.sleep(0.1 * FRAMESIZE)

    client.send_message("/stop", 0)



#recording Discharge
variable = "Discharge_m3s"
FRAMESIZE = 20

myvalues.fillna(0)
skipby = math.floor(myvalues.size / READINGS * FRAMESIZE)

std_devs = list()

for x in range(math.floor(READINGS / FRAMESIZE)):
    temp = list()
    for y in range(skipby):
        temp.append(myvalues.iloc[x * skipby + y])
    std_devs.append(np.std(temp))

myMean = np.mean(std_devs)
myStd = np.std(std_devs)
myMin = myMean - 4*myStd
myMax = myMean + 4*myStd
myRange = myMax - myMin
std_devs = abs( ((std_devs - myMin)/myRange )**3)

thunder = std_devs > 0.4

if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("--ip", default='127.0.0.1',
                        help="The ip of the OSC server")
    parser.add_argument("--port", type=int, default=57120,
                        help="The port the OSC server is listening on")
    args = parser.parse_args()

    client = udp_client.SimpleUDPClient(args.ip, args.port)

    client.send_message("/variable", variable)
    client.send_message("/start", 0)

    for x in range(len(std_devs)):
        client.send_message("/discharge", std_devs[x])
        if(thunder[x]):
            client.send_message("/thunder", 1)
        else:
            client.send_message("/thunder", 0)
        time.sleep(0.1 * FRAMESIZE)

    client.send_message("/stop", 0)
