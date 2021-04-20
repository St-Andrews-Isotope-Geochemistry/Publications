%% Plot Cenozoic CO2 alongside ice core records and modern CO2 with projections
%% Load the data
root_directory = "./../../";

% Palaeo CO2
co2_sheet_names = ["alkalinity_low","alkalinity","alkalinity_high"];
for sheet_index = 1:numel(co2_sheet_names)
    co2_data{sheet_index} = readtable(root_directory+"/Data/Rae_2021_Cenozoic_CO2_Precalculated.xlsx","Sheet",co2_sheet_names(sheet_index));
end

% Ice core CO2
ice_data = readtable(root_directory+"/Data/Bereiter_2015");

% Current + Future CO2
SSP_data = readtable(root_directory+"/Data/SSPs.xlsx");
law_CO2 = readtable(root_directory+"/Data/Recent_CO2.xlsx","Sheet","Law_smooth");
mauna_loa_CO2 = readtable(root_directory+"/Data/Recent_CO2.xlsx","Sheet","MaunaLoaAnnual");

% Alkenones
% Anchored approach
alkenones_anchored = readtable(root_directory+"/Data/Rae_2021_Alkenone_CO2.xlsx","Sheet","anchored");
% Diffusive approach
alkenones_diffusive = readtable(root_directory+"/Data/Rae_2021_Alkenone_CO2.xlsx","Sheet","diffusive");

%% Analyse the data
% Smoothing CO2
smoothing = 30;
for co2_index = 1:numel(co2_data)
    co2_smooth{co2_index} = smooth(co2_data{co2_index}.age/1000,co2_data{co2_index}.xco2,smoothing);
end

% Alkenones
alkenones_anchored = sortrows(alkenones_anchored,'age');
alkenones_diffusive = sortrows(alkenones_diffusive,'age');

ep_age = [alkenones_anchored.age(alkenones_anchored.age/1000<23); alkenones_diffusive.age(alkenones_diffusive.age/1000>23)];
ep_co2 = [alkenones_anchored.co2(alkenones_anchored.age/1000<23); alkenones_diffusive.co2(alkenones_diffusive.age/1000>23)];
ep_combined = table(ep_age,ep_co2);

% Calculate SSP_data age
SSP_data.age = 1950-SSP_data.year;

%% Make the figure
clf
figure_handle = figure(1);
figure_handle.Color = "White";

% Create an initial size for xaxissplit
y_min = 180;
y_max = 2300;
figure_position = [273,508,815,360];
axis_position = [0.1300,0.2000,0.7750,0.700];
number_of_plots = 3;

plot_handles = xaxissplit(number_of_plots,figure_position,axis_position,[y_min,y_max],"figure_handle",figure_handle);
set(gcf,'Position',figure_position);

ep_size = 4;

%% Plot the data
% Palaeo data
current_plot_index = 1;
hold(plot_handles(current_plot_index),'On');
set(plot_handles(current_plot_index),'Xlim',[1,70]);

% Alkenone data
plot(alkenones_anchored.age/1000,alkenones_anchored.co2_84pc,'+','MarkerEdgeColor',rgb('SteelBlue'),'MarkerFaceColor','None','MarkerSize',ep_size,'Parent',plot_handles(current_plot_index))
plot(alkenones_diffusive.age/1000,alkenones_diffusive.co2,'+','MarkerEdgeColor',rgb('SteelBlue'),'MarkerFaceColor','None','MarkerSize',ep_size,'Parent',plot_handles(current_plot_index))

% Boron data
plot(co2_data{2}.age/1000,co2_data{2}.xco2,'o','MarkerEdgeColor',rgb('DarkBlue'),'MarkerFaceColor','none','MarkerSize',6,'Parent',plot_handles(current_plot_index))
plot(co2_data{2}.age/1000,co2_smooth{2},'--','Color',rgb('DarkBlue'),'LineWidth',3,'Parent',plot_handles(current_plot_index))
plot(co2_data{1}.age/1000,co2_smooth{1},'--','Color',rgb('DarkBlue'),'LineWidth',1,'Parent',plot_handles(current_plot_index))
plot(co2_data{3}.age/1000,co2_smooth{3},'--','Color',rgb('DarkBlue'),'LineWidth',1,'Parent',plot_handles(current_plot_index))

% Labels
text(50,2100,"\it PETM",'Color',rgb('Grey'),'FontSize',11,'Parent',plot_handles(current_plot_index));
text(45,1500,["\it Alligators in","the Arctic"],'Color',rgb('Grey'),'FontSize',11,'Parent',plot_handles(current_plot_index));
text(0,700,["\it Beech trees","in Antarctica"],'Color',rgb('Grey'),'FontSize',11,'Parent',plot_handles(current_plot_index));

%% Plio-Pleisto
current_plot_index = 2;
hold(plot_handles(current_plot_index),'On')
set(plot_handles(current_plot_index),'XLim',[1,1000]) 

% Boron
plot(co2_data{2}.age,co2_data{2}.xco2,'o','MarkerEdgeColor',rgb('DarkBlue'),'MarkerFaceColor','none','MarkerSize',6,'Parent',plot_handles(current_plot_index))

% Ice core
plot(ice_data.Age_from_1950(ice_data.Age_from_1950>200)./1000,smooth(ice_data.CO2(ice_data.Age_from_1950>200),5),'-','Color',rgb('DarkBlue'),'LineWidth',2,'Parent',plot_handles(current_plot_index))

% Label
text(700,400,"\it Ice age cycles",'Color',rgb('Grey'),'FontSize',11,'Parent',plot_handles(current_plot_index));

%% Future
current_plot_index = 3;
hold(plot_handles(current_plot_index),'On');
set(plot_handles(current_plot_index),'XLim',[900,2500]);

% Add RCPs
plot(SSP_data.year,SSP_data.co2_4p5,'-','Color',rgb('Orange'),'LineWidth',2,'Parent',plot_handles(current_plot_index));
text(2550,SSP_data.co2_4p5(end)+50,'SSP2-4.5','Color',rgb('Orange'),'FontSize',10,'Parent',plot_handles(current_plot_index));

plot(SSP_data.year,SSP_data.co2_6p0,'-','Color',rgb('Red'),'LineWidth',2,'Parent',plot_handles(current_plot_index));
text(2550,SSP_data.co2_6p0(end)+100,'SSP4-6.0','Color',rgb('Red'),'FontSize',10,'Parent',plot_handles(current_plot_index));

plot(SSP_data.year,SSP_data.co2_8p5,'-','Color',rgb('FireBrick'),'LineWidth',2,'Parent',plot_handles(current_plot_index));
text(2550,SSP_data.co2_8p5(end)+150,'SSP5-8.5','Color',rgb('FireBrick'),'FontSize',10,'Parent',plot_handles(current_plot_index));
plot(law_CO2.year,law_CO2.CO2,'-','Color',rgb('DarkBlue'),'LineWidth',2,'Parent',plot_handles(current_plot_index));

plot(mauna_loa_CO2.year,mauna_loa_CO2.CO2,'-','Color',rgb('DarkBlue'),'LineWidth',2,'Parent',plot_handles(current_plot_index));

plot([2020,2500],[413,413],'--','Color',[0.05,0.05,0.05],'LineWidth',2,'Parent',plot_handles(current_plot_index));
text(2100,413+80,'2020','Color',[0.05,0.05,0.05],'FontSize',12,'Parent',plot_handles(current_plot_index));

set(plot_handles(current_plot_index),'XTick',[1000,1500,2000,2500]);

% Add some annotations
text(800,450,["\it Human","settlement"],'Color',rgb('Grey'),'FontSize',11,'Parent',plot_handles(current_plot_index));
text(1800,2300,["\it Possible futures"],'Color',rgb('Grey'),'FontSize',11,'Parent',plot_handles(current_plot_index));

%% Manual axis adjustments and labelling
for plot_index = 1:number_of_plots-1
    set(plot_handles(plot_index),'YLim',[100,2300],'XDir','Reverse','TickDir','Out','YMinorTick','On','FontSize',14);
end
set(plot_handles(3),'XDir','Normal')
xlabel(plot_handles(1),'Age (Ma)')
xlabel(plot_handles(2),'Age (ka)')
xlabel(plot_handles(3),'Year (CE)')

ylabel(plot_handles(1),"Atmospheric CO_2 (ppm)",'FontSize',14);

figure_height = 360;
figure_width = 815;

screen_size = get(0,'ScreenSize');
left_margin = 0.1*screen_size(3);
bottom_margin = 0.1*screen_size(4);

set(gcf,'Position',[left_margin,bottom_margin,figure_width,figure_height]);

%% Saving
exportgraphics(gcf,root_directory+"/Figures/Cenozoic_CO2_SSPs.png","Resolution",600);
exportgraphics(gcf,root_directory+"/Figures/Cenozoic_CO2_SSPs.pdf");