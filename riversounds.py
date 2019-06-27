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
path = "NC_Eno_WaterTemp_C"        #change to user input at some point!
delta = 4           #how many std_dev's from mean are we tolerating

myfile = readFile("csv_files/" + path + ".csv")

clean = myfile.loc[myfile['flagID']!="Bad Data"]
clean = clean.drop_duplicates(subset=['dateTimeUTC'], keep='first')

mean = np.mean(clean['value'])
std_dev = np.std(clean['value'])

clean = clean[(clean.value < (mean + (delta * std_dev))) & (clean.value > (mean - (delta * std_dev)))]

nums = (clean['value'] - mean) / std_dev
nums = np.float32(nums)

if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("--ip", default='127.0.0.1',
                        help="The ip of the OSC server")
    parser.add_argument("--port", type=int, default=57120,
                        help="The port the OSC server is listening on")
    args = parser.parse_args()

    client = udp_client.SimpleUDPClient(args.ip, args.port)

    msg = osc_message_builder.OscMessageBuilder(address='/s_new')
    msg.add_arg(nums, arg_type=)
