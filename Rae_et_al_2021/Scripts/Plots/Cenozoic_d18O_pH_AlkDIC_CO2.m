% Plot Cenozoic d18O, pH, alkalinity/DIC and CO2
%% Load data
root_directory = "./../../";

% d18O
westerhold2020 = readtable(root_directory+"/Data/Westerhold_2020_d18O.xlsx",'Sheet','Matlab','Format','Auto');

Epochs = readtable(root_directory+"/Data/Cenozoic_Epochs.xlsx");

% CO2
co2_sheet_names = ["ccd","Omega65","Omega5","Omega8","dic","alkalinity_high","alkalinity_low","alkalinity"];
for sheet_index = 1:numel(co2_sheet_names)
    co2_data{sheet_index} = readtable(root_directory+"/Data/Rae_2021_Cenozoic_CO2_Precalculated.xlsx","Sheet",co2_sheet_names(sheet_index));
end

ca_mg = readtable(root_directory+"/Data/Supplements/Rae_2021_Boron_pH_CO2_CO2system.xlsx",'sheet','Mg_Ca_sw');

%% Analyse the data
westerhold2020 = westerhold2020(~isnan(westerhold2020.age) & ~isnan(westerhold2020.d18O),:);
westerhold2020 = sortrows(westerhold2020);
westerhold2020.d18O_smooth = smooth(westerhold2020.age,westerhold2020.d18O_corrected,30,'loess');

% Test influence of Ks
test = table();
test.age = [0,10,20,32,42.5,53.5]';
test.depth = 0.*ones(height(test),1);
test.temperature = [26,27,29,29,31,33]';
test.salinity = 35.*ones(height(test),1);

test.alkalinity = 2330.*ones(height(test),1);
test.dic = [1900,2010,2049,2124,2148,2178]';

test.magnesium_seawater = interp1(ca_mg.age,ca_mg.Mg,test.age);
test.calcium_seawater = interp1(ca_mg.age,ca_mg.Ca,test.age);

flag1 = 15; % specifies use of ALK & DIC

myami = MyAMI.MyAMI("Precalculated",true);
[~,test_results] = fncsysKMgCaV2(flag1,test.temperature,test.salinity,test.depth,NaN,NaN,NaN,NaN,test.alkalinity,test.dic,NaN,test.magnesium_seawater,test.calcium_seawater,myami);

test_temperature_25 = test;
test_temperature_25.temperature = 25.*ones(height(test),1);
[~,test_temperature_25_results] = fncsysKMgCaV2(flag1,test_temperature_25.temperature,test_temperature_25.salinity,test_temperature_25.depth,NaN,NaN,NaN,NaN,test_temperature_25.alkalinity,test_temperature_25.dic,NaN,test_temperature_25.magnesium_seawater,test_temperature_25.calcium_seawater,myami);

test_magnesium_55 = test_temperature_25;
test_magnesium_55.magnesium_seawater = 55.1.*ones(height(test),1);
[~,test_magnesium_55_results] = fncsysKMgCaV2(flag1,test_magnesium_55.temperature,test_magnesium_55.salinity,test_magnesium_55.depth,NaN,NaN,NaN,NaN,test_magnesium_55.alkalinity,test_magnesium_55.dic,NaN,test_magnesium_55.magnesium_seawater,test_magnesium_55.calcium_seawater,myami);

test_ca_10 = test_magnesium_55;
test_ca_10.calcium_seawater = 10.6.*ones(height(test),1);
[~,test_ca_10_results] = fncsysKMgCaV2(flag1,test_ca_10.temperature,test_ca_10.salinity,test_ca_10.depth,NaN,NaN,NaN,NaN,test_ca_10.alkalinity,test_ca_10.dic,NaN,test_ca_10.magnesium_seawater,test_ca_10.calcium_seawater,myami);

%% Make the figure
age_limits = [0,70];
age_ticks = 0:10:70;

% Normal - time going right to left or
% Reverse - time going left to right
% age_direction = 'normal';
age_direction = 'Reverse';

clf
figure_handle = figure(1);
figure_handle.Color = "White";
number_of_plots = 4; % This is the number of axes you would like
plot_handles = stackplot(number_of_plots,"figure_handle",figure_handle);

%% d18O
current_plot_index = number_of_plots;
hold(plot_handles(current_plot_index),'on');

plot(westerhold2020.age,westerhold2020.d18O_corrected,'x','Color',rgb('LightGray'),'MarkerSize',2,'Parent',plot_handles(current_plot_index))
plot(westerhold2020.age,westerhold2020.d18O_smooth,'-','Color',rgb('Black'),'LineWidth',1,'Parent',plot_handles(current_plot_index))

set(plot_handles(current_plot_index),'YDir','Reverse');
ylabel(plot_handles(current_plot_index),join(["\delta^{18}O (",char(8240),")"]));
axis(plot_handles(current_plot_index),[age_limits(1),age_limits(2),-1.5,5.5]);

for epoch_index = 1:height(Epochs)
    plot([Epochs.Start(epoch_index) Epochs.Start(epoch_index)],[-2.5,-1.5],'Color',[0.5,0.5,0.5],'Parent',plot_handles(current_plot_index))
end

%% pH
current_plot_index = current_plot_index-1;
hold(plot_handles(current_plot_index),'on');

plot(co2_data{1}.age/1000,co2_data{1}.pH,'o','MarkerEdgeColor',rgb('Purple'),'MarkerSize',5,'Parent',plot_handles(current_plot_index))

ylabel(plot_handles(current_plot_index),"pH")
axis(plot_handles(current_plot_index),[age_limits(1),age_limits(2),-inf,inf])
set(plot_handles(current_plot_index),'YDir','Reverse')

size = 4;

%% Alkalinity/DIC
current_plot_index = number_of_plots-2;
hold(plot_handles(current_plot_index),'on');

co2_to_plot = [2,8];
symbols = ["d","o"];
colours = ["DarkGrey","DarkBlue"];

for co2_index = 1:numel(co2_to_plot)
    plot(co2_data{co2_to_plot(co2_index)}.age/1000,co2_data{co2_to_plot(co2_index)}.alkalinity./co2_data{co2_to_plot(co2_index)}.dic,symbols(co2_index),'MarkerEdgeColor',rgb(colours(co2_index)),'MarkerSize',size+1,'Parent',plot_handles(current_plot_index))
end

set(plot_handles(current_plot_index),'YDir','Reverse')
ylabel(plot_handles(current_plot_index),"ALK/DIC")
axis(plot_handles(current_plot_index),[age_limits(1),age_limits(2),-inf,inf])

%% CO2
current_plot_index = 1;
hold(plot_handles(current_plot_index),'on')

co2_index = 2;
plot(co2_data{co2_to_plot(co2_index)}.age/1000,co2_data{co2_to_plot(co2_index)}.xco2,symbols(co2_index),'MarkerEdgeColor',rgb(colours(co2_index)),'MarkerSize',size+1,'Parent',plot_handles(current_plot_index))

plot(test.age,test_results.XCO2,'o','MarkerEdgeColor',rgb('Black'),'MarkerFaceColor','Red','MarkerSize',14,'Parent',plot_handles(1))
plot(test_temperature_25.age,test_temperature_25_results.XCO2,'o','MarkerEdgeColor',rgb('Black'),'MarkerFaceColor','Blue','MarkerSize',14,'Parent',plot_handles(1)); % now constant modern T
plot(test_magnesium_55.age,test_magnesium_55_results.XCO2,'d','MarkerEdgeColor',rgb('Black'),'MarkerFaceColor','Green','MarkerSize',12,'Parent',plot_handles(1)); % now constant modern Mg 
plot(test_ca_10.age,test_ca_10_results.XCO2,'d','MarkerEdgeColor',rgb('Black'),'MarkerFaceColor','Cyan','MarkerSize',12,'Parent',plot_handles(1)); % now constant modern Ca 

ylabel(plot_handles(current_plot_index),"Atmospheric CO_2 (ppm)");
axis(plot_handles(current_plot_index),[age_limits(1),age_limits(2),-inf,2200]);
set(plot_handles(current_plot_index),'YScale','Log','YTick',100:100:4000,'YTickLabel',{'100' '200' '300' '400' '' '600' '' '800' '' '1000' '' '' '' '' '1500' '' '' '' '' '2000' '' '' '' '' '' '' '' '' '' '3000'  '' '' '' '' '' '' '' '' '' '4000' });


%% Axis etc
axpos = get(plot_handles(1),'Position');
set(plot_handles(1),'Position',[axpos(1),axpos(2),axpos(3),axpos(4)+0.06])
axpos = get(plot_handles(2),'Position');
set(plot_handles(2),'Position',[axpos(1),axpos(2)+0.01,axpos(3),axpos(4)+0.04])
axpos = get(plot_handles(3),'Position');
set(plot_handles(3),'Position',[axpos(1),axpos(2),axpos(3),axpos(4)+0.04])

set(plot_handles(1),'XTick',age_ticks);
set(plot_handles(number_of_plots),'XTick',age_ticks);
xlabel(plot_handles(1),"Age (Ma)");

for plot_index = 1:number_of_plots
    set(plot_handles(plot_index),'XDir',age_direction,'TickDir','Out','XMinorTick','On','YMinorTick','On','FontSize',14)
end

for plot_index = 1:2:number_of_plots
    current_label = get(plot_handles(plot_index),'YLabel');
    current_label.Rotation = -90;
    current_label.Position(1) = -14;
end

figure_width = 571;
figure_height = 660;

screen_size = get(0,'ScreenSize');
left_margin = 0.1*screen_size(3);
bottom_margin = 0.1*screen_size(4);
set(gcf,'Position',[left_margin,bottom_margin,figure_width,figure_height]);

%% Saving
exportgraphics(gcf,root_directory+"/Figures/Cenozoic_d18O_pH_AlkDIC_CO2.png","Resolution",600);
exportgraphics(gcf,root_directory+"/Figures/Cenozoic_d18O_pH_AlkDIC_CO2.pdf");
