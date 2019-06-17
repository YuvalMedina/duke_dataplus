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

myfile = readFile("flagged_sites.csv")

myregionsite_data = getData(myfile, region="NC", site="Eno")
myVar_data = getData(myregionsite_data, variable="DO_mgL")

plotGraph(myVar_data)

mean = np.mean(myVar_data['value'])
std_dev = np.std(myVar_data['value'])

factors = dict({'DO_mgL': 60,
                    'WaterTemp_C': 50,
                    'pH': 100,
                    'AirTemp_C': 70,
                    'WaterPres_kPa': 4})
factorized_mean = mean * factors["DO_mgL"]      #the variable name is at index 1, 3

if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("--ip", default='127.0.0.1',
                        help="The ip of the OSC server")
    parser.add_argument("--port", type=int, default=57120,
                        help="The port the OSC server is listening on")
    args = parser.parse_args()

    client = udp_client.SimpleUDPClient(args.ip, args.port)

    for x in range(20):
        client.send_message("/print", factorized_mean)
        time.sleep(1)
