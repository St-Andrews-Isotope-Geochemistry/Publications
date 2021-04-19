% do full set of CO2 system calculations for Rae Annual Reviews paper

%% Load in the data
% d18O
westerhold2020 = readtable('./../../Data/Westerhold_2020_d18O.xlsx','Sheet','Matlab','Format','Auto');

mg_ca = readtable('./../../Data/Publication/Rae_2021_Boron_pH_CO2_CO2system.xlsx','sheet','Mg_Ca_sw');
% mg_ca_points = readtable('./../../Data/Mg_Ca_Compilation.xlsx','sheet','Matlab_points');

% pH
d11B_pH = readtable("./../../Data/Rae_2021_Cenozoic_CO2_Precalculated.xlsx","Sheet","d11B_data");

% CO2
co2_sheet_names = ["ccd","Omega65","Omega5","Omega8","dic","alkalinity_high","alkalinity_low","alkalinity","omega8_high_ca","omega8_low_ca","omega5_high_ca","omega5_low_ca"];
for sheet_index = 1:numel(co2_sheet_names)
    co2_data{sheet_index} = readtable("./../../Data/Rae_2021_Cenozoic_CO2_Precalculated.xlsx","Sheet",co2_sheet_names(sheet_index));
end
co2_colours = ["Black","Grey","Grey","Grey","SteelBlue","DarkBlue","DarkBlue","Orange","LightGrey","LightGrey","LightGrey","LightGrey"];
co2_line_style = ["--","-",":",":","--",":",":","-",":",":",":",":"];

%% Analyse the data
% d18O
westerhold2020 = westerhold2020(~isnan(westerhold2020.age) & ~isnan(westerhold2020.d18O),:);
westerhold2020 = sortrows(westerhold2020);
westerhold2020.d18O_smooth = smooth(westerhold2020.age,westerhold2020.d18O_corrected,30,'loess');

Epochs = readtable('./../../Data/Cenozoic_Epochs.xlsx');

% Alkenones
Alk_anch = sortrows(Alk_anch,'age');
Alk_diff = sortrows(Alk_diff,'age');

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
number_of_plots = 10; %his is the number of axes you would like
plot_handles = stackplot(number_of_plots,"figure_handle",figure_handle);


%% d18O
current_plot_index = number_of_plots;
hold(plot_handles(current_plot_index),'on')

plot(westerhold2020.age,westerhold2020.d18O_corrected,'x','Color',rgb('LightGray'),'MarkerSize',2,'Parent',plot_handles(current_plot_index))
plot(westerhold2020.age,westerhold2020.d18O_smooth,'-','Color',rgb('Black'),'LineWidth',1,'Parent',plot_handles(current_plot_index))

set(plot_handles(current_plot_index),'YDir','reverse')
ylabel(plot_handles(current_plot_index),['\delta^{18}O (' char(8240) ')'])
axis(plot_handles(current_plot_index),[age_limits(1) age_limits(2) -1.5 5.5])

for epoch_index = 1:height(Epochs)
    plot([Epochs.Start(epoch_index),Epochs.Start(epoch_index)],[-2.5,-1.5],'Color',[0.5,0.5,0.5],'Parent',plot_handles(current_plot_index))
end

%% pH 
current_plot_index = current_plot_index-1; 
hold(plot_handles(current_plot_index),'on')

plot(d11B_pH.age/1000,d11B_pH.pH,'o','MarkerEdgeColor',rgb("Purple"),'MarkerFaceColor','None','MarkerSize',4,'Parent',plot_handles(current_plot_index))

ylabel(plot_handles(current_plot_index),'pH')
axis(plot_handles(current_plot_index),[age_limits(1),age_limits(2),-inf,inf])
set(plot_handles(current_plot_index),'YDir','reverse')

%% CCD
current_plot_index = number_of_plots-2;
hold(plot_handles(current_plot_index),'on');

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

ylabel(plot_handles(current_plot_index),'CCD Depth (m)')
axis(plot_handles(current_plot_index),[age_limits(1),age_limits(2),-inf,inf])
set(plot_handles(current_plot_index),'YDir','reverse')

%% Ca & Mg
current_plot_index = number_of_plots-5;
hold(plot_handles(current_plot_index),'on');

plot(mg_ca.age, mg_ca.Ca,'--','Color',rgb('LightGray'),'LineWidth',2,'Parent',plot_handles(current_plot_index))
plot(mg_ca.age,mg_ca.Ca+mg_ca.Ca_up,':','Color',rgb('LightGray'),'LineWidth',2,'Parent',plot_handles(current_plot_index))
plot(mg_ca.age,mg_ca.Ca-mg_ca.Ca_down,':','Color',rgb('LightGray'),'LineWidth',2,'Parent',plot_handles(current_plot_index))

for mg_ca_index=1:height(mg_ca)
    plot([mg_ca.age(mg_ca_index),mg_ca.age(mg_ca_index)],[mg_ca.Ca(mg_ca_index)-mg_ca.Ca_down(mg_ca_index),mg_ca.Ca(mg_ca_index)+mg_ca.Ca_up(mg_ca_index)],'-','Color',rgb('LightGray'),'LineWidth',6,'Parent',plot_handles(current_plot_index))
end
plot(mg_ca.age,mg_ca.Ca,'d','MarkerEdgeColor',rgb('Black'),'MarkerFaceColor',rgb('Grey'),'MarkerSize',8,'Parent',plot_handles(current_plot_index))

ylabel(plot_handles(current_plot_index),{'[Ca^{2+}]','(mmol/kg)'});
axis(plot_handles(current_plot_index),[age_limits(1),age_limits(2),7,25])

%% CONSTANT OMEGA %
current_plot_index = number_of_plots-3;
hold(plot_handles(current_plot_index),'on');

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
ylabel(plot_handles(current_plot_index),"Omega");

% CO3
current_plot_index = number_of_plots-4;
hold(plot_handles(current_plot_index),'on');

co2_to_plot = [1,2,3,4,5,6,7,8,9,11,12];

for co2_index = 1:numel(co2_to_plot)
    plot(co2_data{co2_to_plot(co2_index)}.age/1000,smooth(co2_data{co2_to_plot(co2_index)}.age/1000,co2_data{co2_to_plot(co2_index)}.co3,smoothing),"LineStyle",co2_line_style(co2_to_plot(co2_index)),'Color',rgb(co2_colours(co2_to_plot(co2_index))),'LineWidth',1,'Parent',plot_handles(current_plot_index))     
end
ylabel(plot_handles(current_plot_index),"CO3");

% Alkalinity
current_plot_index = number_of_plots-6;
hold(plot_handles(current_plot_index),'on');

co2_to_plot = [1,2,3,4,5,6,7,8,9,11,12];

for co2_index = 1:numel(co2_to_plot)
    plot(co2_data{co2_to_plot(co2_index)}.age/1000,smooth(co2_data{co2_to_plot(co2_index)}.age/1000,co2_data{co2_to_plot(co2_index)}.alkalinity,smoothing),"LineStyle",co2_line_style(co2_to_plot(co2_index)),'Color',rgb(co2_colours(co2_to_plot(co2_index))),'LineWidth',1,'Parent',plot_handles(current_plot_index))     
end
ylabel(plot_handles(current_plot_index),"Alkalinity");

% DIC
current_plot_index = number_of_plots-7;
hold(plot_handles(current_plot_index),'on');

co2_to_plot = [1,2,3,4,5,6,7,8,9,11,12];

for co2_index = 1:numel(co2_to_plot)
    plot(co2_data{co2_to_plot(co2_index)}.age/1000,smooth(co2_data{co2_to_plot(co2_index)}.age/1000,co2_data{co2_to_plot(co2_index)}.dic,smoothing),"LineStyle",co2_line_style(co2_to_plot(co2_index)),'Color',rgb(co2_colours(co2_to_plot(co2_index))),'LineWidth',1,'Parent',plot_handles(current_plot_index))     
end
ylabel(plot_handles(current_plot_index),"DIC");

% ALK/DIC
current_plot_index = number_of_plots-8;
hold(plot_handles(current_plot_index),'on');

co2_to_plot = [1,2,3,4,5,6,7,8,9,11,12];

for co2_index = 1:numel(co2_to_plot)
    plot(co2_data{co2_to_plot(co2_index)}.age/1000,smooth(co2_data{co2_to_plot(co2_index)}.age/1000,(co2_data{co2_to_plot(co2_index)}.alkalinity./co2_data{co2_to_plot(co2_index)}.dic),smoothing),"LineStyle",co2_line_style(co2_to_plot(co2_index)),'Color',rgb(co2_colours(co2_to_plot(co2_index))),'LineWidth',1,'Parent',plot_handles(current_plot_index))     
end
ylabel(plot_handles(current_plot_index),"ALK/DIC");

% CO2
current_plot_index = number_of_plots-9;
hold(plot_handles(current_plot_index),'on');

co2_to_plot = [1,2,3,4,5,6,7,8,9,11,12];

for co2_index = 1:numel(co2_to_plot)
    plot(co2_data{co2_to_plot(co2_index)}.age/1000,smooth(co2_data{co2_to_plot(co2_index)}.age/1000,co2_data{co2_to_plot(co2_index)}.xco2,smoothing),"LineStyle",co2_line_style(co2_to_plot(co2_index)),'Color',rgb(co2_colours(co2_to_plot(co2_index))),'LineWidth',1,'Parent',plot_handles(current_plot_index))     
end
ylabel(plot_handles(current_plot_index),"CO2");

%% axes etc
axpos = get(plot_handles(9),'Position');
set(plot_handles(9), 'Position', [axpos(1) axpos(2)+0.01 axpos(3) axpos(4)+0.02])
axpos = get(plot_handles(8),'Position');
set(plot_handles(8), 'Position', [axpos(1) axpos(2)+0.04 axpos(3) axpos(4)])
axpos = get(plot_handles(7),'Position');
set(plot_handles(7), 'Position', [axpos(1) axpos(2)+0.06 axpos(3) axpos(4)])
axpos = get(plot_handles(6),'Position');
set(plot_handles(6), 'Position', [axpos(1) axpos(2)+0.03 axpos(3) axpos(4)+0.05])
axpos = get(plot_handles(5),'Position');
set(plot_handles(5), 'Position', [axpos(1) axpos(2)+0.06 axpos(3) axpos(4)])
axpos = get(plot_handles(4),'Position');
set(plot_handles(4), 'Position', [axpos(1) axpos(2)+0.04 axpos(3) axpos(4)+0.03])
axpos = get(plot_handles(3),'Position');
set(plot_handles(3), 'Position', [axpos(1) axpos(2)+0.02 axpos(3) axpos(4)+0.03])
axpos = get(plot_handles(2),'Position');
set(plot_handles(2), 'Position', [axpos(1) axpos(2)-0.04 axpos(3) axpos(4)+0.05])
axpos = get(plot_handles(1),'Position');
set(plot_handles(1), 'Position', [axpos(1) axpos(2)-0.05 axpos(3) axpos(4)+0.07])


% axis(plot_handles(number_of_plots),[age_limits(1),age_limits(2),2.5,5])
ylabel(plot_handles(number_of_plots-2),'CCD (km)')
axis(plot_handles(number_of_plots-2),[age_limits(1),age_limits(2),2.5,5])
ylabel(plot_handles(number_of_plots-3),'\Omega')
axis(plot_handles(number_of_plots-3),[age_limits(1),age_limits(2),3,11])
ylabel(plot_handles(number_of_plots-4),'[CO_3^{2-}] \mumol/kg')
axis(plot_handles(number_of_plots-4),[age_limits(1),age_limits(2),-inf,inf])
ylabel(plot_handles(number_of_plots-6),'Alkalinity \mumol/kg')
axis(plot_handles(number_of_plots-6),[age_limits(1),age_limits(2),-inf,5000])
ylabel(plot_handles(number_of_plots-7),'DIC \mumol/kg')
axis(plot_handles(number_of_plots-7),[age_limits(1),age_limits(2),-inf,5000])
ylabel(plot_handles(number_of_plots-8),'ALK/DIC')
axis(plot_handles(number_of_plots-8),[age_limits(1),age_limits(2),-inf,inf])
set(plot_handles(number_of_plots-8),'YDir','reverse')
ylabel(plot_handles(number_of_plots-9),{'Atmospheric CO_2','(ppm)'})
axis(plot_handles(number_of_plots-9),[age_limits(1),age_limits(2),150,3200])

set(plot_handles(number_of_plots-9),'YScale','log','YTick',100:100:3200,'YTickLabel',{'' '200' '' '400' '' '' '' '800' '' '' '' '' '' '' '' '1600' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '3200'})

set(plot_handles(1),'XTick',age_ticks)
set(plot_handles(number_of_plots),'XTick',age_ticks)

xlabel(plot_handles(1),'Age (Ma)')

for i = 1:number_of_plots
    set(plot_handles(i),'XDir',age_direction,'TickDir','Out','XMinorTick','On','YMinorTick','On','FontSize',12)
end
set(gcf,'Position',[50,235,517,750]);

for plot_index = 1:2:number_of_plots
    current_label = get(plot_handles(plot_index),'YLabel');
    current_label.Rotation = -90;
    current_label.Position(1) = -8;
end

for plot_index = 1:2:5
    current_label = get(plot_handles(plot_index),'YLabel');
    current_label.Position(1) = -14;
end

%% Saving
exportgraphics(gcf,"./Figures/Cenozoic_d18O_pH_CCD_CO3_Ca_Alkalinity_DIC_CO2.png","Resolution",600);
exportgraphics(gcf,"./Figures/Cenozoic_d18O_pH_CCD_CO3_Ca_Alkalinity_DIC_CO2.pdf");
