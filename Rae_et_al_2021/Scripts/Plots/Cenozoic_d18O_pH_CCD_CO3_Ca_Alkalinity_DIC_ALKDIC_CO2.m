%% Plot Cenozoic d18O, pH, CCD, CO2, Ca, Alkalinity, DIC, Alkalinity/DIC and CO2
%% Load in the data
root_directory = "./../../";

% d18O
westerhold2020 = readtable(root_directory+"/Data/Westerhold_2020_d18O.xlsx",'Sheet','Matlab','Format','Auto');

% Magnesium + Calcium
mg_ca = readtable(root_directory+"/Data/Supplements/Rae_2021_Boron_pH_CO2_CO2system.xlsx",'sheet','Mg_Ca_sw');

% pH
d11B_pH = readtable(root_directory+"/Data/Rae_2021_Cenozoic_CO2_Precalculated.xlsx","Sheet","d11B_data");

Epochs = readtable(root_directory+"/Data/Cenozoic_Epochs.xlsx");

% CO2
co2_sheet_names = ["ccd","Omega65","Omega5","Omega8","dic","alkalinity_high","alkalinity_low","alkalinity","omega8_high_ca","omega8_low_ca","omega5_high_ca","omega5_low_ca"];
for sheet_index = 1:numel(co2_sheet_names)
    co2_data{sheet_index} = readtable(root_directory+"/Data/Rae_2021_Cenozoic_CO2_Precalculated.xlsx","Sheet",co2_sheet_names(sheet_index));
end
co2_colours = ["Black","Grey","Grey","Grey","SteelBlue","DarkBlue","DarkBlue","Orange","LightGrey","LightGrey","LightGrey","LightGrey"];
co2_line_style = ["--","-",":",":","--",":",":","-",":",":",":",":"];

%% Analyse the data
% d18O
westerhold2020 = westerhold2020(~isnan(westerhold2020.age) & ~isnan(westerhold2020.d18O),:);
westerhold2020 = sortrows(westerhold2020);
westerhold2020.d18O_smooth = smooth(westerhold2020.age,westerhold2020.d18O_corrected,30,'loess');

%% Make the figure
age_limits = [0,70];
age_ticks = 0:10:70;

% Normal - time going right to left or
% Reverse - time going left to right
% age_direction = 'Normal';
age_direction = 'Reverse';

clf
figure_handle = figure(1);
figure_handle.Color = "White";
number_of_plots = 10; %his is the number of axes you would like
plot_handles = stackplot(number_of_plots,"figure_handle",figure_handle);


%% d18O
current_plot_index = number_of_plots;
hold(plot_handles(current_plot_index),'On')

plot(westerhold2020.age,westerhold2020.d18O_corrected,'x','Color',rgb('LightGray'),'MarkerSize',2,'Parent',plot_handles(current_plot_index))
plot(westerhold2020.age,westerhold2020.d18O_smooth,'-','Color',rgb('Black'),'LineWidth',1,'Parent',plot_handles(current_plot_index))

set(plot_handles(current_plot_index),'YDir','Reverse')
ylabel(plot_handles(current_plot_index),join(["\delta^{18}O (",char(8240),")"]))
axis(plot_handles(current_plot_index),[age_limits(1) age_limits(2) -1.5 5.5])

for epoch_index = 1:height(Epochs)
    plot([Epochs.Start(epoch_index),Epochs.Start(epoch_index)],[-2.5,-1.5],'Color',[0.5,0.5,0.5],'Parent',plot_handles(current_plot_index))
end

%% pH 
current_plot_index = current_plot_index-1; 
hold(plot_handles(current_plot_index),'On')

plot(d11B_pH.age/1000,d11B_pH.pH,'o','MarkerEdgeColor',rgb("Purple"),'MarkerFaceColor','None','MarkerSize',4,'Parent',plot_handles(current_plot_index))

ylabel(plot_handles(current_plot_index),'pH')
axis(plot_handles(current_plot_index),[age_limits(1),age_limits(2),-inf,inf])
set(plot_handles(current_plot_index),'YDir','Reverse')

%% CCD
current_plot_index = number_of_plots-2;
hold(plot_handles(current_plot_index),'On');

% Palike equatorial CCD
load ./../../Data/Palike2012.mat
plot(Palike2012.age./1000,Palike2012.DepthEqCCD./1000,'--','Color',rgb('Brown'),'LineWidth',1,'Parent',plot_handles(current_plot_index))

% Lyle Pacific CCD
Lyle08 = readtable('./../../Data/Lyle_2008_CCD_BoudreauGC.xlsx');
plot(Lyle08.age,Lyle08.CCDdepth,'--','Color',rgb('Tan'),'LineWidth',1,'Parent',plot_handles(current_plot_index))

% Van Andel 1975
VanAnd75 = readtable('./../../Data/VanAndel_1975_CCD_TyrrellGC.xlsx');
plot(VanAnd75.age,VanAnd75.CCDdepth,'-','Color',rgb('Sienna'),'LineWidth',1,'Parent',plot_handles(current_plot_index))

% Tyrrell & Zeebe 2004
TZ04 = readtable('./../../Data/Tyrrell_2004_CCD_GC.xlsx');
plot(TZ04.age,TZ04.CCDdepth,'-','Color',rgb('Chocolate'),'LineWidth',1,'Parent',plot_handles(current_plot_index))

ylabel(plot_handles(current_plot_index),'CCD (km)')
axis(plot_handles(current_plot_index),[age_limits(1),age_limits(2),-inf,inf])
set(plot_handles(current_plot_index),'YDir','Reverse')

%% Ca & Mg
current_plot_index = number_of_plots-5;
hold(plot_handles(current_plot_index),'On');

plot(mg_ca.age, mg_ca.Ca,'--','Color',rgb('LightGray'),'LineWidth',2,'Parent',plot_handles(current_plot_index))
plot(mg_ca.age,mg_ca.Ca+mg_ca.Ca_up,':','Color',rgb('LightGray'),'LineWidth',2,'Parent',plot_handles(current_plot_index))
plot(mg_ca.age,mg_ca.Ca-mg_ca.Ca_down,':','Color',rgb('LightGray'),'LineWidth',2,'Parent',plot_handles(current_plot_index))

for mg_ca_index=1:height(mg_ca)
    plot([mg_ca.age(mg_ca_index),mg_ca.age(mg_ca_index)],[mg_ca.Ca(mg_ca_index)-mg_ca.Ca_down(mg_ca_index),mg_ca.Ca(mg_ca_index)+mg_ca.Ca_up(mg_ca_index)],'-','Color',rgb('LightGray'),'LineWidth',6,'Parent',plot_handles(current_plot_index))
end
plot(mg_ca.age,mg_ca.Ca,'d','MarkerEdgeColor',rgb('Black'),'MarkerFaceColor',rgb('Grey'),'MarkerSize',8,'Parent',plot_handles(current_plot_index))

ylabel(plot_handles(current_plot_index),["[Ca^{2+}]","(mmol/kg)"]);
axis(plot_handles(current_plot_index),[age_limits(1),age_limits(2),7,25])

%% CONSTANT OMEGA %
current_plot_index = number_of_plots-3;
hold(plot_handles(current_plot_index),'On');

OmegaVals = [5, 8, 6.5];
OmegaCols = {'Gray', 'Gray', 'DimGrey'};
OmegaSymb = {'v', '^', '+'};
OmegaLine = {'--', '--', '-'};
OmegaLineWidth = [1, 1, 2];
OmegaSize = [3, 3, 3];
smoothing = 20;

% Omega
co2_to_plot = [1,2,3,4,5,6,7,8,9,11,12];

for co2_index = 1:numel(co2_to_plot)
    plot(co2_data{co2_to_plot(co2_index)}.age/1000,smooth(co2_data{co2_to_plot(co2_index)}.age/1000,co2_data{co2_to_plot(co2_index)}.saturation_state,smoothing),"LineStyle",co2_line_style(co2_to_plot(co2_index)),'Color',rgb(co2_colours(co2_to_plot(co2_index))),'LineWidth',1,'Parent',plot_handles(current_plot_index))     
end
ylabel(plot_handles(current_plot_index),"\Omega");

% CO3
current_plot_index = number_of_plots-4;
hold(plot_handles(current_plot_index),'On');

co2_to_plot = [1,2,3,4,5,6,7,8,9,11,12];

for co2_index = 1:numel(co2_to_plot)
    plot(co2_data{co2_to_plot(co2_index)}.age/1000,smooth(co2_data{co2_to_plot(co2_index)}.age/1000,co2_data{co2_to_plot(co2_index)}.co3,smoothing),"LineStyle",co2_line_style(co2_to_plot(co2_index)),'Color',rgb(co2_colours(co2_to_plot(co2_index))),'LineWidth',1,'Parent',plot_handles(current_plot_index))     
end
ylabel(plot_handles(current_plot_index),["CO_3^{2-}","(\mumol/kg)"]);

% Alkalinity
current_plot_index = number_of_plots-6;
hold(plot_handles(current_plot_index),'On');

co2_to_plot = [1,2,3,4,5,6,7,8,9,11,12];

for co2_index = 1:numel(co2_to_plot)
    plot(co2_data{co2_to_plot(co2_index)}.age/1000,smooth(co2_data{co2_to_plot(co2_index)}.age/1000,co2_data{co2_to_plot(co2_index)}.alkalinity,smoothing),"LineStyle",co2_line_style(co2_to_plot(co2_index)),'Color',rgb(co2_colours(co2_to_plot(co2_index))),'LineWidth',1,'Parent',plot_handles(current_plot_index))     
end
ylabel(plot_handles(current_plot_index),["Alkalinity","(\mumol/kg)"]);

% DIC
current_plot_index = number_of_plots-7;
hold(plot_handles(current_plot_index),'On');

co2_to_plot = [1,2,3,4,5,6,7,8,9,11,12];

for co2_index = 1:numel(co2_to_plot)
    plot(co2_data{co2_to_plot(co2_index)}.age/1000,smooth(co2_data{co2_to_plot(co2_index)}.age/1000,co2_data{co2_to_plot(co2_index)}.dic,smoothing),"LineStyle",co2_line_style(co2_to_plot(co2_index)),'Color',rgb(co2_colours(co2_to_plot(co2_index))),'LineWidth',1,'Parent',plot_handles(current_plot_index))     
end
ylabel(plot_handles(current_plot_index),["DIC","(\mumol/kg)"]);

% ALK/DIC
current_plot_index = number_of_plots-8;
hold(plot_handles(current_plot_index),'On');

co2_to_plot = [1,2,3,4,5,6,7,8,9,11,12];

for co2_index = 1:numel(co2_to_plot)
    plot(co2_data{co2_to_plot(co2_index)}.age/1000,smooth(co2_data{co2_to_plot(co2_index)}.age/1000,(co2_data{co2_to_plot(co2_index)}.alkalinity./co2_data{co2_to_plot(co2_index)}.dic),smoothing),"LineStyle",co2_line_style(co2_to_plot(co2_index)),'Color',rgb(co2_colours(co2_to_plot(co2_index))),'LineWidth',1,'Parent',plot_handles(current_plot_index))     
end
ylabel(plot_handles(current_plot_index),"ALK/DIC");

% CO2
current_plot_index = number_of_plots-9;
hold(plot_handles(current_plot_index),'On');

co2_to_plot = [1,2,3,4,5,6,7,8,9,11,12];

for co2_index = 1:numel(co2_to_plot)
    plot(co2_data{co2_to_plot(co2_index)}.age/1000,smooth(co2_data{co2_to_plot(co2_index)}.age/1000,co2_data{co2_to_plot(co2_index)}.xco2,smoothing),"LineStyle",co2_line_style(co2_to_plot(co2_index)),'Color',rgb(co2_colours(co2_to_plot(co2_index))),'LineWidth',1,'Parent',plot_handles(current_plot_index))     
end
ylabel(plot_handles(current_plot_index),["Atmospheric CO_2","(ppm)"]);

%% axes etc
axis_position = get(plot_handles(9),'Position');
set(plot_handles(9), 'Position', [axis_position(1),axis_position(2)+0.01,axis_position(3),axis_position(4)+0.02])
axis_position = get(plot_handles(8),'Position');
set(plot_handles(8), 'Position', [axis_position(1),axis_position(2)+0.04,axis_position(3),axis_position(4)])
axis_position = get(plot_handles(7),'Position');
set(plot_handles(7), 'Position', [axis_position(1),axis_position(2)+0.06,axis_position(3),axis_position(4)])
axis_position = get(plot_handles(6),'Position');
set(plot_handles(6), 'Position', [axis_position(1),axis_position(2)+0.03,axis_position(3),axis_position(4)+0.05])
axis_position = get(plot_handles(5),'Position');
set(plot_handles(5), 'Position', [axis_position(1),axis_position(2)+0.06,axis_position(3),axis_position(4)])
axis_position = get(plot_handles(4),'Position');
set(plot_handles(4), 'Position', [axis_position(1),axis_position(2)+0.04,axis_position(3),axis_position(4)+0.03])
axis_position = get(plot_handles(3),'Position');
set(plot_handles(3), 'Position', [axis_position(1),axis_position(2)+0.02,axis_position(3),axis_position(4)+0.03])
axis_position = get(plot_handles(2),'Position');
set(plot_handles(2), 'Position', [axis_position(1),axis_position(2)-0.04,axis_position(3),axis_position(4)+0.05])
axis_position = get(plot_handles(1),'Position');
set(plot_handles(1), 'Position', [axis_position(1),axis_position(2)-0.05,axis_position(3),axis_position(4)+0.07])

yticks = [200,400,800,1600,3200];
set(plot_handles(number_of_plots-9),'YScale','Log','YTick',yticks,'YTickLabel',num2str(yticks'))

set(plot_handles(1),'XTick',age_ticks)
set(plot_handles(number_of_plots),'XTick',age_ticks)

xlabel(plot_handles(1),"Age (Ma)")

for plot_index = 1:number_of_plots
    set(plot_handles(plot_index),'XDir',age_direction,'TickDir','Out','XMinorTick','On','YMinorTick','On','FontSize',12)
    xlim(plot_handles(plot_index),age_limits);
end
set(gcf,'Position',[50,235,700,750]);

for plot_index = 1:2:number_of_plots
    current_label = get(plot_handles(plot_index),'YLabel');
    current_label.Rotation = -90;
    current_label.Position(1) = -14;
end

%% Saving
exportgraphics(gcf,root_directory+"/Figures/Cenozoic_d18O_pH_CCD_CO3_Ca_Alkalinity_DIC_CO2.png","Resolution",600);
exportgraphics(gcf,root_directory+"/Figures/Cenozoic_d18O_pH_CCD_CO3_Ca_Alkalinity_DIC_CO2.pdf");
