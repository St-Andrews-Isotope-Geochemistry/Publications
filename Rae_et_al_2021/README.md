# Materials and code associated with Rae et al., 2021

## Citation
James W.B. Rae, Yi Ge Zhang, Xiaoqing Liu, Gavin L. Foster, Heather M. Stoll and Ross D.M. Whiteford, **2021**, _Atmospheric CO_<sub>2</sub> _over the last 66 million years from marine archives_. https://doi.org/10.1146/annurev-earth-082420-063026

## How to download
Either download from [this page](https://github.com/St-Andrews-Isotope-Geochemistry/Private_Publications/tree/Rae_et_al_2021) using the online interface or use the following git commands:
```
git init
git remote add origin https://github.com/St-Andrews-Isotope-Geochemistry/Publications
git fetch origin Rae_et_al_2021
git checkout Rae_et_al_2021
git submodule update --recursive --init
```

You may need to install git lfs:
```
git lfs install
```

## Contents
### Supplement
Files included in the paper supplement are found [here](./Data/Supplements/).

### Data
Other data files are found [here](./Data/)

### Scripts
Code files are separated into [analysis](./Scripts/Analysis/) and [plots](./Scripts/Plots).
Analysis contains two files, one to perform calculations of &delta;^{11}B to pH and atmospheric CO_2 concentration (using various assumptions of a second carbonate system parameter) and another to perform a Monte Carlo simulation for an estimation of the uncertainties.

Before you run any analyses, you'll need to add the Dependencies folder to the Matlab path.

The Plots folder contains a script for most of the Figures in the manuscript.

### Functions
The Functions folder contains the calculation routine for converting &delta;^{11}B to pH.

### Dependencies
Additional functions to facilitate the plots and CO_2 calculations.
The CO2_Systematics folder contains a submodule for performing ocean carbonate chemistry calculations. This is an updated version of [csys](https://www.soest.hawaii.edu/oceanography/faculty/zeebe_files/CO2_System_in_Seawater/csys.html) which uses the [MyAMI model](https://github.com/St-Andrews-Isotope-Geochemistry/MyAMI) for equilibrium coefficients, and has a few other minor updates.

### Figures
This folder contains the image files for generated plots as both PDF and PNG files.

## Quick Links
- [Figure 3](#figure-3)
- [Figure 4](#figure-4)
- [Figure 5](#figure-5)
- [Figure 6](#figure-6)
- [Figure 7](#figure-7)
- [Figure 8](#figure-8)

## Figures
### Figure 3
  ![Figure 3][figure3]
### Figure 4
  ![Figure 4][figure4]  
### Figure 5
  ![Figure 5][figure5]
### Figure 6
  ![Figure 6][figure6]
### Figure 7
  ![Figure 7][figure7]
### Figure 8
  ![Figure 8][figure8]

Some figures are slightly different to those in the manuscript due to the copy editing process.

## Dependencies
### RGB
rgb.m is used here to provide colours.

This program is public domain and may be distributed freely.
Author: Kristjn Jnasson, Dept. of Computer Science, University of Iceland (jonasson@hi.is). June 2009.

### Submodules
CO2_Systematics is a submodule found [here](https://github.com/St-Andrews-Isotope-Geochemistry/CO2_Systematics). For this paper the 'script' branch was used, which is a version of csys which has been updated to use equilibrium coefficients for carbonate chemistry from the [MyAMI model](https://github.com/St-Andrews-Isotope-Geochemistry/MyAMI).

[figure3]: ./Figures/DIC_Alkalinity_Contours.png "Relationships between key components of the CO2 system as a function of the master variables, alkalinity and DIC"
[figure4]: ./Figures/Cenozoic_d18O_Ep_CoccoLength_b_CO2.png "Updated CO2 reconstructions from alkenone &delta;13C"
[figure5]: ./Figures/Cenozoic_d18O_d11B_d11Bsw_pH_CO2.png "Boron isotope derived estimates of pH and CO2"
[figure6]: ./Figures/Cenozoic_SurfaceTemperature_SeaLevel_CO2.png "Cenozoic CO2 and global climate"
[figure7]: ./Figures/Cenozoic_CO2_dTemperature.png "Relationship between CO2 and climate over the Cenozoic"
[figure8]: ./Figures/Cenozoic_CO2_SSPs.png "Paleo CO2 context for future CO2 change scenarios"
