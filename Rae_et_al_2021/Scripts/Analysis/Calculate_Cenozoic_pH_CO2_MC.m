% do full set of CO2 system calculations for Rae Annual Reviews paper
% this version from 3 Nov 2020 includes Anagnostou 2020 data and Harper
% 2020 data.  Also have corrected age direction of PETM data! 
% before final version may also want to include Raitzsch 2020 in review https://cp.copernicus.org/preprints/cp-2020-96/

tic
%% Load data 
boron_data_path = './Data/Rae_2021_Boron_Compilation_Input.xlsx';
d11B_data = readtable(boron_data_path,'sheet','d11Bdata_byStudy');
d11B_sw_JR = readtable('./Data/d11Bsw_compilation.xlsx','sheet','Rae2021comp');

mg_ca_average = readtable('./Data/Mg_Ca_compilation.xlsx','sheet','Matlab_average');

CCDZT19 = readtable('./Data/ZeebeTyrrell_2019.xlsx');

% Alkenone Ep
% Stoll data
HS_Alk = readtable('./Data/Stoll_2019_Alkenone_CO2.xlsx','sheet','Matlab');
HS_Alk = sortrows(HS_Alk,'age');
% Zhang data
YZ_Alk = readtable('./Data/Zhang_2017_Alkenone_CO2.xlsx','sheet','Matlab');
YZ_Alk = sortrows(YZ_Alk,'age');

% alkenone smooth comp
ep_age = [HS_Alk.age(HS_Alk.age/1000<23); YZ_Alk.age(YZ_Alk.age/1000>23)];
ep_co2 = [HS_Alk.CO2(HS_Alk.age/1000<23); YZ_Alk.CO2(YZ_Alk.age/1000>23)];
ep_combined = table(ep_age,ep_co2);

ep_combined.smooth_co2 = smooth(ep_combined.ep_age,ep_combined.ep_co2,30,'rlowess');

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
calibrations = readtable(boron_data_path,'Sheet','calibrations','Format','Auto');
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
d11B_data.d11B_sw = interp1(d11B_sw_JR.age,d11B_sw_JR.d11B_sw,d11B_data.age/1000);
d11B_data.d11B_sw_low = interp1(d11B_sw_JR.age,d11B_sw_JR.d11B_sw_95_low,d11B_data.age/1000);
d11B_data.d11B_sw_high = interp1(d11B_sw_JR.age,d11B_sw_JR.d11B_sw_95_high,d11B_data.age/1000);

d11B_data.calibration_intercept_sw = d11B_data.calibration_intercept+(39.61-d11B_data.d11B_sw).*(d11B_data.calibration_gradient-1);
d11B_data.calibration_intercept_sw_low = d11B_data.calibration_intercept+(39.61-d11B_data.d11B_sw_low).*(d11B_data.calibration_gradient-1);
d11B_data.calibration_intercept_sw_high = d11B_data.calibration_intercept+(39.61-d11B_data.d11B_sw_high).*(d11B_data.calibration_gradient-1);

% Special treatment of Henehan 2019 - where tuning was done with d11B_sw at
% age=same as dataset
% 
% henehan_2019_boolean = strcmp(d11B_data.ref,'Henehan et al., 2019');
% henehan_2019_d11B_sw = d11B_sw_JR.d11B_sw(strcmp(d11B_sw_JR.source,"Henehan2019"));
% d11B_data(henehan_2019_boolean,:).calibration_intercept_sw = d11B_data(henehan_2019_boolean,:).calibration_intercept+(henehan_2019_d11B_sw-d11B_data(henehan_2019_boolean,:).d11B_sw).*(d11B_data(henehan_2019_boolean,:).calibration_gradient-1);
% d11B_data(henehan_2019_boolean,:).calibration_intercept_sw_low = d11B_data(henehan_2019_boolean,:).calibration_intercept+(henehan_2019_d11B_sw-d11B_data(henehan_2019_boolean,:).d11B_sw_low).*(d11B_data(henehan_2019_boolean,:).calibration_gradient-1);
% d11B_data(henehan_2019_boolean,:).calibration_intercept_sw_high = d11B_data(henehan_2019_boolean,:).calibration_intercept+(henehan_2019_d11B_sw-d11B_data(henehan_2019_boolean,:).d11B_sw_high).*(d11B_data(henehan_2019_boolean,:).calibration_gradient-1);

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
% d11B_data.alkalinity_low = d11B_data.alkalinity-alkalinity_offset;
% d11B_data.alkalinity_high = d11B_data.alkalinity+alkalinity_offset;

% Create MyAMI object
myami = MyAMI.MyAMI("Precalculated",true);

%% do Monte Carlo simulation for pH uncertainty 
nmc = 10000;

pHmc = ones(height(d11B_data),nmc);
CO2mc = ones(height(d11B_data),nmc);

% uncertainties input below are 1 sigma for d11B measurements and
% indicative ~1 sigma for T and S.  Detailed uncertainty evaluation -
% including calibrations, d11Bsw, proper temperature uncertainties etc. -
% is beyond the scope of this work

Ter = 1;
Ser = 0.5;

for ii = 1:nmc
Tmc = d11B_data.temperature + randn*Ter;
Smc = d11B_data.salinity + randn*Ser;
d11B_4mc = d11B_data.d11B_4 + randn*d11B_data.d11B_uncertainty./2;

% calculate pH
[pHmc(:,ii),~] = d11BtopH(d11B_4mc,Tmc,Smc,d11B_data.depth,d11B_data.d11B_sw,d11B_data.magnesium_seawater,d11B_data.calcium_seawater,myami);
% [d11B_data.pH_low,d11B_data.pKb_low] = d11BtopH(d11B_data.d11B_4_low,d11B_data.temperature,d11B_data.salinity,d11B_data.depth,d11B_data.d11B_sw_low,d11B_data.magnesium_seawater,d11B_data.calcium_seawater,myami);
% [d11B_data.pH_high,d11B_data.pKb_high] = d11BtopH(d11B_data.d11B_4_high,d11B_data.temperature,d11B_data.salinity,d11B_data.depth,d11B_data.d11B_sw_high,d11B_data.magnesium_seawater,d11B_data.calcium_seawater,myami);

% uniformly distributed random numbers between -1 and 1 using r = a + (b-a).*rand(N,1).
Alkmc = d11B_data.alkalinity + (-1+(1--1)*rand(1,1)).*alkalinity_offset;
% normal dist of random numbers
% Alkmc = d11B_data.alkalinity + randn.*alkalinity_offset;

% calculate CO2 
[~,CO2systmc] = fncsysKMgCaV2(flag,Tmc,Smc,d11B_data.depth,pHmc(:,ii),NaN,NaN,NaN,Alkmc,NaN,NaN,d11B_data.magnesium_seawater,d11B_data.calcium_seawater,myami);
CO2mc(:,ii) = CO2systmc.XCO2;

end 

%% MC stats

pHmctable = table();
pHmctable.mean = mean(pHmc,2);
pHmctable.mode = mode(pHmc,2);
pHmctable.median = median(pHmc,2);
pHmctable.sd = std(pHmc,0,2);
% percentiles: 68% & 95%
pHmctable.percentiles = prctile(pHmc,[2.5 16 84 97.5],2);

CO2mctable = table();
CO2mctable.mean = mean(CO2mc,2);
CO2mctable.mode = mode(CO2mc,2);
CO2mctable.median = median(CO2mc,2);
CO2mctable.sd = std(CO2mc,0,2);
% percentiles: 68% & 95%
CO2mctable.percentiles = prctile(CO2mc,[2.5 16 84 97.5],2);


%% Save results
% output_filename = "./Data/Rae_2021_Cenozoic_CO2_Precalculated.xlsx";
% writetable(d11B_data,output_filename,'Sheet',"d11B_data");
% 
% save("./Data/Rae_2021_Cenozoic_pH_MonteCarlo.mat");
toc