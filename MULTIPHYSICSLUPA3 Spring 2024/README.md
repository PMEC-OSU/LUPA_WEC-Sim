# LUPA WEC-Sim Model — Spring 2024

This is the ReadMe for the LUPA WEC-Sim model based on the experimental testing in **Spring 2024** at the O.H. Hinsdale Wave Research Laboratory in Corvallis, OR, USA. This was the third LUPA testing and the only configuration tested was the two-body, heave-only LUPA configuration. For information on the other two configurations, see **LUPA Fall 2022** or **TEAMERLUPA Fall 2023** (for updated spar design & 6DOF model).

Two heave plate diameters were tested, 0.9 m and 1.14 m.
Each configuration has its own wecSimInputFile, Simulink file, and userDefinedFunctions post processing code in folders named 'TwoBodyHeaveOnly_D0_9m' and 'TwoBodyHeaveOnly_D1_14m' respectively. 

The model references:
- `.stl` files in the `geometry` folder
- `.h5` files in the `hydroData` folder
- WAMIT input and output files (also provided)

## Basic Details

- **Water depth:** 2.78 meters
- **Physical test dates:** ~04/30/2024 - 05/16/2024
- **Changes from LUPA Fall 2022:** spar design, heave plate diameters, water depth

## Software Versions

- **WEC-Sim version:** v6.1.2  
- **MATLAB version:** R2023b
