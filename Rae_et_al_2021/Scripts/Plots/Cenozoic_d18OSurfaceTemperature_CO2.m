% Plot Cenozoic temperature, sea level and CO2 data
%% Load the data
root_directory = "./../../";

% d18O
westerhold2020 = readtable(root_directory+"/Data/Westerhold_2020_d18O.xlsx",'Sheet','Matlab','Format','Auto');

% Sea level
sea_level = readtable(root_directory+"/Data/Miller_2020_SeaLevel.xlsx",'sheet','data');
sea_level_smooth = readtable(root_directory+"/Data/Miller_2020_SeaLevel.xlsx",'sheet','smooth');

% Alkenones
alkenones_anchored = readtable(root_directory+"/Data/Supplements/Rae_2021_Alkenone_CO2.xlsx",'sheet','anchored');
alkenones_diffusive = readtable(root_directory+"/Data/Supplements/Rae_2021_Alkenone_CO2.xlsx",'sheet','diffusive');

% CO2
co2_sheet_names = ["alkalinity_low","alkalinity","alkalinity_high"];
co2_data = cell(numel(co2_sheet_names),1);
for sheet_index = 1:numel(co2_sheet_names)
    co2_data{sheet_index} = readtable(root_directory+"/Data/Rae_2021_Cenozoic_CO2_Precalculated.xlsx","Sheet",co2_sheet_names(sheet_index));
end

no_ice_hansen_calibration = @(d18O) -4*d18O+12;

%% Analyse the data
% Remove NaN and smooth Westerhold
westerhold2020 = westerhold2020(~isnan(westerhold2020.age) & ~isnan(westerhold2020.d18O),:);
westerhold2020 = sortrows(westerhold2020);
westerhold2020.smooth = smooth(westerhold2020.age,westerhold2020.d18O_corrected,30,'loess');
westerhold2020.surface_ocean_temperature_smooth = smooth(westerhold2020.age,westerhold2020.surface_ocean_temperature,50,'loess');

% Alkenones
alkenones_anchored = sortrows(alkenones_anchored,'age');
alkenones_diffusive = sortrows(alkenones_diffusive,'age');

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
age_direction = 'Reverse';

clf
figure_handle = figure(1);
figure_handle.Color = "White";
number_of_plots = 2; % This is the number of axes you would like
plot_handles = stackplot(number_of_plots,"figure_handle",figure_handle,"side","left");

%% Plot the data
% Surface temperature
current_plot_index = number_of_plots;
hold(plot_handles(current_plot_index),'On')

plot(westerhold2020.age,westerhold2020.d18O_corrected,'x','Color',rgb('LightGray'),'MarkerSize',2,'Parent',plot_handles(current_plot_index))
plot(westerhold2020.age,smooth(westerhold2020.d18O_corrected,30),'-','Color',rgb('Black'),'LineWidth',1,'Parent',plot_handles(current_plot_index))

ylabel(plot_handles(current_plot_index),join(["\delta^{18}O (",char(8240),")"]))
axis(plot_handles(current_plot_index),[age_limits(1),age_limits(2),-inf,34])

% CO2
current_plot_index = number_of_plots-1;
hold(plot_handles(current_plot_index),'On')

plot(alkenones_anchored.age/1000, log2(alkenones_anchored.co2),'+','MarkerEdgeColor',rgb('SteelBlue'),'MarkerFaceColor','none','MarkerSize',5,'Parent',plot_handles(current_plot_index))
plot(alkenones_diffusive.age/1000, log2(alkenones_diffusive.co2_84pc),'+','MarkerEdgeColor',rgb('SteelBlue'),'MarkerFaceColor','none','MarkerSize',5,'Parent',plot_handles(current_plot_index))

for co2_data_index = 1:height(co2_data{2})
    plot(co2_data{2}.age(co2_data_index)/1000,log2(co2_data{2}.xco2(co2_data_index)),"Marker","o",'Color',rgb('DarkBlue'),'MarkerSize',7,'Parent',plot_handles(current_plot_index))
end
plot(co2_data{2}.age/1000,log2(co2_smooth{2}),'-','Color',rgb('DarkBlue'),'LineWidth',2,'Parent',plot_handles(current_plot_index));
plot(co2_data{1}.age/1000,log2(co2_smooth{1}),':','Color',rgb('DarkBlue'),'LineWidth',1,'Parent',plot_handles(current_plot_index));
plot(co2_data{3}.age/1000,log2(co2_smooth{3}),':','Color',rgb('DarkBlue'),'LineWidth',1,'Parent',plot_handles(current_plot_index));

ylabel(plot_handles(current_plot_index),"Atmospheric CO_2 (ppm)")

axis(plot_handles(current_plot_index),[age_limits(1),age_limits(2),log2([180,2200])])

y_ticks = [200,400,600,800,1000,1500,2000];
y_tick_labels = string(y_ticks);
set(plot_handles(current_plot_index),'YTick',log2(y_ticks),'YTickLabels',y_tick_labels);

%% Manual axis adjustments
axpos = get(plot_handles(1),'Position');
set(plot_handles(1),'Position', [axpos(1),axpos(2),axpos(3),axpos(4)+0.02])
axpos = get(plot_handles(2),'Position');
set(plot_handles(2),'Position', [axpos(1),axpos(2),axpos(3),axpos(4)+0.02])

set(plot_handles(1),'XTick',age_ticks)
set(plot_handles(number_of_plots),'XTick',age_ticks,'YDir','Reverse')
xlabel(plot_handles(1),"Age (Ma)")

d18O_limits = [-2,6];
temperature_limits = no_ice_hansen_calibration(d18O_limits);

temperature_axis = axes('Position',get(plot_handles(2),'Position'),'Color','None');
set(temperature_axis,'XColor','None','YDir','Normal');

ylim(plot_handles(2),d18O_limits);
ylim(temperature_axis,fliplr(temperature_limits));
xlim(temperature_axis,[age_limits(1),age_limits(2)]);
ylabel(temperature_axis,"Ice free temperature (^\circC)");

for plot_index = 1:number_of_plots
    set(plot_handles(plot_index),'XDir',age_direction,'TickDir','Out','XMinorTick','On','YMinorTick','On','FontSize',14)
end
set(temperature_axis,'XDir',age_direction,'TickDir','Out','XMinorTick','On','YMinorTick','On','FontSize',14)

for plot_index = 2:2:number_of_plots
    current_label = get(plot_handles(plot_index),'YLabel');
    current_label.Rotation = -90;
    current_label.Position(1) = -11;
end

for plot_index = 1:2:number_of_plots
    current_label = get(plot_handles(plot_index),'YLabel');
    current_label.Position(1) = 78;
end
current_label = get(temperature_axis,'YLabel');
current_label.Position(1) = 78;
    
figure_height = 590;
figure_width = 690;

screen_size = get(0,'ScreenSize');
left_margin = 0.1*screen_size(3);
bottom_margin = 0.1*screen_size(4);

set(gcf,'Position',[left_margin,bottom_margin,figure_width,figure_height]);

%% Saving
exportgraphics(gcf,root_directory+"/Figures/Cenozoic_d18OSurfaceTemperature_CO2.png","Resolution",600);
exportgraphics(gcf,root_directory+"/Figures/Cenozoic_d18OSurfaceTemperature_CO2.pdf");