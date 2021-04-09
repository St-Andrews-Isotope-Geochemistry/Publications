function [handles] = stackplot(number_of_plots,varargin)
input_parser = inputParser;
addRequired(input_parser,"numplots");
addOptional(input_parser,"side","right");
addOptional(input_parser,"figure_handle","new");

parse(input_parser,number_of_plots,varargin{:});

if input_parser.Results.figure_handle=="new"
    figure_handle = figure("Color","White");
else
    figure_handle = input_parser.Results.figure_handle;
    figure(figure_handle);
end
    



%Define positions of axes below, first left or right placement
%(alternating) then placement within window


width = 0.7;
left = (1-width)/2;
pad = 0.11;

handles = zeros(number_of_plots,1);
for plot_index = 1:number_of_plots
    if floor(plot_index/2) < plot_index/2
        if input_parser.Results.side=="right"
            side = "right";
        else
            side = "left";
        end
    else
        if input_parser.Results.side=="right"
            side = "left";
        else
            side = "right";
        end
    end
    
    %define positions of axes.  Position vector (of each axis rectable) is
    %[left bottom width height] in units normalised to window size
    if plot_index==1
        handles(plot_index) = axes('Position',[left,pad,width,(1-pad-left)/number_of_plots],...
                                   'XAxisLocation','bottom',...
                                   'YAxisLocation',side,...
                                   'Color','none',...
                                   'XColor','k','YColor','k');
    elseif plot_index==number_of_plots
        handles(plot_index) = axes('Position',[left,pad+(1-left)/number_of_plots*(plot_index-1),width,(1-pad-left)/number_of_plots],...
                                   'XAxisLocation','top',...
                                   'YAxisLocation',side,...
                                   'Color','none',...
                                   'XColor','k','YColor','k');
    else
        handles(plot_index) = axes('Position',[left,pad+(1-left)/number_of_plots*(plot_index-1),width,(1-pad-left)/number_of_plots],...
                                   'XAxisLocation','bottom',...
                                   'YAxisLocation',side,...
                                   'Color','none',...
                                   'XColor','None','YColor','k');
    end
end