# Weatherstation
A 3d printed diy weather station with anemometer and direction vane. Others sensors will be available soon...

<img align="right" width="297" height="396" src="https://github.com/nliaudat/weatherstation/blob/main/imgs/finished.jpg">

## Abstract

Yet another weather station, but that one use a magnetometer for the direction vane and a rotary encoder with an IR optocoupler for the anemometer.
It runs with an ESP board and [Esphome software](https://esphome.io/)

## Direction Vane

The direction vane use an 1.2$ HMC5883L Magnetometer and a magnet. The simplest is the best !

I've made a [precise calibration script](https://github.com/nliaudat/magnetometer_calibration) if needed to correct hard & soft iron effects with ellipsoid fitting.

<img align="center" width="396" height="297" src="https://github.com/nliaudat/weatherstation/blob/main/imgs/direction_vane_schematics.png">



## Anemometer

The anemometer use a rotary encoder with an 0.6$ IR optocoupler. 

The openscad script output all needed informations to calculate the wind speed except the correction/friction factor which depends on your ball bearing. (mine is 5 and it's a good starting point for futher calibration)

```
[Wind speed in m/s] = 2PI * [anemometer mid cup to axle lenght in m]  * [revolution per seconds]  * [unknown correction factor]
anemometer mid cup to axle lenght = 72.5 mm => 72.5/1000 = 0.0725 m for R
rotary encoder pulse per revolution : 36
revolution per seconds = pulses /36 /60
S = 2PI * 0.0725 * pulses /36 /60 = 0.00021089395
Speed m/s => Km/h : *3.6 => 0.00075921822
[unknown correction factor or friction] : mine is ~5 => 0.00075921822 *5 = 0.0037960911 

You must paste that value in "pulse_meter" section of esphome.yaml
    filters:
      - multiply: 0.0037960911 
```

<img align="center" width="396" height="297" src="https://github.com/nliaudat/weatherstation/blob/main/imgs/anemometer_schematics.png">


