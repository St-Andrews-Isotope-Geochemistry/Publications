%% Plot Cenozoic CO2 and change in temperature 
%% Load in data
root_directory = "./../../";

% d18O
westerhold2020 = readtable(root_directory+"/Data/Westerhold_2020_d18O.xlsx",'Sheet','Matlab','Format','Auto');

% CO2
co2_sheet_names = ["alkalinity"];
for sheet_index = 1:numel(co2_sheet_names)
    co2_data{sheet_index} = readtable(root_directory+"/Data/Rae_2021_Cenozoic_CO2_Precalculated.xlsx","Sheet",co2_sheet_names(sheet_index));
end
co2 = co2_data{1}.xco2;
age = co2_data{1}.age/1000; % ka to Ma

%% Bin the data
bin_width = 0.01;
bin_edges = 0:bin_width:100;
bins_midpoints = bin_edges(1:end-1)+bin_width;

co2_binned = NaN(numel(bins_midpoints),1);
d18O_binned = NaN(numel(bins_midpoints),1);
surface_ocean_temperature_binned = NaN(numel(bin_edges)-1,1);

for bin_index = 1:numel(bins_midpoints)
    co2_filter = age>bin_edges(bin_index) & age<=bin_edges(bin_index+1);
    co2_binned(bin_index) = nanmean(co2(co2_filter));
    
    d18O_filter = westerhold2020.age>bin_edges(bin_index) & westerhold2020.age<=bin_edges(bin_index+1);
    d18O_binned(bin_index) = nanmean(westerhold2020.d18O_corrected(d18O_filter));
    surface_ocean_temperature_binned(bin_index) = nanmean(westerhold2020.surface_ocean_temperature(d18O_filter));
end

%% Sensitivity
modern_t = 12.7951;
modern_d18O = 0;
tiepoint = [280,modern_t];
sensitivities = [2,4,6,8]';
doublings = [-2,4];

sensitivity_lines_lower = [repelem(tiepoint(1)*2^doublings(1),numel(sensitivities),1),(sensitivities.*doublings(1))+tiepoint(2)];
sensitivity_lines_upper = [repelem(tiepoint(1)*2^doublings(2),numel(sensitivities),1),(sensitivities.*doublings(2))+tiepoint(2)];
sensitivity_label_position = [1500,18,11; 
                              1600,23,22;
                              1650,28.5,32;                             
                              1400,31.75,40];

% Other data
zhu_2019.age = [55,48];
zhu_2019.temperature = 29.4;
zhu_2019.temperature_uncertainty = 3;
zhu_2019.co2 = 1625;

tierney_2019.age = [15000,30000]/1e6;
tierney_2019.temperature = -6.1;
tierney_2019.temperature_uncertainty = [-6.5,-5.7];
tierney_2019.co2 = 185;

mcclymont2020.age = [2.8,3.2];
mcclymont2020.temperature = 2.3;
mcclymont2020.co2 = 380;

evans2018.age = [56,34];
evans2018.temperature = 33;
evans2018.co2 = 1149;

delavega.age = [3.6,2.6];
delavega.temperature = 2.5;
delavega.co2 = 371;

anag20_1.age = [59,56];
anag20_1.temperature = 12.3;
anag20_1.co2 = 1000;

anag20_2.age = [53.3,49.1];
anag20_2.temperature = 13;
anag20_2.co2 = 950;

anag20_3.age = [56.2,55.8];
anag20_3.temperature = 17.6;
anag20_3.co2 = 1750;

% Get CO2
zhu_2019.co2 = lookupCO2(bin_edges,co2_binned,zhu_2019.age);
tierney_2019.co2 = lookupCO2(bin_edges,co2_binned,tierney_2019.age);
mcclymont2020.co2 = lookupCO2(bin_edges,co2_binned,mcclymont2020.age);
evans2018.co2 = lookupCO2(bin_edges,co2_binned,evans2018.age);
delavega.co2 = lookupCO2(bin_edges,co2_binned,delavega.age);
anag20_1.co2 = lookupCO2(bin_edges,co2_binned,anag20_1.age);
anag20_2.co2 = lookupCO2(bin_edges,co2_binned,anag20_2.age);

%% Plot
figure(1);
clf

subplot_1 = subplot(1,2,1);
scatter(log2(co2_binned),d18O_binned-modern_d18O,8,bins_midpoints,"filled");

x_ticks = log2(280*2.^(-1:4));
x_tick_labels = string(280*2.^(-1:4));

xlabel("Atmospheric CO_2 (ppmv)");
ylabel(['Benthic \delta^{18}O (' char(8240) ')']);

xlim(log2([140,3000]));
ylim([-2.5,6]);

current_axis = gca;
current_axis.XAxis.MinorTickValues = log2(140:70:4480);
set(gca,'XMinorTick','On','YMinorTick','On','TickDir','Out','TickLength',[0.02,0.01],'XTick',x_ticks,'XTickLabels',x_tick_labels,'YDir','Reverse');
axis square


subplot_2 = subplot(1,2,2);
hold on
for sensitivity_index = 1:numel(sensitivities)
    plot([log2(sensitivity_lines_lower(sensitivity_index,1)),log2(sensitivity_lines_upper(sensitivity_index,1))],[sensitivity_lines_lower(sensitivity_index,2),sensitivity_lines_upper(sensitivity_index,2)]-modern_t,'Color',[0.6,0.6,0.6],'LineStyle','--');
    text(log2(sensitivity_label_position(sensitivity_index,1)),sensitivity_label_position(sensitivity_index,2)-modern_t,join([num2str(sensitivities(sensitivity_index)),"^{\circ}C/doubling"],""),'Rotation',sensitivity_label_position(sensitivity_index,3),'BackgroundColor','w');
end
scatter(log2(co2_binned),surface_ocean_temperature_binned-modern_t,8,bins_midpoints,"filled");

% Other estimates
scatter(log2(tierney_2019.co2),tierney_2019.temperature,80,'k','MarkerEdgeColor','k','MarkerFaceColor',rgb("grey"));
text(log2(tierney_2019.co2+10),tierney_2019.temperature+0.5,"^a",'FontWeight','Bold');
scatter(log2(mcclymont2020.co2),mcclymont2020.temperature,80,'k','MarkerEdgeColor','k','MarkerFaceColor',rgb("grey"));
text(log2(mcclymont2020.co2+20),mcclymont2020.temperature+0,"^c",'FontWeight','Bold');
scatter(log2(delavega.co2),delavega.temperature,80,'k','MarkerEdgeColor','k','MarkerFaceColor',rgb("grey"));
text(log2(delavega.co2-30),delavega.temperature+0.6,"^b",'FontWeight','Bold');
scatter(log2(anag20_1.co2),anag20_1.temperature,80,'k','MarkerEdgeColor','k','MarkerFaceColor',rgb("grey"));
text(log2(anag20_1.co2+50),anag20_1.temperature+0.5,"^d",'FontWeight','Bold');
scatter(log2(anag20_2.co2),anag20_2.temperature,80,'k','MarkerEdgeColor','k','MarkerFaceColor',rgb("grey"));
text(log2(anag20_2.co2+40),anag20_2.temperature+0.6,"^e",'FontWeight','Bold');
scatter(log2(anag20_3.co2),anag20_3.temperature,80,'k','MarkerEdgeColor','k','MarkerFaceColor',rgb("grey"));
text(log2(anag20_3.co2-30),anag20_3.temperature+0.8,"^f",'FontWeight','Bold');

% Other estimates - labels
text(log2(160),24,"a - Tierney, 2019");
text(log2(160),22,"b - de la Vega, 2020");
text(log2(160),20,"c - McClymont, 2020");
text(log2(160),18,"d - Inglis, LatePal");
text(log2(160),16,"e - Inglis, EECO");
text(log2(160),14,"f - Inglis, PETM");

% Add the tiepoint
plot(log2(tiepoint(1)),tiepoint(2)-modern_t,'sk','MarkerSize',8,'MarkerFaceColor','k');

xlabel("Atmospheric CO_2 (ppmv)");
ylabel("\DeltaTemperature (^{\circ}C)");

xlim(log2([140,3000]));
ylim([-10,25]);

current_axis = gca;
current_axis.XAxis.MinorTickValues = log2(140:70:4480);
set(gca,'XMinorTick','On','YMinorTick','On','TickDir','Out','TickLength',[0.02,0.01],'XTick',x_ticks,'XTickLabels',x_tick_labels);
axis square

% Keep original sizes for scaling
original_sizes = [get(subplot_1,'Position');get(subplot_2,'Position')];

% Colorbar
colour_handle = colorbar;
ylabel(colour_handle,"Age (Ma)","Rotation",-90, 'VerticalAlignment','bottom', 'HorizontalAlignment','center');
set(colour_handle,'YDir','Reverse');
caxis([0,70]);

% Create a custom colormap
colour_stops = [0,0.3010,0.7450,0.9330;
                1.81,0,0.447,0.741;
                5.3,0.764,0.564,0.831;
                34,0.494,0.184,0.556;
                36,0.981,0.285,0.417;
                70,0.376,0.180,0;];
            
expanded_colour_map = Expand_CMap(colour_stops,1000);
colormap(expanded_colour_map);

% Rescale the subplots to maintain square shape
set(subplot_1,'Position',original_sizes(1,:));
set(subplot_2,'Position',original_sizes(2,:));

% Scale the figure
figure_height = 500;
figure_width = 1100;

screen_size = get(0,'ScreenSize');
left_margin = 0.1*screen_size(3);
bottom_margin = 0.1*screen_size(4);

set(gcf,'Position',[left_margin,bottom_margin,figure_width,figure_height]);

%% Saving
exportgraphics(gcf,root_directory+"/Figures/Cenozoic_CO2_dTemperature.png","Resolution",600);
exportgraphics(gcf,root_directory+"/Figures/Cenozoic_CO2_dTemperature.pdf");

%% Function to look up CO2 for a given age
function output_co2 = lookupCO2(age_bins,co2_bins,age_lookup)
    co2 = co2_bins(age_bins<max(age_lookup) & age_bins>min(age_lookup));
    output_co2 = nanmean(co2);
end
