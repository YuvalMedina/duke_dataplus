import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import datetime as dt

from main_functions import readFile, getData, plotGraph

gpppath = 'all_daily_model_results'
region = 'PR'
site = 'QS'
start_date = dt.datetime.strptime('2017-01-01', '%Y-%m-%d')   #2017-01-01
end_date = dt.datetime.strptime('2017-12-29', '%Y-%m-%d')   #2017-12-29

doing_GPP = True    #whether or not we're plotting GPP or our variable

mygpp = pd.read_csv("all_daily_model_results.csv", sep=',', skiprows=[1], parse_dates=['year', 'solar_date'], dtype={'GPP':np.float64, 'GPP_lower':np.float64,
                                                                        'GPP_upper':np.float64, 'ER':np.float64, 'ER_lower':np.float64,
                                                                        'ER_upper':np.float64, 'K600':np.float64, 'K600_lower':np.float64,
                                                                        'K600_upper':np.float64}, na_values=['\\N'])
mygpp = mygpp.loc[(mygpp['region']==region) & (mygpp['site']==site)]
mygpp = mygpp.loc[(mygpp['solar_date'] >= start_date) & (mygpp['solar_date'] <= end_date)]
mygpp = mygpp[['solar_date','GPP']]
mygpp.columns = ['DateTime_UTC','value']
READINGS = len(mygpp['value'])      #number of readings of gpp from river! from OC is 687
FRAMESIZE = 1          #how slow we're going through, when one, we go 1frame/0.1sec
#optimal frame for discharge (lightning and pinknoises) is 20 (1frame/2sec)
#for all others, frame=1 is great

path = region + '_' + site + '_' + "sensorData"
variable = "DO_mgL"

myfile = pd.read_csv('csv_files/' + 'Complete_Sensor_Data/' + path + '.csv', sep=',')
myfile['DateTime_UTC'] = pd.to_datetime(myfile['DateTime_UTC'], format='%Y-%m-%d %H:%M:%S')
myfile['value'] = pd.to_numeric(myfile['value'])
myfile = myfile.loc[(myfile['DateTime_UTC'] >= start_date) & (myfile['DateTime_UTC'] <= end_date)]
myfile = myfile.loc[myfile['variable'] == variable]
myfile = myfile[['DateTime_UTC','value']]

myvalues = pd.DataFrame()
skipby = 1

if(doing_GPP):
    myvalues = mygpp
    variable = 'GPP'
    skipby = 1
else:
    myvalues = myfile
    skipby = myvalues.size / READINGS * FRAMESIZE


title = region + ', ' + site + ', ' + variable
y = np.array(myvalues['value'])
x = np.array(myvalues['DateTime_UTC'])
varplot = pd.DataFrame(y,x)

Writer = animation.writers['ffmpeg']
writer = Writer(fps=10, metadata=dict(artist='Me'), bitrate=1800)

fig = plt.figure(figsize=(10,6))
plt.title(title)
plt.plot_date(x,y)
plt.xlabel(variable)
plt.ylabel('Time Stamp')
plt.title(variable + ' over time', fontsize=22)

#plt.clf()

#def init():
#    scat.set_offsets([])
#    return scat

def animate(i):
    data = myvalues.iloc[:int((i+1) * skipby)] #select data range
    p = sns.lineplot(x=data['DateTime_UTC'], y=data['value'], data=data, color="r")
    p.tick_params(labelsize=17)
    plt.setp(p.lines,linewidth=7)

#def animate(i):
#    data = np.hstack((x[:i,np.newaxis], y[:i, np.newaxis]))
#    scat.set_offsets(data)
#    return scat

#init_func=init,
ani = matplotlib.animation.FuncAnimation(fig, animate, frames=int(READINGS/FRAMESIZE),
                               interval=100, blit=False, repeat=True)

ani.save('/Users/yuvalmedina/Music/SuperCollider Recordings/' + region + '_' + site + '_' + variable + '_animation.mp4', writer=writer)
