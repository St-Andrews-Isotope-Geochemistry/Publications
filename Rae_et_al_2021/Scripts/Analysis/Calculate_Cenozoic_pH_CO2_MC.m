% do full set of CO2 system calculations for Rae Annual Reviews paper
% this version from 3 Nov 2020 includes Anagnostou 2020 data and Harper
% 2020 data.  Also have corrected age direction of PETM data! 
% before final version may also want to include Raitzsch 2020 in review https://cp.copernicus.org/preprints/cp-2020-96/

tic
%% Load data
root_directory = "./../../";

boron_data_path = root_directory+"/Data/Rae_2021_Boron_Data_Input.xlsx";
d11B_data = readtable(boron_data_path,"Sheet","d11Bdata_byStudy");
d11B_sw = readtable(boron_data_path,'sheet','d11Bsw');

mg_ca_average = readtable(boron_data_path,'Sheet','Mg_Ca_sw');

CCDZT19 = readtable(root_directory+"/Data/ZeebeTyrrell_2019.xlsx");

% Alkenone Ep
% Stoll data
alkenones_anchored = readtable(root_directory+"/Data/Supplements/Rae_2021_Alkenone_CO2.xlsx","Sheet","Anchored");
alkenones_anchored = sortrows(alkenones_anchored,'age');
% Zhang data
alkenones_diffusive = readtable(root_directory+"/Data/Supplements/Rae_2021_Alkenone_CO2.xlsx","Sheet","Diffusive");
alkenones_diffusive = sortrows(alkenones_diffusive,'age');

% alkenone smooth comp
ep_age = [alkenones_anchored.age(alkenones_anchored.age/1000<23); alkenones_diffusive.age(alkenones_diffusive.age/1000>23)];
ep_co2 = [alkenones_anchored.co2(alkenones_anchored.age/1000<23); alkenones_diffusive.co2(alkenones_diffusive.age/1000>23)];
ep_combined = table(ep_age,ep_co2);

ep_combined.smooth_co2 = smooth(ep_combined.ep_age,ep_combined.ep_co2,30,"rlowess");

%% pH
% Exclude any datasets
excluded = d11B_data.exclude>0;
d11B_data = d11B_data(~excluded,:);

% Get rid of what we're calculating
d11B_data.pH(:) = NaN;
d11B_data.alkalinity(:) = NaN;
d11B_data.pCO2(:) = NaN;

% Sort by age to allow smoothing
d11B_data = sortrows(d11B_data,'age');

% Calculate d11B_4
% Fill in calibration c and m
calibrations = readtable(boron_data_path,"Sheet","calibrations","Format","Auto");
% Preallocate space
d11B_data.calibration_gradient = zeros(height(d11B_data),1);
d11B_data.calibration_intercept = zeros(height(d11B_data),1);
for calibration_index = 1:height(calibrations)    
    calibration_boolean = strcmp(d11B_data.calibration,calibrations.name(calibration_index));
    d11B_data.calibration_gradient(calibration_boolean) = calibrations.m(calibration_index);
    d11B_data.calibration_intercept(calibration_boolean) = calibrations.c(calibration_index);
end

% Correct calibration for d11Bsw
% Find d11B_sw for each sample
d11B_data.d11B_sw = interp1(d11B_sw.age,d11B_sw.d11Bsw,d11B_data.age/1000);
d11B_data.d11B_sw_low = interp1(d11B_sw.age,d11B_sw.d11Bsw_low,d11B_data.age/1000);
d11B_data.d11B_sw_high = interp1(d11B_sw.age,d11B_sw.d11Bsw_high,d11B_data.age/1000);

d11B_data.calibration_intercept_sw = d11B_data.calibration_intercept+(39.61-d11B_data.d11B_sw).*(d11B_data.calibration_gradient-1);
d11B_data.calibration_intercept_sw_low = d11B_data.calibration_intercept+(39.61-d11B_data.d11B_sw_low).*(d11B_data.calibration_gradient-1);
d11B_data.calibration_intercept_sw_high = d11B_data.calibration_intercept+(39.61-d11B_data.d11B_sw_high).*(d11B_data.calibration_gradient-1);

d11B_data.d11B_4 = (d11B_data.d11B-d11B_data.calibration_intercept_sw)./d11B_data.calibration_gradient;
d11B_data.d11B_4_low = (d11B_data.d11B-d11B_data.calibration_intercept_sw_low)./d11B_data.calibration_gradient;
d11B_data.d11B_4_high = (d11B_data.d11B-d11B_data.calibration_intercept_sw_high)./d11B_data.calibration_gradient;

% Interpolate calcium and magnesium concentrations
d11B_data.calcium_seawater = interp1(mg_ca_average.age,mg_ca_average.Ca,d11B_data.age/1000);
d11B_data.magnesium_seawater = interp1(mg_ca_average.age,mg_ca_average.Mg,d11B_data.age/1000);

% Set all salinities to 35 
d11B_data.salinity = ones(size(d11B_data,1),1).*35;

% Set all depths to 0m
d11B_data.depth = zeros(size(d11B_data,1),1);

% for CO2 calculation
flag = 8; % specifies use of pH and ALK

alkalinity_offset_points = [  0,175; 
                              5,175; 
                             15,350; 
                             50,600; 
                            100,600];
                        
alkalinity_offset = interp1(alkalinity_offset_points(:,1),alkalinity_offset_points(:,2),d11B_data.age/1000);

d11B_data.alkalinity = repelem(2330,height(d11B_data))'; % Alkalinity at 2330 as in MB15

% Create MyAMI object
myami = MyAMI.MyAMI("Precalculated",true);

%% do Monte Carlo simulation for pH uncertainty 
number_of_simulations = 10000;

pH_monte_carlo = ones(height(d11B_data),number_of_simulations);
CO2_monte_carlo = ones(height(d11B_data),number_of_simulations);

% uncertainties input below are 1 sigma for d11B measurements and
% indicative ~1 sigma for T and S.  Detailed uncertainty evaluation -
% including calibrations, d11Bsw, proper temperature uncertainties etc. -
% is beyond the scope of this work

temperature_uncertainty = 1;
salinity_uncertainty = 0.5;

for simulation_index = 1:number_of_simulations
    temperature_monte_carlo = d11B_data.temperature + randn(height(d11B_data),1)*temperature_uncertainty;
    salinity_monte_carlo = d11B_data.salinity + randn(height(d11B_data),1)*salinity_uncertainty;
    d11B_4_monte_carlo = d11B_data.d11B_4 + randn(height(d11B_data),1).*d11B_data.d11B_2SD./2;
    
    % Calculate pH
    [pH_monte_carlo(:,simulation_index),~] = d11BtopH(d11B_4_monte_carlo,temperature_monte_carlo,salinity_monte_carlo,d11B_data.depth,d11B_data.d11B_sw,d11B_data.magnesium_seawater,d11B_data.calcium_seawater,myami);

    % Uniformly distributed random numbers between -1 and 1
    alkalinity_monte_carlo = d11B_data.alkalinity + (2*rand(height(d11B_data),1)-1).*alkalinity_offset;
    
    % Calculate CO2
    [~,co2_system_monte_carlo] = fncsysKMgCaV2(flag,temperature_monte_carlo,salinity_monte_carlo,d11B_data.depth,pH_monte_carlo(:,simulation_index),NaN,NaN,NaN,alkalinity_monte_carlo,NaN,NaN,d11B_data.magnesium_seawater,d11B_data.calcium_seawater,myami);
    CO2_monte_carlo(:,simulation_index) = co2_system_monte_carlo.XCO2;

end 

%% MC stats
pH_monte_carlo_table = table();
pH_monte_carlo_table.mean = mean(pH_monte_carlo,2);
pH_monte_carlo_table.mode = mode(pH_monte_carlo,2);
pH_monte_carlo_table.median = median(pH_monte_carlo,2);
pH_monte_carlo_table.sd = std(pH_monte_carlo,0,2);
% percentiles: 68% & 95%
pH_monte_carlo_table.percentiles = prctile(pH_monte_carlo,[2.5,16,84,97.5],2);

co2_monte_carlo_table = table();
co2_monte_carlo_table.mean = mean(CO2_monte_carlo,2);
co2_monte_carlo_table.mode = mode(CO2_monte_carlo,2);
co2_monte_carlo_table.median = median(CO2_monte_carlo,2);
co2_monte_carlo_table.sd = std(CO2_monte_carlo,0,2);
% percentiles: 68% & 95%
co2_monte_carlo_table.percentiles = prctile(CO2_monte_carlo,[2.5,16,84,97.5],2);


%% Save results
% save("./Data/Rae_2021_Cenozoic_pH_Monte_Carlo.mat");
toc