import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as pltdates
import datetime as dt
import wave
import sys

from main_functions import readFile, getData, plotGraph

path = "NC_UEno_WaterTemp_C"

currentfile = readFile("csv_files/" + path + ".csv")

clean = currentfile.loc[currentfile['flagID']!="Bad Data"]

#clean.head(10)
#clean.dtypes

clean = clean.drop_duplicates(subset=['dateTimeUTC'], keep='first')
clean = clean[(clean.value < 200) & (clean.value > 0)]

mean = np.mean(clean['value'])
std_dev = np.std(clean['value'])

wavfile = wave.open("wav_files/" + path + ".wav", mode='wb')
nums = (clean['value'] - mean) / std_dev
nums = np.float32(nums)
bytes = nums.tobytes()
wavfile.setparams((1,4, 44100, 0, 'NONE', 'NONE'))
wavfile.writeframes(bytes)

plt.plot(clean['dateTimeUTC'],clean['value'])
plt.show
