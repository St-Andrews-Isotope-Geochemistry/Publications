%% Plot Cenozoic CO2 alongside ice core records and modern CO2 with projections
%% Load the data
clear
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
alkenones_anchored = readtable(root_directory+"/Data/Supplements/Rae_2021_Alkenone_CO2.xlsx","Sheet","anchored");
% Diffusive approach
alkenones_diffusive = readtable(root_directory+"/Data/Supplements/Rae_2021_Alkenone_CO2.xlsx","Sheet","diffusive");

co2_combined = [co2_data{2}.xco2;alkenones_anchored.co2;alkenones_diffusive.co2];
age_combined = [co2_data{2}.age;alkenones_anchored.age;alkenones_diffusive.age];

%% Analyse the data
% Smoothing CO2
bin_width = 0.05;
bin_lefts = 0:bin_width:70;
co2_binned = [];
for bin_left = bin_lefts
    co2_binned = [co2_binned,mean(co2_combined(age_combined/1000>=bin_left & age_combined/1000<bin_left+bin_width))];
end
co2_smoothed = smooth(bin_lefts,co2_binned,15);
co2_smoothed(bin_lefts>56) = NaN;

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

% pause

% Create an initial size for xaxissplit
y_min = 180;
y_max = 2300;
figure_position = [100,200,815,360];
axis_position = [0.1300,0.2000,0.7750,0.700];
number_of_plots = 3;

plot_handles = xaxissplit(number_of_plots,figure_position,axis_position,[y_min,y_max],"figure_handle",figure_handle);
set(gcf,'Position',figure_position);

ep_size = 3;

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

%% Plot the data
% Palaeo data
current_plot_index = 1;
hold(plot_handles(current_plot_index),'On');
set(plot_handles(current_plot_index),'Xlim',[0.8,60]);

xlabel(plot_handles(1),'Millions of years ago');
ylabel(plot_handles(1),"Atmospheric CO_2 (ppm)",'FontSize',14);
set(plot_handles(1),'YLim',[150,1700],'XDir','Reverse','TickDir','Out','YMinorTick','On','FontSize',8);

% exportgraphics(gcf,"Cenozoic-Today_Start.pdf");

wobj = VideoWriter('./../../Animations/Cenozoic_CO2_SSPs_Animation.mp4',"MPEG-4");
wobj.FrameRate = 30;                  % frames per second (video speed)
open(wobj);                           % open file
for animation_index = 70:-0.2:1
    cla(plot_handles(1));
    
    boron_condition = age_combined/1000>=animation_index;
    boron_pop_condition = age_combined/1000<animation_index & age_combined/1000>animation_index-2;
    boron_pop_distance = 1-((animation_index-age_combined(boron_pop_condition)/1000)/2);
    boron_line_condition = bin_lefts>=animation_index;
    
    plot(bin_lefts(boron_line_condition),co2_smoothed(boron_line_condition),'-','Color',rgb('Black'),'LineWidth',2,'Parent',plot_handles(current_plot_index))

    if animation_index<49+5
        t_distance = min([1-((animation_index-49)/5),1]);
        t(3) = text(49,1600,["\it Alligators in","the Arctic"],'Color',t_distance.*rgb('Grey')+(1-t_distance).*rgb("White"),'FontSize',11,'Parent',plot_handles(current_plot_index));
    end
    if animation_index<10+5
        t_distance = min([1-((animation_index-10)/5),1]);
        t(4) = text(10,600,["\it Expansion", "of ice"],'Color',t_distance.*rgb('Grey')+(1-t_distance).*rgb("White"),'FontSize',11,'Parent',plot_handles(current_plot_index));
    end
    if animation_index<32+5
        t_distance = min([1-((animation_index-32)/5),1]);
        t(5) = text(32,900,["\it Ice grows on","Antarctica"],'Color',t_distance.*rgb('Grey')+(1-t_distance).*rgb("White"),'FontSize',11,'Parent',plot_handles(1));
    end
    
    drawnow;
    filename = "temporary_image"; % full name of image
    print('-djpeg','-r600',filename)     % save image with '-r600' resolution
    image = imread(filename+".jpg");       % read saved image
    frame = im2frame(image);              % convert image to frame
    writeVideo(wobj,frame);           % save frame into video    
end



%% Plio-Pleisto
current_plot_index = 2;
hold(plot_handles(current_plot_index),'On');
set(plot_handles(current_plot_index),'XLim',[1,800]);

xlabel(plot_handles(2),'Hundreds of thousands of years ago');
set(plot_handles(2),'YLim',[150,1700],'XDir','Reverse','TickDir','Out','YMinorTick','On','FontSize',8,'YColor','None');

for animation_index = 0:0.5:10
    current_position_1 = (1-animation_index/10)*plot_initial_positions_1+(animation_index/10)*plot_final_positions_1;
    set(plot_handles(1),'Position',current_position_1);
    
    current_position_2 = [current_position_1(1)+current_position_1(3),plot_final_positions_2(2),(animation_index/10).*plot_initial_positions_2(3),plot_final_positions_2(4)];
    set(plot_handles(2),'Position',current_position_2);
    
    t_distance = 1-animation_index/10;

    set(plot_handles(2),'XColor',1-0.1*[animation_index,animation_index,animation_index]);

    drawnow;
    filename = "test"; % full name of image
    print('-djpeg','-r600',filename)     % save image with '-r600' resolution
    image = imread(filename+".jpg");       % read saved image
    frame = im2frame(image);              % convert image to frame
    writeVideo(wobj,frame);           % save frame into video    
end

bin_width = 0.001;
bin_lefts = 0:bin_width:1;
co2_binned = [];
for bin_left = bin_lefts
    co2_binned = [co2_binned,mean(co2_combined(age_combined/1000>=bin_left & age_combined/1000<bin_left+bin_width))];
end
co2_smoothed = smooth(bin_lefts,co2_binned,10);


for animation_index = 800:-5:1
    cla(plot_handles(2));
    
    boron_condition = age_combined>=animation_index;
    boron_pop_condition = age_combined<animation_index & age_combined>animation_index-50;
    boron_pop_distance = 1-((animation_index-age_combined(boron_pop_condition))/50);
    
    ice_condition = (ice_data.Age_from_1950+50)/1e3>animation_index;
    boron_line_condition = bin_lefts>=animation_index;
    
    % Boron
%     scatter(age_combined(boron_condition),co2_combined(boron_condition),ep_size,rgb('SteelBlue'),'MarkerFaceColor',rgb('SteelBlue'),'Parent',plot_handles(current_plot_index))
%     scatter(age_combined(boron_pop_condition),co2_combined(boron_pop_condition),boron_pop_distance.*ep_size,rgb('SteelBlue'),'MarkerFaceColor',rgb('SteelBlue'),'Parent',plot_handles(current_plot_index))
%     plot(bin_lefts(boron_line_condition)*1e3,co2_smoothed(boron_line_condition),'-','Color',rgb('Black'),'LineWidth',2,'Parent',plot_handles(current_plot_index))

    % Ice core
    plot((ice_data.Age_from_1950(ice_condition)+50)./1000,smooth(ice_data.CO2(ice_condition),5),'-','Color',rgb('Black'),'LineWidth',2,'Parent',plot_handles(current_plot_index))
    
    % Label
    if animation_index<700+100
        t_distance = min([1-((animation_index-700)/100),1]);
        text(700,350,"\it Ice age cycles",'Color',t_distance.*rgb('Grey')+(1-t_distance).*rgb("White"),'FontSize',11,'Parent',plot_handles(current_plot_index));
    end
    drawnow;
    filename = "test"; % full name of image
    print('-djpeg','-r600',filename)     % save image with '-r600' resolution
    image = imread(filename+".jpg");       % read saved image
    frame = im2frame(image);              % convert image to frame
    writeVideo(wobj,frame);           % save frame into video    
end


%% Future
current_plot_index = 3;
hold(plot_handles(current_plot_index),'On');
set(plot_handles(current_plot_index),'XLim',[1000,2200]);
set(plot_handles(current_plot_index),'XTick',[1000,1500,2000,2500]);
set(plot_handles(current_plot_index),'YLim',[150,1700],'XDir','Normal','TickDir','Out','YMinorTick','On','FontSize',8);

xlabel(plot_handles(3),'Year (CE)')

set(plot_handles(3),'Position',plot_final_positions_3);
for animation_index = 0:0.5:10
    current_position_2 = (1-animation_index/10)*plot_initial_positions_2+(animation_index/10)*plot_final_positions_2;
    set(plot_handles(2),'Position',current_position_2);
    
    current_position_3 = [current_position_2(1)+current_position_2(3),plot_final_positions_3(2),(animation_index/10).*plot_initial_positions_3(3),plot_final_positions_3(4)];
    set(plot_handles(3),'Position',current_position_3);
    
    set(plot_handles(3),'XColor',1-0.1*[animation_index,animation_index,animation_index]);
    drawnow;
    filename = "test"; % full name of image
    print('-djpeg','-r600',filename)     % save image with '-r600' resolution
    image = imread(filename+".jpg");       % read saved image
    frame = im2frame(image);              % convert image to frame
    writeVideo(wobj,frame);           % save frame into video     
end


for animation_index = 1000:10:2020
    cla(plot_handles(3));
    
    law_condition = law_CO2.year<animation_index;
    mauna_condition = mauna_loa_CO2.year<animation_index;
    ssp_condition = SSP_data.year<animation_index;
        plot(law_CO2.year(law_condition),law_CO2.CO2(law_condition),'-','Color',rgb('Black'),'LineWidth',2,'Parent',plot_handles(current_plot_index));

    plot(mauna_loa_CO2.year(mauna_condition),mauna_loa_CO2.CO2(mauna_condition),'-','Color',rgb('Black'),'LineWidth',2,'Parent',plot_handles(current_plot_index));

    drawnow;
    filename = "test"; % full name of image
    print('-djpeg','-r600',filename)     % save image with '-r600' resolution
    image = imread(filename+".jpg");       % read saved image
    frame = im2frame(image);              % convert image to frame
    writeVideo(wobj,frame);           % save frame into video     
end

for t_index = 1:20
    cla(plot_handles(3));
    law_condition = law_CO2.year<animation_index;
    mauna_condition = mauna_loa_CO2.year<animation_index;
    ssp_condition = SSP_data.year<animation_index;
    
    plot(law_CO2.year(law_condition),law_CO2.CO2(law_condition),'-','Color',rgb('Black'),'LineWidth',2,'Parent',plot_handles(current_plot_index));

    plot(mauna_loa_CO2.year(mauna_condition),mauna_loa_CO2.CO2(mauna_condition),'-','Color',rgb('Black'),'LineWidth',2,'Parent',plot_handles(current_plot_index));

    t_distance = min([((t_index)/10),1]);
    plot(2021,400,'s','MarkerEdgeColor',t_distance.*rgb("Black")+(1-t_distance.*rgb("White")),'MarkerFaceColor',t_distance.*rgb("SteelBlue")+(1-t_distance.*rgb("White")),'MarkerSize',8,'Parent',plot_handles(current_plot_index));
    text(1750,450,"\it Today",'Color',t_distance.*rgb("Grey")+(1-t_distance.*rgb("White")));
    
    
    drawnow;
    filename = "test"; % full name of image
    print('-djpeg','-r600',filename)     % save image with '-r600' resolution
    image = imread(filename+".jpg");       % read saved image
    frame = im2frame(image);              % convert image to frame
    writeVideo(wobj,frame);           % save frame into video    
end

%%
for animation_index = 2020:5:2200
    cla(plot_handles(3));
    
    law_condition = law_CO2.year<animation_index;
    mauna_condition = mauna_loa_CO2.year<animation_index;
    ssp_condition = SSP_data.year<animation_index;
    
    plot(SSP_data.year(ssp_condition),SSP_data.co2_2p6(ssp_condition),'-','Color',rgb('DarkGoldenrod'),'LineWidth',2,'Parent',plot_handles(current_plot_index));

    % Add RCPs
    plot(SSP_data.year(ssp_condition),SSP_data.co2_4p5(ssp_condition),'-','Color',rgb('Orange'),'LineWidth',2,'Parent',plot_handles(current_plot_index));
    plot(SSP_data.year(ssp_condition),SSP_data.co2_6p0(ssp_condition),'-','Color',rgb('Red'),'LineWidth',2,'Parent',plot_handles(current_plot_index));
    plot(SSP_data.year(ssp_condition),SSP_data.co2_8p5(ssp_condition),'-','Color',rgb('FireBrick'),'LineWidth',2,'Parent',plot_handles(current_plot_index));
    
    plot(law_CO2.year(law_condition),law_CO2.CO2(law_condition),'-','Color',rgb('Black'),'LineWidth',2,'Parent',plot_handles(current_plot_index));
    plot(mauna_loa_CO2.year(mauna_condition),mauna_loa_CO2.CO2(mauna_condition),'-','Color',rgb('Black'),'LineWidth',2,'Parent',plot_handles(current_plot_index));
    
    if animation_index>2020
        t_distance = min([((animation_index-2020)/20),1]);
        text(1700,1400,["\it Possible","Futures"],'Color',t_distance.*rgb('Grey')+(1-t_distance).*rgb("White"),'FontSize',11,'Parent',plot_handles(current_plot_index));
    end
    plot(2021,400,'s','MarkerEdgeColor',t_distance.*rgb("Black")+(1-t_distance.*rgb("White")),'MarkerFaceColor',t_distance.*rgb("SteelBlue")+(1-t_distance.*rgb("White")),'MarkerSize',8,'Parent',plot_handles(current_plot_index));
    text(1750,450,"\it Today",'Color',rgb("Grey"));

    drawnow;
    filename = "test"; % full name of image
    print('-djpeg','-r600',filename)     % save image with '-r600' resolution
    image = imread(filename+".jpg");       % read saved image
    frame = im2frame(image);              % convert image to frame
    writeVideo(wobj,frame);           % save frame into video    
end

close(wobj);

% exportgraphics(gcf,"Cenozoic-Today_End.pdf");

% cla(plot_handles(1));
% cla(plot_handles(2));
% cla(plot_handles(3));

% exportgraphics(gcf,"Cenozoic-Today_End_Clear.pdf");
