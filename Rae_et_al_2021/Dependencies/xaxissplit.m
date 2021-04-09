function [handles] = xaxissplit(numplots,figpos,axpos,ylims,varargin)
input_parser = inputParser;
addRequired(input_parser,"numplots");
addRequired(input_parser,"figpos");
addRequired(input_parser,"axpos");
addRequired(input_parser,"ymin");
addRequired(input_parser,"ymax");
addOptional(input_parser,"figure_handle","new");

parse(input_parser,numplots,figpos,axpos,ylims,varargin{:});

if input_parser.Results.figure_handle=="new"
    figure_handle = figure("Color","White");
else
    figure_handle = input_parser.Results.figure_handle;
    figure(figure_handle);
end
figure_handle.Position = figpos;

ax1 = axpos(1);
ax2 = axpos(2);
ax3 = axpos(3);
ax4 = axpos(4);

axwidth  = ax3/numplots;

for i = 1:numplots
    if i == 1
        handles(i) = axes('Position',[ax1+(i-1)*axwidth ax2 axwidth ax4],...
            'XAxisLocation','bottom',...
            'YAxisLocation','left',...
            'Color','none',...
            'XColor','k','YColor','k', 'YLim',ylims);
    elseif i == numplots
            handles(i) = axes('Position',[ax1+(i-1)*axwidth ax2 axwidth ax4],...
            'XAxisLocation','bottom',...
            'YAxisLocation','right',...
            'Color','none',...
            'XColor','k','YColor','k', 'YLim',ylims);
    else
        handles(i) = axes('Position',[ax1+(i-1)*axwidth ax2 axwidth ax4],...
            'XAxisLocation','bottom',...
            'Color','none',...
            'XColor','k','YColor','none','YTickLabel','', 'YLim',ylims);
    end
end