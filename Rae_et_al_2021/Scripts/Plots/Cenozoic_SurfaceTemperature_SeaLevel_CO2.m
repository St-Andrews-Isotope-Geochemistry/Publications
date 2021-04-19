% Plot Cenozoic temperature, sea level and CO2 data
%% Load the data
westerhold2020 = readtable('./../../Data/Westerhold_2020_d18O.xlsx','Sheet','Matlab','Format','Auto');

sea_level = readtable('./../../Data/Miller_2020_SeaLevel.xlsx','sheet','data');
sea_level_smooth = readtable('./../../Data/Miller_2020_SeaLevel.xlsx','sheet','smooth');

% Alkenone Ep
% Anchored approach
Alk_anch = readtable('./../../Data/Rae_2021_Alkenone_CO2.xlsx','sheet','anchored');
% Diffusive approach
Alk_diff = readtable('./../../Data/Rae_2021_Alkenone_CO2.xlsx','sheet','diffusive');

% CO2
co2_sheet_names = ["alkalinity_low","alkalinity","alkalinity_high"];
co2_data = cell(numel(co2_sheet_names),1);
for sheet_index = 1:numel(co2_sheet_names)
    co2_data{sheet_index} = readtable("./../../Data/Rae_2021_Cenozoic_CO2_Precalculated.xlsx","Sheet",co2_sheet_names(sheet_index));
end

%% Analyse the data
% Remove NaN and smooth Westerhold
westerhold2020 = westerhold2020(~isnan(westerhold2020.age) & ~isnan(westerhold2020.d18O),:);
westerhold2020 = sortrows(westerhold2020);
westerhold2020.smooth = smooth(westerhold2020.age,westerhold2020.d18O_corrected,30,'loess');
westerhold2020.surface_ocean_temperature_smooth = smooth(westerhold2020.age,westerhold2020.surface_ocean_temperature,100,'loess');

% Alkenones
Alk_anch = sortrows(Alk_anch,'age');
Alk_diff = sortrows(Alk_diff,'age');

% -21 ppm from 999 to correct for air-sea disequilibrium
for co2_index = 1:numel(co2_data)
    odp999 = find(strcmp(co2_data{co2_index}.ref,'Foster, 2008; Rae 2018 pH pCO2')|strcmp(co2_data{co2_index}.ref,'Chalk et al., 2017')|strcmp(co2_data{co2_index}.ref,'Martínez-Botí et al., 2015')|strcmp(co2_data{co2_index}.ref,'de la Vega et al., 2020'));
    co2_data{co2_index}.xco2(odp999) = co2_data{co2_index}.xco2(odp999)-21;
end

% Smoothing CO2
smoothing = 30;
for co2_index = 1:numel(co2_data)
    co2_smooth{co2_index} = smooth(co2_data{co2_index}.age/1000,co2_data{co2_index}.xco2,smoothing);
end

%% Make the figure
age_limits = [0,70];
age_ticks = 0:10:70;

% Normal - time going right to left or
% Reverse - time going left to right
% age_direction = 'normal';
age_direction = 'reverse';

clf
figure_handle = figure(1);
figure_handle.Color = "White";
number_of_plots = 3; % This is the number of axes you would like
plot_handles = stackplot(number_of_plots,"figure_handle",figure_handle,"side","left");

%% Plot the data
% Surface temperature
current_plot_index = number_of_plots;
hold(plot_handles(current_plot_index),'on')

plot(westerhold2020.age,westerhold2020.surface_ocean_temperature,'x','Color',rgb('LightGray'),'MarkerSize',2,'Parent',plot_handles(current_plot_index))
plot(westerhold2020.age,westerhold2020.surface_ocean_temperature_smooth,'-','Color',rgb('Black'),'LineWidth',1.5,'Parent',plot_handles(current_plot_index))

ylabel(plot_handles(current_plot_index),'Surface Temperature (^oC)')
axis(plot_handles(current_plot_index),[age_limits(1),age_limits(2),-inf,34])

% Sea Level
current_plot_index = number_of_plots-1;
hold(plot_handles(current_plot_index),'on')

plot(sea_level.age/1000, sea_level.SL,'x','MarkerEdgeColor',[0.7922    0.9020    0.7922],'MarkerFaceColor','none','MarkerSize',3,'Parent',plot_handles(current_plot_index))
plot(sea_level_smooth.age/1000, sea_level_smooth.SL,'-','Color',rgb('Green'),'LineWidth',1.5,'Parent',plot_handles(current_plot_index))
% [0.1529    0.6667    0.2745]

ylabel(plot_handles(current_plot_index),'Sea Level (m)')
axis(plot_handles(current_plot_index),[age_limits(1),age_limits(2),-inf,inf])

% CO2
current_plot_index = number_of_plots-2;
hold(plot_handles(current_plot_index),'on')

plot(Alk_anch.age/1000, log2(Alk_anch.co2),'+','MarkerEdgeColor',rgb('SteelBlue'),'MarkerFaceColor','none','MarkerSize',5,'Parent',plot_handles(current_plot_index))
plot(Alk_diff.age/1000, log2(Alk_diff.co2_84pc),'+','MarkerEdgeColor',rgb('SteelBlue'),'MarkerFaceColor','none','MarkerSize',5,'Parent',plot_handles(current_plot_index))

for co2_data_index = 1:height(co2_data{2})
    plot(co2_data{2}.age(co2_data_index)/1000,log2(co2_data{2}.xco2(co2_data_index)),"Marker","o",'Color',rgb('DarkBlue'),'MarkerSize',7,'Parent',plot_handles(current_plot_index))
end
plot(co2_data{2}.age/1000,log2(co2_smooth{2}),'-','Color',rgb('DarkBlue'),'LineWidth',2,'Parent',plot_handles(current_plot_index));
plot(co2_data{1}.age/1000,log2(co2_smooth{1}),':','Color',rgb('DarkBlue'),'LineWidth',1,'Parent',plot_handles(current_plot_index));
plot(co2_data{3}.age/1000,log2(co2_smooth{3}),':','Color',rgb('DarkBlue'),'LineWidth',1,'Parent',plot_handles(current_plot_index));


ylabel(plot_handles(current_plot_index),'Atmospheric CO_2 (ppm)')

axis(plot_handles(current_plot_index),[age_limits(1),age_limits(2),log2([180,2200])])

y_ticks = log2([200,400,600,800,1000,1500,2000]);
y_tick_labels = string([200,400,600,800,1000,1500,2000]);
set(plot_handles(current_plot_index),'YTick',y_ticks,'YTickLabels',y_tick_labels);

%% Manual axis adjustments
axpos = get(plot_handles(1),'Position');
set(plot_handles(1),'Position', [axpos(1),axpos(2),axpos(3),axpos(4)+0.12])
axpos = get(plot_handles(2),'Position');
set(plot_handles(2),'Position', [axpos(1),axpos(2)+0.03,axpos(3),axpos(4)+0.02])
axpos = get(plot_handles(3),'Position');
set(plot_handles(3),'Position', [axpos(1),axpos(2)-0.02,axpos(3),axpos(4)+0.1])

set(plot_handles(1),'XTick',age_ticks)
set(plot_handles(number_of_plots),'XTick',age_ticks)
xlabel(plot_handles(1),'Age (Ma)')

for plot_index = 1:number_of_plots
    set(plot_handles(plot_index),'XDir',age_direction,'TickDir','Out','XMinorTick','On','YMinorTick','On','FontSize',14)
end

for plot_index = 2:2:number_of_plots
    current_label = get(plot_handles(plot_index),'YLabel');
    current_label.Rotation = -90;
    current_label.Position(1) = -11;
end

for plot_index = 1:2:number_of_plots
    current_label = get(plot_handles(plot_index),'YLabel');
    current_label.Position(1) = 78;
end

figure_height = 590;
figure_width = 690;

screen_size = get(0,'ScreenSize');
left_margin = 0.1*screen_size(3);
bottom_margin = 0.1*screen_size(4);

set(gcf,'Position',[left_margin,bottom_margin,figure_width,figure_height]);

%% Saving
exportgraphics(gcf,"./Figures/Cenozoic_SurfaceTemperature_SeaLevel_CO2.png","Resolution",600);
exportgraphics(gcf,"./Figures/Cenozoic_SurfaceTemperature_SeaLevel_CO2.pdf","ContentType","vector");