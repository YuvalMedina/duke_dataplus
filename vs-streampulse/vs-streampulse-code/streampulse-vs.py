#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Jun  5 10:08:04 2019

@author: vs
"""
# import libraries
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# read file and convert dateTime column into datetime format
df = pd.read_csv('flagged_sites.csv', sep=',', encoding='latin_1', infer_datetime_format=True)
df.dateTimeUTC = pd.to_datetime(df.dateTimeUTC)


df1 = df.copy() # making a copy of the original dataframe
df1 = df.drop(columns=['flagID', 'flagComment']) # dropping comments column for range checking
sites = df1.siteID.unique() # creating array of all site names


#save each siteID in separate wide dataframe with each variable as column
sites_df = dict()
for site in sites:
    data = df1.loc[df1['siteID']==site]
    data1 = data.pivot_table(index='dateTimeUTC', columns='variable', values='value')
    norm_data1 = (data1 - data1.mean())/data1.std()
    sites_df.update({site:norm_data1})


# plot boxplot for each variable for every siteID
plt.figure(figsize=(30, 20))

plt.subplot(4,7,1)
sites_df['LV'].boxplot(vert=0)
plt.title('LV')

plt.subplot(4,7,2)
sites_df['OC'].boxplot(vert=0)
plt.title('OC')

plt.subplot(4,7,3)
sites_df['WB'].boxplot(vert=0)
plt.title('WB')

plt.subplot(4,7,4)
sites_df['Eno'].boxplot(vert=0)
plt.title('Eno')

plt.subplot(4,7,5)
sites_df['UEno'].boxplot(vert=0)
plt.title('UEno')

plt.subplot(4,7,6)
sites_df['Mud'].boxplot(vert=0)
plt.title('Mud')

plt.subplot(4,7,7)
sites_df['NHC'].boxplot(vert=0)
plt.title('NHC')

plt.subplot(4,7,8)
sites_df['UNHC'].boxplot(vert=0)
plt.title('UNHC')

plt.subplot(4,7,9)
sites_df['Stony'].boxplot(vert=0)
plt.title('Stony')

plt.subplot(4,7,10)
sites_df['QS'].boxplot(vert=0)
plt.title('QS')

plt.subplot(4,7,11)
sites_df['BEC'].boxplot(vert=0)
plt.title('BEC')

plt.subplot(4,7,12)
sites_df['BRW'].boxplot(vert=0)
plt.title('BRW')

plt.subplot(4,7,13)
sites_df['BUNN'].boxplot(vert=0)
plt.title('BUNN')

plt.subplot(4,7,14)
sites_df['ICHE2700'].boxplot(vert=0)
plt.title('ICHE2700')

plt.subplot(4,7,15)
sites_df['NR1000'].boxplot(vert=0)
plt.title('NR1000')

plt.subplot(4,7,16)
sites_df['SF700'].boxplot(vert=0)
plt.title('SF700')

plt.subplot(4,7,17)
sites_df['SF2500'].boxplot(vert=0)
plt.title('SF2500')

plt.subplot(4,7,18)
sites_df['SF2800'].boxplot(vert=0)
plt.title('SF2800')

plt.subplot(4,7,19)
sites_df['WS1500'].boxplot(vert=0)
plt.title('WS1500')

plt.subplot(4,7,20)
sites_df['MV'].boxplot(vert=0)
plt.title('MV')

plt.subplot(4,7,21)
sites_df['Icacos'].boxplot(vert=0)
plt.title('Icacos')

plt.subplot(4,7,22)
sites_df['ColeMill'].boxplot(vert=0)
plt.title('ColeMill')

plt.subplot(4,7,23)
sites_df['NeuseDown2A'].boxplot(vert=0)
plt.title('NeuseDown2A')

plt.subplot(4,7,24)
sites_df['Potash'].boxplot(vert=0)
plt.title('Potash')

plt.subplot(4,7,25)
sites_df['Sisimiut'].boxplot(vert=0)
plt.title('Sisimiut')

plt.subplot(4,7,26)
sites_df['Sióimiut'].boxplot(vert=0)
plt.title('Sióimiut')

plt.subplot(4,7,27)
sites_df['Cameo'].boxplot(vert=0)
plt.title('Cameo')

plt.subplot(4,7,28)
sites_df['Simms'].boxplot(vert=0)
plt.title('Simms')


plt.tight_layout()
plt.show()

# creating boxplots for each variable by siteID

df2 = df.copy() # making a second copy of the original dataframe
df2 = df.drop(columns=['flagID', 'flagComment']) # dropping comments column for range checking
sites = df1.siteID.unique() # creating array of all site names

