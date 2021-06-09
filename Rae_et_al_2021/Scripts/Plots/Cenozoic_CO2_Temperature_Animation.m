%% Plot Cenozoic CO2 alongside ice core records and modern CO2 with projections
%% Load the data
clear
root_directory = "./../../";

% d18O
westerhold2020 = readtable(root_directory+"/Data/Westerhold_2020_d18O.xlsx",'Sheet','Matlab','Format','Auto');

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
alkenones_anchored = readtable(root_directory+"/Data/Supplements/Rae_2021_Alkenone_CO2.xlsx","Sheet","anchored");
% Diffusive approach
alkenones_diffusive = readtable(root_directory+"/Data/Supplements/Rae_2021_Alkenone_CO2.xlsx","Sheet","diffusive");

co2_combined = [co2_data{2}.xco2;alkenones_anchored.co2;alkenones_diffusive.co2];
age_combined = [co2_data{2}.age;alkenones_anchored.age;alkenones_diffusive.age];

no_ice_hansen_calibration = @(d18O) -4*d18O+12;

%% Analyse the data
% Smoothing CO2
bin_width = 0.1;
bin_lefts = 0:bin_width:70;
co2_binned = [];
for bin_left = bin_lefts
    co2_binned = [co2_binned,mean(co2_combined(age_combined/1000>=bin_left & age_combined/1000<bin_left+bin_width))];
end
co2_smoothed = smooth(bin_lefts,co2_binned,25);

% Alkenones
alkenones_anchored = sortrows(alkenones_anchored,'age');
alkenones_diffusive = sortrows(alkenones_diffusive,'age');

ep_age = [alkenones_anchored.age(alkenones_anchored.age/1000<23); alkenones_diffusive.age(alkenones_diffusive.age/1000>23)];
ep_co2 = [alkenones_anchored.co2(alkenones_anchored.age/1000<23); alkenones_diffusive.co2(alkenones_diffusive.age/1000>23)];
ep_combined = table(ep_age,ep_co2);

% Calculate SSP_data age
SSP_data.age = 1950-SSP_data.year;

% Remove NaN and smooth Westerhold
westerhold2020 = westerhold2020(~isnan(westerhold2020.age) & ~isnan(westerhold2020.d18O),:);
westerhold2020 = sortrows(westerhold2020);
westerhold2020.smooth = smooth(westerhold2020.age,westerhold2020.d18O_corrected,30,'loess');
westerhold2020.surface_ocean_temperature_smooth = smooth(westerhold2020.age,westerhold2020.surface_ocean_temperature,4000,'loess');

%% Make the figure
clf
figure_handle = figure(1);
figure_handle.Color = "White";

% pause

% Create an initial size for xaxissplit
y_min = 180;
y_max = 2300;
figure_position = [100,200,600,360];
axis_position = [0.1300,0.1000,0.750,0.500];
upper_axis_position = axis_position+[0,0.52,0,-0.15];
number_of_plots = 3;

plot_handles = xaxissplit(number_of_plots,figure_position,axis_position,[y_min,y_max],"figure_handle",figure_handle);
upper_plot_handles = xaxissplit(number_of_plots,figure_position,upper_axis_position,[0,30],"figure_handle",figure_handle);
set(gcf,'Position',figure_position);

ep_size = 2;
temperature_size = 6;

plot_final_positions_1 = plot_handles(1).Position;
plot_initial_positions_1 = plot_handles(1).Position;
plot_initial_positions_1(3) = (plot_handles(3).Position(1)+plot_handles(3).Position(3))-plot_handles(1).Position(1);

plot_final_positions_2 = plot_handles(2).Position;
plot_initial_positions_2 = plot_handles(2).Position;
plot_initial_positions_2(3) = (plot_handles(3).Position(1)+plot_handles(3).Position(3))-plot_handles(2).Position(1);

plot_initial_positions_3 = plot_handles(3).Position;
plot_final_positions_3 = plot_handles(3).Position;
plot_final_positions_3(1) = plot_final_positions_2(1)+plot_final_positions_2(3);

set(plot_handles(1),'Position',plot_initial_positions_1);
set(plot_handles(2),'Position',plot_initial_positions_2,'XColor','None');
set(plot_handles(3),'XColor','None');

set(plot_handles(2),'YColor','None');
set(plot_handles(3),'YColor','None');


upper_plot_final_positions_1 = upper_plot_handles(1).Position;
upper_plot_initial_positions_1 = upper_plot_handles(1).Position;
upper_plot_initial_positions_1(3) = (upper_plot_handles(3).Position(1)+upper_plot_handles(3).Position(3))-upper_plot_handles(1).Position(1);

upper_plot_final_positions_2 = upper_plot_handles(2).Position;
upper_plot_initial_positions_2 = upper_plot_handles(2).Position;
upper_plot_initial_positions_2(3) = (upper_plot_handles(3).Position(1)+upper_plot_handles(3).Position(3))-upper_plot_handles(2).Position(1);

upper_plot_initial_positions_3 = upper_plot_handles(3).Position;
upper_plot_final_positions_3 = upper_plot_handles(3).Position;
upper_plot_final_positions_3(1) = upper_plot_final_positions_2(1)+upper_plot_final_positions_2(3);

set(upper_plot_handles(1),'Position',upper_plot_initial_positions_1);
set(upper_plot_handles(2),'Position',upper_plot_initial_positions_2,'XColor','None');
set(upper_plot_handles(3),'XColor','None');

set(upper_plot_handles(2),'YColor','None');
set(upper_plot_handles(3),'YColor','None');


%% Plot the data
% Palaeo data
current_plot_index = 1;
hold(plot_handles(current_plot_index),'On');
hold(upper_plot_handles(current_plot_index),'On');
set(plot_handles(current_plot_index),'Xlim',[0,60]);
set(upper_plot_handles(current_plot_index),'Xlim',[0,60]);

xlabel(plot_handles(1),'Millions of years ago');
ylabel(upper_plot_handles(1),"Temperature (^{\circ}C)",'FontSize',14);
ylabel(plot_handles(1),"Atmospheric CO_2 (ppm)",'FontSize',14);
set(plot_handles(1),'YLim',[100,1600],'XDir','Reverse','TickDir','Out','YMinorTick','On','FontSize',8);
set(upper_plot_handles(1),'YLim',[8,30],'XDir','Reverse','TickDir','Out','YMinorTick','On','FontSize',8,'XTick',[],'XColor','None');

colourmap = Geochemistry_Helpers.Colour.Map("rb",[Geochemistry_Helpers.Colour.Colour("Navy","ryb",0),...
                                                  Geochemistry_Helpers.Colour.Colour("DeepSkyBlue","ryb",10),...
                                                  Geochemistry_Helpers.Colour.Colour("Khaki","ryb",15),...
                                                  Geochemistry_Helpers.Colour.Colour("IndianRed","ryb",20),...
                                                  Geochemistry_Helpers.Colour.Colour("Firebrick","ryb",30)]);
expanded_colourmap = colourmap.getColours(100);
colormap(expanded_colourmap.colours.rgb);
cla(upper_plot_handles(1));

wobj = VideoWriter('./../../Animations/Cenozoic_CO2_Temperature_Animation.mp4',"MPEG-4");
wobj.FrameRate = 30;                  % frames per second (video speed)
open(wobj);                           % open file
for animation_index = 70:-0.2:0
    cla(plot_handles(1));

    boron_condition = age_combined/1000>=animation_index;
    boron_pop_condition = age_combined/1000<animation_index & age_combined/1000>animation_index-2;
    boron_pop_distance = 1-((animation_index-age_combined(boron_pop_condition)/1000)/2);
    boron_line_condition = bin_lefts>=animation_index & bin_lefts<=58;

    temperature_condition = westerhold2020.age>=animation_index-0.2 & westerhold2020.age<animation_index;
    temperature_pop_condition = westerhold2020.age<animation_index & westerhold2020.age>animation_index-2;
    temperature_pop_distance = 1-((animation_index-westerhold2020.age(temperature_pop_condition))/2);

    plot(bin_lefts(boron_line_condition),co2_smoothed(boron_line_condition),'-','Color',rgb('Black'),'LineWidth',2,'Parent',plot_handles(current_plot_index))

    temperature_interpolate = max(westerhold2020.surface_ocean_temperature_smooth(temperature_condition));
    if temperature_interpolate>30
        temperature_interpolate = 30;
    elseif temperature_interpolate<12
        temperature_interpolate = 12;
    end
    temperature_colour = expanded_colourmap.interpolate(interp1([12,30],[0,30],temperature_interpolate));
    plot(westerhold2020.age(temperature_condition),westerhold2020.surface_ocean_temperature_smooth(temperature_condition),'-','Color',rgb("FireBrick"),'LineWidth',2,'Parent',upper_plot_handles(current_plot_index))

    if animation_index<53+5
        t_distance = min([1-((animation_index-53)/5),1]);
        t(1) = text(53,1750,["\it Peak","greenhouse"],'Color',t_distance.*rgb('Grey')+(1-t_distance).*rgb("White"),'FontSize',11,'Parent',plot_handles(current_plot_index));
    end
    if animation_index<45+5
        t_distance = min([1-((animation_index-45)/5),1]);
        t(3) = text(45,1300,["\it Alligators in","the Arctic"],'Color',t_distance.*rgb('Grey')+(1-t_distance).*rgb("White"),'FontSize',11,'Parent',plot_handles(current_plot_index));
    end
    if animation_index<13+5
        t_distance = min([1-((animation_index-13)/5),1]);
        t(4) = text(13,800,["\it Expansion", "of ice"],'Color',t_distance.*rgb('Grey')+(1-t_distance).*rgb("White"),'FontSize',11,'Parent',plot_handles(current_plot_index));
    end
    if animation_index<31+5
        t_distance = min([1-((animation_index-31)/5),1]);
        t(5) = text(31,900,["\it Ice grows on","Antarctica"],'Color',t_distance.*rgb('Grey')+(1-t_distance).*rgb("White"),'FontSize',11,'Parent',plot_handles(1));
    end
    
    caxis(upper_plot_handles(1),[12,30]);
    
    drawnow;
    filename = "temporary_image"; % full name of image
    print('-djpeg','-r200',filename)     % save image with '-r200' resolution
    image = imread(filename+".jpg");       % read saved image
    frame = im2frame(image);              % convert image to frame
    writeVideo(wobj,frame);           % save frame into video    
end
close(wobj);
