% do full set of CO2 system calculations for Rae Annual Reviews paper
% this version from 31 March 2021 uses final data files for publication

tic
%% Load data 
boron_data_path = './../../Data/Rae_2021_Boron_DataInput.xlsx';
d11B_data = readtable(boron_data_path,'sheet','d11Bdata_byStudy');
d11B_sw = readtable(boron_data_path,'sheet','d11Bsw');

mg_ca_average = readtable(boron_data_path,'sheet','Mg_Ca_sw');

CCDZT19 = readtable('./../../Data/ZeebeTyrrell_2019.xlsx');

% Alkenone Ep
% Anchored approach
Alk_anch = readtable('./../../Data/Rae_2021_Alkenone_CO2.xlsx','sheet','anchored');
Alk_anch = sortrows(Alk_anch,'age');
% Diffusive approach
Alk_diff = readtable('./../../Data/Rae_2021_Alkenone_CO2.xlsx','sheet','diffusive');
Alk_diff = sortrows(Alk_diff,'age');

% alkenone comp
ep_age = [Alk_anch.age(Alk_anch.age/1000<23); Alk_diff.age(Alk_diff.age/1000>23)];
ep_co2 = [Alk_anch.co2(Alk_anch.age/1000<23); Alk_diff.co2(Alk_diff.age/1000>23)];
ep_combined = table(ep_age,ep_co2);

%% pH
% Exclude any datasets
excluded = d11B_data.exclude>0;
d11B_data = d11B_data(~excluded,:);

% Sort by age to allow smoothing
d11B_data = sortrows(d11B_data,'age');

% Interpolate calcium and magnesium concentrations
d11B_data.calcium_seawater = interp1(mg_ca_average.age,mg_ca_average.Ca,d11B_data.age/1000);
d11B_data.magnesium_seawater = interp1(mg_ca_average.age,mg_ca_average.Mg,d11B_data.age/1000);

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

% Find d11B_sw for each sample
d11B_data.d11B_sw = interp1(d11B_sw.age,d11B_sw.d11Bsw,d11B_data.age/1000);

% Correct calibration for d11Bsw
d11B_data.calibration_intercept_sw = d11B_data.calibration_intercept+(39.61-d11B_data.d11B_sw).*(d11B_data.calibration_gradient-1);
d11B_data.d11B_4 = (d11B_data.d11B-d11B_data.calibration_intercept_sw)./d11B_data.calibration_gradient;

% Set all salinities to 35 
d11B_data.salinity = ones(size(d11B_data,1),1).*35;
% Set all depths to 0m
d11B_data.depth = zeros(size(d11B_data,1),1);

% Create MyAMI object
myami = MyAMI.MyAMI("Precalculated",true);

% calculate pH
[d11B_data.pH,d11B_data.pKb] = d11BtopH(d11B_data.d11B_4,d11B_data.temperature,d11B_data.salinity,d11B_data.depth,d11B_data.d11B_sw,d11B_data.magnesium_seawater,d11B_data.calcium_seawater,myami);


%% CO2
output_to_save = ["CO2","HCO3","CO3","DIC","ALK","PCO2","XCO2","H","pH","Omc"];
output_to_save_as = ["co2","hco3","co3","dic","alkalinity","pco2","xco2","h","pH","saturation_state"];


%% CONSTANT ALKALINITY % 
flag = 8; % specifies use of pH and ALK
d11B_data_alkalinity = d11B_data;
d11B_data_alkalinity_low = d11B_data;
d11B_data_alkalinity_high = d11B_data;

% expanding range of alkalinity back through time
alkalinity_offset_points = [  0,175; 
                              5,175; 
                             15,350; 
                             50,600; 
                            100,600];
                        
alkalinity_offset = interp1(alkalinity_offset_points(:,1),alkalinity_offset_points(:,2),d11B_data_alkalinity.age/1000);

d11B_data_alkalinity.alkalinity = repelem(2330,height(d11B_data_alkalinity))'; % Central alkalinity of 2330
d11B_data_alkalinity_low.alkalinity = d11B_data_alkalinity.alkalinity-alkalinity_offset;
d11B_data_alkalinity_high.alkalinity = d11B_data_alkalinity.alkalinity+alkalinity_offset;

[~,alkalinity_results{1}] = fncsysKMgCaV2(flag,d11B_data_alkalinity_low.temperature,d11B_data_alkalinity_low.salinity,d11B_data_alkalinity_low.depth,d11B_data_alkalinity_low.pH,NaN,NaN,NaN,d11B_data_alkalinity_low.alkalinity,NaN,NaN,d11B_data_alkalinity_low.magnesium_seawater,d11B_data_alkalinity_low.calcium_seawater,myami);
[~,alkalinity_results{2}] = fncsysKMgCaV2(flag,d11B_data_alkalinity.temperature,d11B_data_alkalinity.salinity,d11B_data_alkalinity.depth,d11B_data_alkalinity.pH,NaN,NaN,NaN,d11B_data_alkalinity.alkalinity,NaN,NaN,d11B_data_alkalinity.magnesium_seawater,d11B_data_alkalinity.calcium_seawater,myami);
[~,alkalinity_results{3}] = fncsysKMgCaV2(flag,d11B_data_alkalinity_high.temperature,d11B_data_alkalinity_high.salinity,d11B_data_alkalinity_high.depth,d11B_data_alkalinity_high.pH,NaN,NaN,NaN,d11B_data_alkalinity_high.alkalinity,NaN,NaN,d11B_data_alkalinity_high.magnesium_seawater,d11B_data_alkalinity_high.calcium_seawater,myami);

d11B_alkalinity_results{1} = d11B_data_alkalinity_low;
d11B_alkalinity_results{2} = d11B_data_alkalinity;
d11B_alkalinity_results{3} = d11B_data_alkalinity_high;

for alkalinity_index = 1:3
    for output_index = 1:numel(output_to_save)
        d11B_alkalinity_results{alkalinity_index}.(output_to_save_as(output_index)) = alkalinity_results{alkalinity_index}.(output_to_save(output_index));
    end
end


%% CONSTANT ALK, d11Bsw low and high % 
flag = 8; % specifies use of pH and ALK

% d11Bsw low
d11B_data_d11Bswlow = d11B_data;
d11B_data_d11Bswlow = removevars(d11B_data_d11Bswlow,{'d11B_sw','calibration_intercept_sw','d11B_4','pH','pKb'});
d11B_data_d11Bswlow.d11B_swlow = interp1(d11B_sw.age,d11B_sw.d11BswLow,d11B_data.age/1000);
% adjust calibration
d11B_data_d11Bswlow.calibration_intercept_swlow = d11B_data_d11Bswlow.calibration_intercept+(39.61-d11B_data_d11Bswlow.d11B_swlow).*(d11B_data_d11Bswlow.calibration_gradient-1);
% calculate borate
d11B_data_d11Bswlow.d11B_4_swlow = (d11B_data_d11Bswlow.d11B-d11B_data_d11Bswlow.calibration_intercept_swlow)./d11B_data_d11Bswlow.calibration_gradient;
% calculate pH
[d11B_data_d11Bswlow.pH_swlow,d11B_data_d11Bswlow.pKb] = d11BtopH(d11B_data_d11Bswlow.d11B_4_swlow,d11B_data_d11Bswlow.temperature,d11B_data_d11Bswlow.salinity,d11B_data_d11Bswlow.depth,d11B_data_d11Bswlow.d11B_swlow,d11B_data_d11Bswlow.magnesium_seawater,d11B_data_d11Bswlow.calcium_seawater,myami);
% calculate CO2 from this pH and alkalinity
d11B_data_d11Bswlow.alkalinity = repelem(2330,height(d11B_data_d11Bswlow))'; % Central alkalinity of 2330
[~,d11Bswlow_results] = fncsysKMgCaV2(flag,d11B_data_d11Bswlow.temperature,d11B_data_d11Bswlow.salinity,d11B_data_d11Bswlow.depth,d11B_data_d11Bswlow.pH_swlow,NaN,NaN,NaN,d11B_data_d11Bswlow.alkalinity,NaN,NaN,d11B_data_d11Bswlow.magnesium_seawater,d11B_data_d11Bswlow.calcium_seawater,myami);
d11B_d11Bswlow_results = d11B_data_d11Bswlow;

for output_index = 1:numel(output_to_save)
    d11B_d11Bswlow_results.(output_to_save_as(output_index)) = d11Bswlow_results.(output_to_save(output_index));
end
d11B_d11Bswlow_results.pH_swlow = d11B_d11Bswlow_results.pH;
d11B_d11Bswlow_results = removevars(d11B_d11Bswlow_results,{'pH'});

% d11Bsw high
d11B_data_d11Bswhigh = d11B_data;
d11B_data_d11Bswhigh = removevars(d11B_data_d11Bswhigh,{'d11B_sw','calibration_intercept_sw','d11B_4','pH','pKb'});
d11B_data_d11Bswhigh.d11B_swhigh = interp1(d11B_sw.age,d11B_sw.d11BswHigh,d11B_data.age/1000);
% adjust calibration
d11B_data_d11Bswhigh.calibration_intercept_swhigh = d11B_data_d11Bswhigh.calibration_intercept+(39.61-d11B_data_d11Bswhigh.d11B_swhigh).*(d11B_data_d11Bswhigh.calibration_gradient-1);
% calculate borate
d11B_data_d11Bswhigh.d11B_4_swhigh = (d11B_data_d11Bswhigh.d11B-d11B_data_d11Bswhigh.calibration_intercept_swhigh)./d11B_data_d11Bswhigh.calibration_gradient;
% calculate pH
[d11B_data_d11Bswhigh.pH_swhigh,d11B_data_d11Bswhigh.pKb] = d11BtopH(d11B_data_d11Bswhigh.d11B_4_swhigh,d11B_data_d11Bswhigh.temperature,d11B_data_d11Bswhigh.salinity,d11B_data_d11Bswhigh.depth,d11B_data_d11Bswhigh.d11B_swhigh,d11B_data_d11Bswhigh.magnesium_seawater,d11B_data_d11Bswhigh.calcium_seawater,myami);
% calculate CO2 from this pH and alkalinity
d11B_data_d11Bswhigh.alkalinity = repelem(2330,height(d11B_data_d11Bswhigh))'; % Central alkalinity of 2330
[~,d11Bswhigh_results] = fncsysKMgCaV2(flag,d11B_data_d11Bswhigh.temperature,d11B_data_d11Bswhigh.salinity,d11B_data_d11Bswhigh.depth,d11B_data_d11Bswhigh.pH_swhigh,NaN,NaN,NaN,d11B_data_d11Bswhigh.alkalinity,NaN,NaN,d11B_data_d11Bswhigh.magnesium_seawater,d11B_data_d11Bswhigh.calcium_seawater,myami);
d11B_d11Bswhigh_results = d11B_data_d11Bswhigh;

for output_index = 1:numel(output_to_save)
    d11B_d11Bswhigh_results.(output_to_save_as(output_index)) = d11Bswhigh_results.(output_to_save(output_index));
end
d11B_d11Bswhigh_results.pH_swlow = d11B_d11Bswhigh_results.pH;
d11B_d11Bswhigh_results = removevars(d11B_d11Bswhigh_results,{'pH'});


%% CONSTANT DIC % 
flag = 9; % specifies use of pH and DIC
d11B_data_dic = d11B_data;

[~,dic_results] = fncsysKMgCaV2(flag,d11B_data_dic.temperature,d11B_data_dic.salinity,d11B_data_dic.depth,d11B_data_dic.pH,NaN,NaN,NaN,NaN,repelem(1900,height(d11B_data_dic)),NaN,d11B_data_dic.magnesium_seawater,d11B_data_dic.calcium_seawater,myami);
d11B_dic_results = d11B_data_dic;

for output_index = 1:numel(output_to_save)
    d11B_dic_results.(output_to_save_as(output_index)) = dic_results.(output_to_save(output_index));
end


%% CONSTANT OMEGA %
% get Kspc for this interval - flag and alk doesn't matter, just want Kspc
flag = 8;
d11B_data_Kspc = d11B_data;
[~,results_table] = fncsysKMgCaV2(flag,d11B_data_Kspc.temperature,d11B_data_Kspc.salinity,d11B_data_Kspc.depth,d11B_data_Kspc.pH,NaN,NaN,NaN,repelem(2100,height(d11B_data_Kspc)),NaN,NaN,d11B_data_Kspc.magnesium_seawater,d11B_data_Kspc.calcium_seawater,myami);

d11B_data_Kspc.Kspc(:) = results_table.Kspc;

d11B_data_omega = d11B_data_Kspc;
d11B_data_omega_ca_low = d11B_data_Kspc;
d11B_data_omega_ca_low.calcium_seawater = interp1(mg_ca_average.age,mg_ca_average.Ca-mg_ca_average.Ca_down,d11B_data_omega_ca_low.age/1000);
d11B_data_omega_ca_high = d11B_data_Kspc;
d11B_data_omega_ca_high.calcium_seawater = interp1(mg_ca_average.age,mg_ca_average.Ca+mg_ca_average.Ca_up,d11B_data_omega_ca_high.age/1000);

% now calculate CO2 
omega_input = [5,6.5,8];
omega_results = cell(numel(omega_input),3);
for omega_index = 1:numel(omega_input)
    d11B_data_omega_ca_low.co3 = omega_input(omega_index)./(d11B_data_omega_ca_low.calcium_seawater./1000).*d11B_data_omega_ca_low.Kspc*10^6; %umol/kg
    d11B_data_omega.co3 = omega_input(omega_index)./(d11B_data_omega.calcium_seawater./1000).*d11B_data_Kspc.Kspc*10^6; %umol/kg
    d11B_data_omega_ca_high.co3 = omega_input(omega_index)./(d11B_data_omega_ca_high.calcium_seawater./1000).*d11B_data_omega_ca_high.Kspc*10^6; %umol/kg

    flag = 7; % CO3 and pH    
    [~,omega_results{omega_index,1}] = fncsysKMgCaV2(flag,d11B_data_omega_ca_low.temperature,d11B_data_omega_ca_low.salinity,d11B_data_omega_ca_low.depth,d11B_data_omega_ca_low.pH,NaN,NaN,d11B_data_omega_ca_low.co3,NaN,NaN,NaN,d11B_data_omega_ca_low.magnesium_seawater,d11B_data_omega_ca_low.calcium_seawater,myami);
    [~,omega_results{omega_index,2}] = fncsysKMgCaV2(flag,d11B_data_omega.temperature,d11B_data_omega.salinity,d11B_data_omega.depth,d11B_data_omega.pH,NaN,NaN,d11B_data_omega.co3,NaN,NaN,NaN,d11B_data_omega.magnesium_seawater,d11B_data_omega.calcium_seawater,myami);
    [~,omega_results{omega_index,3}] = fncsysKMgCaV2(flag,d11B_data_omega_ca_high.temperature,d11B_data_omega_ca_high.salinity,d11B_data_omega_ca_high.depth,d11B_data_omega_ca_high.pH,NaN,NaN,d11B_data_omega_ca_high.co3,NaN,NaN,NaN,d11B_data_omega_ca_high.magnesium_seawater,d11B_data_omega_ca_high.calcium_seawater,myami);    
end

for row_index = 1:size(omega_results,1)
    d11B_omega_results{row_index,1} = d11B_data_omega_ca_low;
    d11B_omega_results{row_index,2} = d11B_data_omega;
    d11B_omega_results{row_index,3} = d11B_data_omega_ca_high;
    
    for column_index = 1:3
        for output_index = 1:numel(output_to_save)
            d11B_omega_results{row_index,column_index}.(output_to_save_as(output_index)) = omega_results{row_index,column_index}.(output_to_save(output_index));
        end
    end
end

omega_results{1}.omega_error = ((d11B_data_omega_ca_low.calcium_seawater./1000).*omega_results{1}.CO3)./(omega_results{1}.Kspc*10^6); %umol/kg
omega_results{3}.omega_error = ((d11B_data_omega_ca_high.calcium_seawater./1000).*omega_results{3}.CO3)./(omega_results{3}.Kspc*10^6); %umol/kg


%% CCD-based CO3 - ZT19
% use version scaled to modern CO3 of 275 and interpolate to find values at
% the ages we have
flag = 7; % specifies use of pH and CO3
d11B_data_CCD = d11B_data;
d11B_data_CCD.co3 = interp1(CCDZT19.age,CCDZT19.CO3_CCD_Mod275,d11B_data_CCD.age/1000);

[~,ccd_results] = fncsysKMgCaV2(flag,d11B_data_CCD.temperature,d11B_data_CCD.salinity,d11B_data_CCD.depth,d11B_data_CCD.pH,NaN,NaN,d11B_data_CCD.co3,NaN,NaN,NaN,d11B_data_CCD.magnesium_seawater,d11B_data_CCD.calcium_seawater,myami);
d11B_ccd_results = d11B_data_CCD;

for output_index = 1:numel(output_to_save)
    d11B_ccd_results.(output_to_save_as(output_index)) = ccd_results.(output_to_save(output_index));
end


%% re-calculate CO2 system w Ep smooth
% smooth alkenone CO2 
ep_combined.smooth_co2 = smooth(ep_combined.ep_age,ep_combined.ep_co2,30,'rlowess');

% find smoothed alkenone CO2 where we have d11B data
d11B_data_ep = d11B_data;
% limit dataset to where we have alkenone data!
d11B_data_ep = d11B_data_ep((d11B_data_ep.age/1000)<37,:);
d11B_data_ep.CO2 = interp1(ep_combined.ep_age,ep_combined.smooth_co2,d11B_data_ep.age);

flag = 101; % specifies use of pH and pCO2
[~,ep_results] = fncsysKMgCaV2(flag,d11B_data_ep.temperature,d11B_data_ep.salinity,d11B_data_ep.depth,d11B_data_ep.pH,NaN,NaN,NaN,NaN,NaN,d11B_data_ep.CO2,d11B_data_ep.magnesium_seawater,d11B_data_ep.calcium_seawater,myami);
d11B_ep_results = d11B_data_ep;

for output_index = 1:numel(output_to_save)
    d11B_ep_results.(output_to_save_as(output_index)) = ep_results.(output_to_save(output_index));
end

%% correct ODP 999 disequilibrium for all treatments
all_results = [d11B_alkalinity_results,{d11B_d11Bswlow_results},{d11B_d11Bswhigh_results},{d11B_dic_results},d11B_omega_results(:)',{d11B_ccd_results},{d11B_ep_results}];
for result_index = 1:numel(all_results)
    result = all_results(result_index);
    
    result{1}.disequilibrium_correction = zeros(height(result{1}),1);
    result{1}.disequilibrium_correction(strcmp(result{1}.site,'999A')|strcmp(result{1}.site,'999')) = -21;
    result{1}.uncorrected_xco2 = result{1}.xco2;
    result{1}.uncorrected_pco2 = result{1}.pco2;
    result{1}.xco2 = result{1}.xco2 + result{1}.disequilibrium_correction;
    result{1}.pco2 = result{1}.pco2 + result{1}.disequilibrium_correction;
    
    all_results(result_index) = result;
end
d11B_alkalinity_results = all_results(1:3);
d11B_d11Bswlow_results = all_results{4};
d11B_d11Bswhigh_results = all_results{5};
d11B_dic_results = all_results{6};
d11B_omega_results = reshape(all_results(7:15),3,3);
d11B_ccd_results = all_results{16};
d11B_ep_results = all_results{17};

%% Save results
output_filename = "./../../Data/Rae_2021_Cenozoic_CO2_Precalculated.xlsx";
writetable(d11B_data,output_filename,'Sheet',"d11B_data");

writetable(d11B_alkalinity_results{2},output_filename,'Sheet',"alkalinity");
writetable(d11B_alkalinity_results{1},output_filename,'Sheet',"alkalinity_low");
writetable(d11B_alkalinity_results{3},output_filename,'Sheet',"alkalinity_high");

writetable(d11B_d11Bswlow_results,output_filename,'Sheet',"alkalinity_d11Bswlow");
writetable(d11B_d11Bswhigh_results,output_filename,'Sheet',"alkalinity_d11Bswhigh");

writetable(d11B_dic_results,output_filename,'Sheet',"dic");

writetable(d11B_omega_results{1,2},output_filename,'Sheet',"omega5");
writetable(d11B_omega_results{2,2},output_filename,'Sheet',"omega65");
writetable(d11B_omega_results{3,2},output_filename,'Sheet',"omega8");

writetable(d11B_ccd_results,output_filename,'Sheet',"ccd");

writetable(d11B_ep_results,output_filename,'Sheet',"ep_results");

writetable(d11B_omega_results{1,3},output_filename,'Sheet',"omega5_high_ca");
writetable(d11B_omega_results{2,3},output_filename,'Sheet',"omega65_high_ca");
writetable(d11B_omega_results{3,3},output_filename,'Sheet',"omega8_high_ca");
writetable(d11B_omega_results{1,1},output_filename,'Sheet',"omega5_low_ca");
writetable(d11B_omega_results{2,1},output_filename,'Sheet',"omega65_low_ca");
writetable(d11B_omega_results{3,1},output_filename,'Sheet',"omega8_low_ca");

save("./../../Data/Rae_2021_Cenozoic_CO2_Workspace.mat");
toc