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

READINGS = 269      #number of readings of gpp from Eno!
FRAMES = 1          #how slow we're going through, when one, we go 1frame/0.1sec

#parameters:
path = "NC_Eno_DO_mgL"        #change to user input at some point!

#path = "all_daily_model_results"   #length of Eno gpp is 269 days
#myfile = pd.read_csv(path + ".csv", sep=',', skiprows=[1], parse_dates=['year', 'solar_date'], dtype={'GPP':np.float64, 'GPP_lower':np.float64,
#                                                                        'GPP_upper':np.float64, 'ER':np.float64, 'ER_lower':np.float64,
#                                                                        'ER_upper':np.float64, 'K600':np.float64, 'K600_lower':np.float64,
#                                                                        'K600_upper':np.float64}, na_values=['\\N'])

myfile = readFile('csv_files/' + path + '.csv')
start_date = dt.datetime.strptime('2016-12-31', '%Y-%m-%d')   #2016-12-31
end_date = dt.datetime.strptime('2017-09-26', '%Y-%m-%d')   #2017-09-25 is last date
myvalues = myfile.loc[(myfile['dateTimeUTC'] >= start_date) & (myfile['dateTimeUTC'] < end_date)]
myvalues = myvalues['value']
#myvalues   #25824 members

#myvalues = myfile.loc[(myfile['region']=='NC') & (myfile['site']=='Eno')]
#start_date = dt.datetime.strptime('2016-12-31', '%Y-%m-%d')   #2016-12-31
#end_date = dt.datetime.strptime('2017-09-26', '%Y-%m-%d')   #2017-09-25 is last date
#myvalues = myvalues.loc[(myfile['solar_date'] >= start_date) & (myfile['solar_date'] < end_date)]
#myvalues = myvalues['GPP']



#modulating volume or frequency?
def volume():
    print('yay')

def frequency():
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

        for x in range(len(myvalues)):
            client.send_message("/print", myvalues.iloc[x])
            time.sleep(0.2)

        client.send_message("/print", 0.0)


changevalues = {'volume' : volume,
                'frequency' : frequency,
}

#change here!
changevalues['volume']

myvalues.fillna(0)
skipby = math.floor(myvalues.size / READINGS * FRAMES)

std_devs = list()

for x in range(math.floor(READINGS / FRAMES)):
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

#std_devs

if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("--ip", default='127.0.0.1',
                        help="The ip of the OSC server")
    parser.add_argument("--port", type=int, default=57120,
                        help="The port the OSC server is listening on")
    args = parser.parse_args()

    client = udp_client.SimpleUDPClient(args.ip, args.port)

    for x in range(len(std_devs)):
        client.send_message("/print", std_devs[x])
#        if(thunder[x]):
#            client.send_message("/thunder", 1)
#        else:
#            client.send_message("/thunder", 0)
        time.sleep(0.2 * FRAMES)

    client.send_message("/print", 0.0)
