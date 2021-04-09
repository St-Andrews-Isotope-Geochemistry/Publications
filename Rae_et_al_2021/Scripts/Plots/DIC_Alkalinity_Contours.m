% DIC vs Alkalinity
dic = 1700:100:2100;
alkalinity = 2100:100:2500;

[dic_grid,alkalinity_grid] = meshgrid(dic,alkalinity);

myami = MyAMI.MyAMI("Precalculated",true);

data_tables = cell(size(dic_grid));
for index = 1:numel(dic_grid)
    [~,data_tables{index}] = fncsysKMgCaV2(15,25,35,0,NaN,NaN,NaN,NaN,alkalinity_grid(index),dic_grid(index),NaN,52,10,myami);
end
data_table = vertcat(data_tables{:});

pH_grid = reshape(data_table.pH,[numel(dic),numel(alkalinity)]);
co2_grid = reshape(data_table.XCO2,[numel(dic),numel(alkalinity)]);
co3_grid = reshape(data_table.CO3,[numel(dic),numel(alkalinity)]);

%%
figure(1);
clf
hold on

[pH_contour_positions,pH_contours] = contour(dic_grid,alkalinity_grid,pH_grid,7.4:0.2:8.6,'Color',rgb("Red"));
[co2_contour_positions,co2_contours] = contour(dic_grid,alkalinity_grid,co2_grid,[100,200,400,800,1600],'Color',rgb("Grey"),'LineStyle','-.');
[co3_contour_positions,co3_contours] = contour(dic_grid,alkalinity_grid,co3_grid,100:100:500,'Color',rgb("RoyalBlue"),'LineStyle','--');

photosynthesis_arrow = annotation('doublearrow',[0.35,0.7],[0.5,0.5],'Color',rgb("Green"),'LineWidth',2,'Head1Length',20,'Head1Width',20,'Head2Length',20,'Head2Width',20);
caco3_arrow = annotation('doublearrow',[0.45,0.6],[0.25,0.75],'Color',rgb("Orange"),'LineWidth',2,'Head1Length',20,'Head1Width',20,'Head2Length',20,'Head2Width',20);

text(1970,2450,["CaCO_3","diss."],'Color',rgb("Orange"),'FontWeight','Bold','FontSize',12,'HorizontalAlignment','Center','BackgroundColor','w');
text(1830,2140,["CaCO_3","ppt."],'Color',rgb("Orange"),'FontWeight','Bold','FontSize',12,'HorizontalAlignment','Center','BackgroundColor','w');
text(1800,2320,["Photosynth."],'Color',rgb("Green"),'FontWeight','Bold','FontSize',12,'HorizontalAlignment','Center','BackgroundColor','w');
text(1980,2270,["Respiration"],'Color',rgb("Green"),'FontWeight','Bold','FontSize',12,'HorizontalAlignment','Center','BackgroundColor','w');

text(1980,2180,"CO_2",'Color',rgb("Grey"),'Rotation',50,'FontSize',16,'FontWeight','Normal');
annotation('arrow',[0.68,0.73],[0.4,0.34],'Color',rgb("Grey"),'LineWidth',1);

text(1740,2430,"[CO_3^{2-}]",'Color',rgb("RoyalBlue"),'Rotation',40,'FontSize',16,'FontWeight','Normal');
annotation('arrow',[0.28,0.24],[0.74,0.80],'Color',rgb("RoyalBlue"),'LineWidth',1);

text(1850,2460,"pH",'Color',rgb("Red"),'Rotation',45,'FontSize',16,'FontWeight','Normal');
annotation('arrow',[0.46,0.41],[0.80,0.86],'Color',rgb("Red"),'LineWidth',1);

text(2120,2410,"Plotted for 25^{\circ}C, 35psu, 0m, Modern CaMg",'Rotation',-90);

clabel(pH_contour_positions,pH_contours,'Color',rgb("Red"),'FontSize',9,'LabelSpacing',200);
clabel(co2_contour_positions,co2_contours,'Color',rgb("Grey"),'FontSize',9,'LabelSpacing',180);
clabel(co3_contour_positions,co3_contours,'Color',rgb("RoyalBlue"),'FontSize',9,'LabelSpacing',300);

xlabel("DIC \mumol/kg");
ylabel("ALK \mumol/kg");

ticks = 1700:100:2500;
set(gca,'TickDir','Out','XMinorTick','On','YMinorTick','On','XTick',ticks,'YTick',ticks);

axis square
box on

%% Saving
exportgraphics(gcf,"./Figures/DIC_Alkalinity_Contours.png","Resolution",600);
exportgraphics(gcf,"./Figures/DIC_Alkalinity_Contours.pdf");