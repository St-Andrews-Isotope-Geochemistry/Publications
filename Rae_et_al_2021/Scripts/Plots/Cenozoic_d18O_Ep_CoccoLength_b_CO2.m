% Plot Cenozoic d18O, Ep, Cocco length, b and CO2 data
%% Load the data
root_directory = "./../../";

westerhold2020 = readtable(root_directory+"Data/Westerhold_2020_d18O.xlsx",'Sheet','Matlab','Format','Auto');

% Alkenone Ep
% Anchored approach
alkenones_anchored = readtable(root_directory+"Data/Rae_2021_Alkenone_CO2.xlsx",'sheet','anchored');
% Diffusive approach
alkenones_diffusive = readtable(root_directory+"Data/Rae_2021_Alkenone_CO2.xlsx",'sheet','diffusive');

% Epoch data
epochs = readtable(root_directory+"Data/Cenozoic_Epochs.xlsx");

%% Analyse the data
% Remove NaN and smooth Westerhold
westerhold2020 = westerhold2020(~isnan(westerhold2020.age) & ~isnan(westerhold2020.d18O),:);
westerhold2020 = sortrows(westerhold2020);
westerhold2020.smooth = smooth(westerhold2020.age,westerhold2020.d18O_corrected,30,'loess');

% Alkenones
alkenones_anchored = sortrows(alkenones_anchored,'age');
alkenones_diffusive = sortrows(alkenones_diffusive,'age');

%% Make the figure
age_limits = [0,60];
age_ticks = 0:10:60;

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
plot(westerhold2020.age,westerhold2020.smooth,'-','Color',rgb('Black'),'LineWidth',1,'Parent',plot_handles(current_plot_index))

set(plot_handles(current_plot_index),'YDir','Reverse');
ylabel(plot_handles(current_plot_index),['\delta^{18}O (' char(8240) ')']);
axis(plot_handles(current_plot_index),[age_limits(1),age_limits(2),-2.5,5]);

for epoch_index = 1:height(epochs)
    plot([epochs.Start(epoch_index),epochs.Start(epoch_index)],[-2.5,-1.5],'Color',[0.5,0.5,0.5],'Parent',plot_handles(current_plot_index))
end

% Ep
current_plot_index = number_of_plots-1;
hold(plot_handles(current_plot_index),'on')

for anchored_index = 1:height(alkenones_anchored)
    plot(alkenones_anchored.age(anchored_index)/1000,alkenones_anchored.ep(anchored_index),'o','MarkerEdgeColor',rgb(alkenones_anchored.colour(anchored_index)),'MarkerFaceColor','none','MarkerSize',5,'Parent',plot_handles(current_plot_index))
end
for diffusive_index = 1:height(alkenones_diffusive)
    plot(alkenones_diffusive.age(diffusive_index)/1000,alkenones_diffusive.ep_50pc(diffusive_index),'x','MarkerEdgeColor',rgb(alkenones_diffusive.colour(diffusive_index)),'MarkerFaceColor','none','MarkerSize',alkenones_diffusive.size(diffusive_index),'Parent',plot_handles(current_plot_index))
end

ylabel(plot_handles(current_plot_index),[char(949),'_p (',char(8240),')'])
axis(plot_handles(current_plot_index),[age_limits(1) age_limits(2) -inf inf])
set(plot_handles(current_plot_index),'YScale','log')

% L cocco
current_plot_index = number_of_plots-2;
hold(plot_handles(current_plot_index),'on')

for diffusive_index = 1:height(alkenones_diffusive)
    plot(alkenones_diffusive.age(diffusive_index)/1000,alkenones_diffusive.coccolith_length(diffusive_index),'d','MarkerEdgeColor',rgb(alkenones_diffusive.colour(diffusive_index)),'MarkerFaceColor','none','MarkerSize',alkenones_diffusive.size(diffusive_index),'Parent',plot_handles(current_plot_index))
end

ylabel(plot_handles(current_plot_index),'Cocco mean Length (\mum)')
axis(plot_handles(current_plot_index),[age_limits(1),age_limits(2),2,10])

% b
current_plot_index = number_of_plots-3;
hold(plot_handles(current_plot_index),'on')


for diffusive_index = 1:height(alkenones_diffusive)
    plot(alkenones_diffusive.age(diffusive_index)/1000,alkenones_diffusive.b_50pc(diffusive_index),'p','MarkerEdgeColor',rgb(alkenones_diffusive.colour(diffusive_index)),'MarkerFaceColor','none','MarkerSize',alkenones_diffusive.size(diffusive_index),'Parent',plot_handles(current_plot_index))
end

ylabel(plot_handles(current_plot_index),'b')
axis(plot_handles(current_plot_index),[age_limits(1),age_limits(2),60,inf])
set(plot_handles(current_plot_index),'YDir','reverse')

% CO2
current_plot_index = number_of_plots-4;
hold(plot_handles(current_plot_index),'on')

for anchored_index = 1:height(alkenones_anchored)
    plot(alkenones_anchored.age(anchored_index)/1000,alkenones_anchored.co2(anchored_index),alkenones_anchored.symbol{anchored_index},'MarkerEdgeColor',rgb(alkenones_anchored.colour(anchored_index)),'MarkerFaceColor','none','MarkerSize',alkenones_anchored.size(anchored_index),'Parent',plot_handles(current_plot_index))
end
for diffusive_index = 1:height(alkenones_diffusive)
    plot(alkenones_diffusive.age(diffusive_index)/1000,alkenones_diffusive.co2(diffusive_index),'x','MarkerEdgeColor',rgb(alkenones_diffusive.colour(diffusive_index)),'MarkerFaceColor','none','MarkerSize',alkenones_diffusive.size(diffusive_index),'Parent',plot_handles(current_plot_index))
end

ylabel(plot_handles(current_plot_index),'Atmospheric CO_2 (ppm)')
axis(plot_handles(current_plot_index),[age_limits(1),age_limits(2),-inf,inf])
set(plot_handles(current_plot_index),'YScale','Log','YTick',100:100:3000,'YTickLabel',{'100','200','300','400','500','600','','800','','1000','','1200','','','1500','','','','','2000','','','','','','','','','',''});

%% Manual axis adjustments
axis_position = get(plot_handles(1),'Position');
set(plot_handles(1), 'Position', [axis_position(1),axis_position(2)-0.05,axis_position(3),axis_position(4)+0.15])
axis_position = get(plot_handles(2),'Position');
set(plot_handles(2), 'Position', [axis_position(1),axis_position(2)+0.1,axis_position(3),axis_position(4)-0.05])
axis_position = get(plot_handles(3),'Position');
set(plot_handles(3), 'Position', [axis_position(1),axis_position(2)+0.08,axis_position(3),axis_position(4)-0.05])

%% Display
set(plot_handles(1),'XTick',age_ticks)
set(plot_handles(number_of_plots),'XTick',age_ticks)

xlabel(plot_handles(1),'Age (Ma)')

for plot_index = 1:number_of_plots
    set(plot_handles(plot_index),'XDir',age_direction,'TickDir','Out','XMinorTick','On','YMinorTick','On','FontSize',10)
end

for plot_index = 1:2:number_of_plots
    current_label = get(plot_handles(plot_index),'YLabel');
    current_label.Rotation = -90;
    current_label.Position(1) = -13;
end

figure_height = 600;
figure_width = 465;

screen_size = get(0,'ScreenSize');
left_margin = 0.1*screen_size(3);
bottom_margin = 0.1*screen_size(4);

set(gcf,'Position',[left_margin,bottom_margin,figure_width,figure_height])

%% Saving
exportgraphics(gcf,root_directory+"/Figures/Cenozoic_d18O_Ep_CoccoLength_b_CO2.png","Resolution",600);
exportgraphics(gcf,root_directory+"/Figures/Cenozoic_d18O_Ep_CoccoLength_b_CO2.pdf");