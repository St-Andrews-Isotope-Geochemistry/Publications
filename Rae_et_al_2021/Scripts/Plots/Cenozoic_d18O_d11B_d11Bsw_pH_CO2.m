% Plot of Cenozoic d18O, d11B, d11B_sw, pH and Atmospheric CO2
%% Load in the data
root_directory = "./../../";

% d18O
westerhold2020 = readtable(root_directory+"/Data/Westerhold_2020_d18O.xlsx",'Sheet','Matlab','Format','Auto');

% d11B_sw
paris2010 = readtable(root_directory+"/Data/d11Bsw_compilation.xlsx",'sheet','Paris2010'); % halites - no outliers removed
raitzsch2013 = readtable(root_directory+"/Data/d11Bsw_compilation.xlsx",'sheet','Raitzsch2013'); % Raitzsch & Honisch version using Klochko
lemarchand2000 = readtable(root_directory+"/Data/d11Bsw_compilation.xlsx",'sheet','Lemarchand2000'); % Lemarchand cnst rivers version
anagnostou2016 = readtable(root_directory+"/Data/d11Bsw_compilation.xlsx",'sheet','Anagnostou2016'); % Eleni
greenop2017 = readtable(root_directory+"/Data/d11Bsw_compilation.xlsx",'sheet','Greenop2017_boxes'); % Greenop - plot boxes as in Figure 10
greenop2017_smooth = readtable(root_directory+"/Data/d11Bsw_compilation.xlsx",'sheet','Greenop2017_smooth');
henehan2019 = readtable(root_directory+"/Data/d11Bsw_compilation.xlsx",'sheet','Henehan2019updated'); % Henehan 2019
henehan2020 = readtable(root_directory+"/Data/d11Bsw_compilation.xlsx",'sheet','Henehan2020'); % Henehan 2020
rae2021 = readtable(root_directory+"/Data/d11Bsw_compilation.xlsx",'sheet','Rae2021Comp');

% pH
d11B_pH = readtable(root_directory+"/Data/Rae_2021_Cenozoic_CO2_Precalculated.xlsx","Sheet","d11B_data");

% CO2
co2_sheet_names = ["ccd","Omega65","Omega5","Omega8","dic","alkalinity_high","alkalinity_low","alkalinity","alkalinity_d11Bswlow","alkalinity_d11Bswhigh"];

for sheet_index = 1:numel(co2_sheet_names)
    co2_data{sheet_index} = readtable(root_directory+"/Data/Rae_2021_Cenozoic_CO2_Precalculated.xlsx","Sheet",co2_sheet_names(sheet_index));
end

%% Analyse the data
% d18O
westerhold2020 = westerhold2020(~isnan(westerhold2020.age) & ~isnan(westerhold2020.d18O),:);
westerhold2020 = sortrows(westerhold2020);
westerhold2020.d18O_smooth = smooth(westerhold2020.age,westerhold2020.d18O_corrected,50,'loess');

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
number_of_plots = 5; % This is the number of axes you would like
plot_handles = stackplot(number_of_plots,"figure_handle",figure_handle);


%% Plot the data
% d18O
current_plot_index = number_of_plots;
hold(plot_handles(current_plot_index),'on')

plot(westerhold2020.age,westerhold2020.d18O_corrected,'x','Color',rgb('LightGray'),'MarkerSize',2,'Parent',plot_handles(current_plot_index))
plot(westerhold2020.age,westerhold2020.d18O_smooth,'-','Color',rgb('Black'),'LineWidth',1,'Parent',plot_handles(current_plot_index))

set(plot_handles(current_plot_index),'YDir','Reverse')
ylabel(plot_handles(current_plot_index),['\delta^{18}O (' char(8240) ')'])
axis(plot_handles(current_plot_index),[age_limits(1),age_limits(2),-3,5.5])

% d11B_borate
current_plot_index = number_of_plots-1;
hold(plot_handles(current_plot_index),'on');

scale_down_boolean = (d11B_pH.colour=="Plum" | d11B_pH.colour=="Purple" | d11B_pH.colour=="BlueViolet" | d11B_pH.colour=="DarkOrchid");
d11B_pH.size(scale_down_boolean,:) = 8;

scale_down_boolean = (d11B_pH.symbol=="v");
d11B_pH.size(scale_down_boolean,:) = 6;

d11B_pH.size(d11B_pH.size>10,:) = 10;

for d11B_index = 1:height(d11B_pH)
    plot([d11B_pH.age(d11B_index)/1000,d11B_pH.age(d11B_index)/1000],[d11B_pH.d11B_4(d11B_index)-d11B_pH.d11B_2SD(d11B_index),d11B_pH.d11B_4(d11B_index)+d11B_pH.d11B_2SD(d11B_index)],'Color',[0.5,0.5,0.5],'Parent',plot_handles(current_plot_index))
end
for d11B_index = 1:height(d11B_pH)
    plot(d11B_pH.age(d11B_index)/1000,d11B_pH.d11B_4(d11B_index),d11B_pH.symbol{d11B_index},'MarkerEdgeColor',rgb('Black'),'LineWidth',0.2,'MarkerFaceColor',rgb(d11B_pH.colour(d11B_index)),'MarkerSize',d11B_pH.size(d11B_index)-2,'Parent',plot_handles(current_plot_index))
end

ylabel(plot_handles(current_plot_index),['\delta^{11}B_{borate} (',char(8240),')'])
axis(plot_handles(current_plot_index),[age_limits(1),age_limits(2),-inf,inf]);
set(plot_handles(current_plot_index),'YDir','reverse');

% d11B_sw
current_plot_index = number_of_plots-2;
hold(plot_handles(current_plot_index),'on')

plot(paris2010.Age,paris2010.d11Bsw,'v','MarkerEdgeColor',rgb('Orange'),'MarkerFaceColor','none','MarkerSize',6,'Color',rgb('Grey'),'Parent',plot_handles(current_plot_index))
plot(raitzsch2013.Age, raitzsch2013.d11Bsw_Klochko,'x','MarkerEdgeColor',rgb('LightGrey'),'MarkerSize',4,'Parent',plot_handles(current_plot_index))
plot(lemarchand2000.Age, lemarchand2000.d11Bsw,'-.','Color',rgb('Grey'),'LineWidth',1,'Parent',plot_handles(current_plot_index))
plot(anagnostou2016.Age, anagnostou2016.d11Bsw,'s','MarkerEdgeColor',rgb('Black'),'MarkerFaceColor',rgb('Red'),'MarkerSize',8,'Color',rgb('Grey'),'Parent',plot_handles(current_plot_index))
plot(anagnostou2016.Age, anagnostou2016.d11BswUpper_usingSacc,'+','MarkerEdgeColor',rgb('DarkRed'),'MarkerFaceColor',rgb('DarkRed'),'MarkerSize',10,'Color',rgb('Grey'),'Parent',plot_handles(current_plot_index))
plot(anagnostou2016.Age, anagnostou2016.d11BswLower,'_','MarkerEdgeColor',rgb('DarkRed'),'MarkerFaceColor',rgb('DarkRed'),'MarkerSize',20,'Color',rgb('Grey'),'Parent',plot_handles(current_plot_index))

for greenop_index = 1:(height(greenop2017))
    plot([greenop2017.agelow(greenop_index),greenop2017.ageup(greenop_index),greenop2017.ageup(greenop_index),greenop2017.agelow(greenop_index),greenop2017.agelow(greenop_index)],[greenop2017.low(greenop_index),greenop2017.low(greenop_index),greenop2017.up(greenop_index),greenop2017.up(greenop_index),greenop2017.low(greenop_index)],'Color',rgb('LightCoral'),'Parent',plot_handles(current_plot_index));
    plot([greenop2017.agelow(greenop_index),greenop2017.ageup(greenop_index)],[greenop2017.med(greenop_index) greenop2017.med(greenop_index)],'Color',rgb('LightCoral'),'LineWidth',2,'Parent',plot_handles(current_plot_index))
end
plot(greenop2017_smooth.age, greenop2017_smooth.maxprob,'--','Color',rgb('Salmon'),'LineWidth',1,'Parent',plot_handles(current_plot_index))

plot(henehan2019.Age,henehan2019.d11Bsw,'o','MarkerEdgeColor',rgb('Black'),'MarkerFaceColor',rgb('Pink'),'MarkerSize',10,'Color',rgb('Grey'),'Parent',plot_handles(current_plot_index))
errorbar(henehan2019.Age,henehan2019.d11Bsw,henehan2019.d11Bswer,'LineWidth',2,'Color',rgb('Black'),'Parent',plot_handles(current_plot_index));

plot(henehan2020.Age, henehan2020.d11Bsw,'d','MarkerEdgeColor',rgb('Black'),'MarkerFaceColor',rgb('Crimson'),'MarkerSize',10,'Color',rgb('Grey'),'Parent',plot_handles(current_plot_index))
errorbar(henehan2020.Age, henehan2020.d11Bsw, henehan2020.d11Bswer, 'LineWidth',2,'Color',rgb('Black'),'Parent',plot_handles(current_plot_index));

plot(rae2021.age, rae2021.d11B_sw,'--','Color',rgb('Black'),'LineWidth',3,'Parent',plot_handles(current_plot_index))
plot(rae2021.age, rae2021.d11B_sw_95_low,'--','Color',[0.3 0.3 0.3],'LineWidth',1,'Parent',plot_handles(current_plot_index))
plot(rae2021.age, rae2021.d11B_sw_95_high,'--','Color',[0.3 0.3 0.3],'LineWidth',1,'Parent',plot_handles(current_plot_index))

ylabel(plot_handles(current_plot_index),['\delta^{11}B_{seawater} (',char(8240),')']);
axis(plot_handles(current_plot_index),[age_limits(1),age_limits(2),31.5,42])


% pH 
current_plot_index = 2;
hold(plot_handles(current_plot_index),'on')
plot(d11B_pH.age/1000, d11B_pH.pH,'o','MarkerEdgeColor',rgb('Gray'),'MarkerFaceColor','None','MarkerSize',5,'Parent',plot_handles(current_plot_index))
% plot(d11B_pH.age/1000,smooth(d11B_pH.age/1000,d11B_pH.pH,20),'--','Color',[0.3,0.3,0.3],'LineWidth',1.5,'Parent',plot_handles(current_plot_index))

% error bars
% for pH_index = 1:height(d11B_pH)
%     plot([d11B_pH.age(pH_index)/1000,d11B_pH.age(pH_index)/1000],[d11B_pH.pH(pH_index)-d11B_pH.pH_uncertainty(pH_index),d11B_pH.pH(pH_index)+d11B_pH.pH_uncertainty(pH_index)],'Color',[0.5,0.5,0.5],'Parent',plot_handles(current_plot_index))
% end

% plot(Alld11B.age/1000, Alld11B.pH,'o','MarkerEdgeColor',[0.05,0.05,0.05],'MarkerFaceColor','None','MarkerSize',5,'Parent',plot_handles(current_plot_index))

% do for variable d11Bsw
plot(d11B_pH.age/1000,smooth(d11B_pH.age/1000,co2_data{9}.pH_swlow,20),'--','Color',[0.3,0.3,0.3],'LineWidth',1,'Parent',plot_handles(current_plot_index))
plot(d11B_pH.age/1000,smooth(d11B_pH.age/1000,co2_data{10}.pH_swhigh,20),'--','Color',[0.3,0.3,0.3],'LineWidth',1,'Parent',plot_handles(current_plot_index))
plot(d11B_pH.age/1000,d11B_pH.pH,'o','MarkerEdgeColor',[0.05,0.05,0.05],'MarkerFaceColor','none','MarkerSize',5,'Parent',plot_handles(current_plot_index))

% Labelling
ylabel(plot_handles(current_plot_index),'pH');
axis(plot_handles(current_plot_index),[age_limits(1),age_limits(2),7.3,8.3]);
set(plot_handles(current_plot_index),'YDir','reverse');


% CO2
current_plot_index = 1;
hold(plot_handles(current_plot_index),'on')


% co2_data = {csysOUT_CCDZTCO3,csysOUT_Om65,csysOUT_Om5,csysOUT_Om8,csysOUT_DIC,csysOUT_ALK_UP,csysOUT_ALK_LOW,csysOUT_ALK};
co2_symbols = ["x","d","v","^","*","^","v","o"];
co2_colours = ["Grey","DarkGrey","DarkGrey","DarkGrey","LightBlue","DarkBlue","DarkBlue","DarkBlue"];
co2_line_width = [NaN,2,1,1,NaN,1,1,2];
co2_line_style = [NaN,"--",":",":",NaN,":",":","--"];
co2_size = [4,4,4,4,4,5,5,5];

co2_with_symbols = [1,2,5,8];
for co2_index = co2_with_symbols
    plot(d11B_pH.age/1000,co2_data{co2_index}.xco2,co2_symbols(co2_index),'MarkerEdgeColor',rgb(co2_colours(co2_index)),'MarkerSize',co2_size(co2_index),'Parent',plot_handles(1));
end
co2_with_lines = [2,3,4,6,7,8];

for co2_index = co2_with_lines
    plot(d11B_pH.age/1000,smooth(d11B_pH.age/1000,co2_data{co2_index}.xco2,30,'rlowess'),"LineStyle",co2_line_style(co2_index),'Color',rgb(co2_colours(co2_index)),'LineWidth',co2_line_width(co2_index),'Parent',plot_handles(1))
end
ylabel(plot_handles(current_plot_index),'Atmospheric CO_2 (ppmv)');
axis(plot_handles(current_plot_index),[age_limits(1),age_limits(2),-inf,12000]);

%% axis etc
set(plot_handles(1),'YScale','log','YTick',100:100:3000,'YTickLabel',{'100' '200' '300' '400' '500' '600' '' '800' '' '1000' '' '1200' '' '' '1500' '' '' '' '' '2000' '' '' '' '' '' '' '' '' '' '3000'})

%[left bottom width height]
axpos = get(plot_handles(1),'Position');
set(plot_handles(1), 'Position', [axpos(1) axpos(2) axpos(3) axpos(4)+0.17])
axpos = get(plot_handles(2),'Position');
set(plot_handles(2), 'Position', [axpos(1) axpos(2)+0.05 axpos(3) axpos(4)])
axpos = get(plot_handles(3),'Position');
set(plot_handles(3), 'Position', [axpos(1) axpos(2)+0.02 axpos(3) axpos(4)])
axpos = get(plot_handles(4),'Position');
set(plot_handles(4), 'Position', [axpos(1) axpos(2)+0.02 axpos(3) axpos(4)])

set(plot_handles(1),'XTick',age_ticks)
set(plot_handles(number_of_plots),'XTick',age_ticks)
xlabel(plot_handles(1),'Age (Ma)')


for plot_index = 1:number_of_plots
    set(plot_handles(plot_index),'XDir',age_direction,'TickDir','Out','XMinorTick','On','YMinorTick','On','FontSize',12)
end
for plot_index = 1:2:number_of_plots
    current_label = get(plot_handles(plot_index),'YLabel');
    current_label.Rotation = -90;
    current_label.Position(1) = -15.5;
end

set(gcf,'Position',[308   160   481   545])

figure_width = 500;
figure_height = 815;

screen_size = get(0,'ScreenSize');
left_margin = 0.1*screen_size(3);
bottom_margin = 0.1*screen_size(4);
set(gcf,'Position',[left_margin,bottom_margin,figure_width,figure_height]);

%% Saving
exportgraphics(gcf,root_directory+"/Figures/Cenozoic_d18O_d11B_d11Bsw_pH_CO2.png","Resolution",600);
exportgraphics(gcf,root_directory+"/Figures/Cenozoic_d18O_d11B_d11Bsw_pH_CO2.pdf");