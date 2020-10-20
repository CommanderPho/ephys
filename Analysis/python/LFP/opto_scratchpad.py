## Scratchpad for opto related analyses

import numpy as np
import Python3.Binary as ob
import Analysis.python.LFP.preprocess_data as ppd
import numpy as np
import matplotlib.pyplot as plt
import os
import pandas as pd


## Relevant folder/files
chan_map_file = '/data/GitHub/dibalab_ephys/Channel Maps/MINT/2x32MINT_chan_map_good' # nat laptop location r'C:\Users\Nat\Documents\UM\Working\Opto\Rat613\2x32MINT_chan_map_good.txt'
data_folder = '/data/Working/Opto Project/Rat 613/Rat613Day1/Rat613simtest_2020-08-01_08-47-11/' # nat laptop location r'C:\Users\Nat\Documents\UM\Working\Opto\Rat613\Rat613Day1\Rat613track_2020-08-01_09-21-55'
## Load Data!
chan_map_dict = ob.LoadChannelMapFromText(chan_map_file)
chans_use = np.hstack((np.arange(0, 8), np.arange(16, 24)))  # Use only shank 1 and shank 3
# channels_use = [chan for chan in np.asarray(chan_map_dict['0']['mapping'])[chans_use]]  # not used
Data, Rate = ob.Load(data_folder, ChannelMap=chans_use, Experiment=1, Recording=1, mode='r')
event_data = ppd.load_binary_events()
channels_use = [chan for chan in np.asarray(chan_map_dict['0']['mapping'])[chans_use]]
Data, Rate = ob.Load(data_folder, ChannelMap=channels_use, Experiment=2, Recording=1, mode='r')

## Look at silencing for Jackie place stim day 2
adc_channel = 35  # channel with adc input
on_thresh = 1000000 # on voltage threshold
if not os.environ['LOGNAME'] is not 'nkinsky':
    base_dir = r'C:\Users\Nat\Documents\UM\Working\Opto\Jackie671\placestim_day2\PRE'
    full_raw_path = r'C:\Users\Nat\Documents\UM\Working\Opto\Jackie671\placestim_day2\PRE\Jackie_PRE_2020-10-07_10-48-13\experiment1\recording1\continuous\Intan_Rec._Controller-100.0'
else:
    base_dir = r'/data/Working/Opto/Jackie671/Jackie_placestim_day2/Jackie_PRE_2020-10-07_10-48-13'
    full_raw_path = r'/data/Working/Opto/Jackie671/Jackie_placestim_day2/Jackie_PRE_2020-10-07_10-48-13/experiment1/recording1/continuous/Intan_Rec._Controller-100.0'
    full_spike_path = r'/data/Working/Opto/Jackie671/Jackie_placestim_day2/Jackie_PRE_2020-10-07_10-48-13/experiment1/recording1/continuous/Intan_Rec._Controller-100.0/spyking_circus/Jackie_pre_2020-10-07_nobadchannels/Jackie_pre_2020-10-07.GUI/'
spike_folder = 'Jackie_pre_2020-10-07.GUI'
raw_folder = 'Jackie_PRE_2020-10-07_10-48-13'
data_ds = np.load(full_raw_path)

timestamps = np.load(os.path.join(full_raw_path, 'timestamps.npy'))
time_ds = timestamps[0:-1:24]

on_times = np.where(data_ds[adc_channel] > on_thresh)[0]
off_times = np.where(data_ds[adc_channel] <= on_thresh)[0]

spike_times = np.load(os.path.join(full_spike_path, 'spike_times.npy'))
clusters = np.load(os.path.join(full_spike_path, 'spike_clusters.npy'))
cluster_info = pd.read_csv(os.path.join(full_spike_path, 'cluster_info.tsv'), sep='\t')
good_units = cluster_info['id'][cluster_info['group'] == 'good'].array
