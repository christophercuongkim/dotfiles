#!/usr/bin/env python3
import tkinter as tk
import subprocess
import pulsectl

def set_volume(val):
    volume = int(val) / 100
    pulse = pulsectl.Pulse()
    sink = pulse.sink_list()[0]
    pulse.volume_set_all_chans(sink, volume)
    pulse.close()

def get_volume():
    pulse = pulsectl.Pulse()
    sink = pulse.sink_list()[0]
    vol = int(pulse.volume_get_all_chans(sink) * 100)
    pulse.close()
    return vol

root = tk.Tk()
root.title("Volume")
root.geometry("200x50+1000+40")  # position near top right
root.attributes('-topmost', True)

current_vol = get_volume()

slider = tk.Scale(root, from_=0, to=100, orient="horizontal", command=set_volume)
slider.set(current_vol)
slider.pack(fill='x', padx=10, pady=10)

root.mainloop()

