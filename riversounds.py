import argparse
import random
from pythonosc import osc_message_builder
from pythonosc import udp_client
import socket
import time

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as pltdates
import datetime as dt

from main_functions import readFile, getData, plotGraph

#parameters:
path = "NC_Eno_Turbidity_mV"        #change to user input at some point!

#myfile = pd.read_csv(path + ".csv", sep=',', skiprows=[1], parse_dates=['year', 'solar_date'], dtype={'GPP':np.float64, 'GPP_lower':np.float64,
#                                                                        'GPP_upper':np.float64, 'ER':np.float64, 'ER_lower':np.float64,
#                                                                        'ER_upper':np.float64, 'K600':np.float64, 'K600_lower':np.float64,
#                                                                        'K600_upper':np.float64}, na_values=['\\N'])

myfile = readFile('csv_files/' + path + '.csv')
start_date = dt.datetime.strptime('2016-12-31', '%Y-%m-%d')   #2016-12-31
end_date = dt.datetime.strptime('2017-09-26', '%Y-%m-%d')   #2017-09-25 is last date
myvalues = myfile.loc[(myfile['dateTimeUTC'] >= start_date) & (myfile['dateTimeUTC'] < end_date)]
#myvalues   #25117 members

#myvalues = myfile.loc[(myfile['region']=='NC') & (myfile['site']=='Eno')]
#myvalues = myvalues['GPP']

myMean = np.mean(myvalues)
myStd = np.std(myvalues)
myMin = myMean - 4*myStd
myMax = myMean + 4*myStd
myRange = myMax - myMin

#changing volume or frequency?
def volume():
    myvalues = abs( ((myvalues - myMin)/myRange )**2)

def frequency():
    myvalues = abs( ((myvalues - myMin)/myRange )**2) * 500 + 200

changevalues = {'volume' : volume,
                'frequency' : frequency,
}

#change here!
changevalues('volume')

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
        time.sleep(0.1)

    client.send_message("/print", 0.0)
