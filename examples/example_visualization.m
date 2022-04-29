clear
close all

addALFONSO2path();

% load MRS data from ALFONSOobj file (requires to run example_processing
% and  example_quantification first)
datafile = './examples/temp/example_quantification.mat';

DIR_OUT = './examples/temp/';

mrs = ALFONSO( datafile );

% create publication plot
fh = mrs.plot_dynSeries();

fh.Children(2).Title.String = '';
fh.Children(2).Legend.Location = 'north';

fh.PaperPositionMode = 'manual';
fh.PaperPosition = [fh.PaperPosition(1:2) 12 10];

fh.PaperUnits = 'centimeters';
fh.PaperSize = [12 12]; % 12 by 12 cm canvas 

mrs.save_plots( DIR_OUT, {'jpg', 'fig'} ) % here we make use of MATLAB's saveas method

mrs.save_plots( DIR_OUT, { % cell of cells indicate to use MATLAB's print method
    {'tex'}, ... % except for tex export, which uses matlab2tikz
    {'-dpng','-r600'}, ...
    {'-dpdf', '-bestfit'} ...
    })

% if black background is prefered we can also 
invertFigureContrast(fh)
fh.Name = [fh.Name '_black_background'];

mrs.save_plots( DIR_OUT, { % cell of cells indicate to use MATLAB's print method
    {'tex'}, ... % except for tex export, which uses matlab2tikz
    {'-dpng','-r600'}, ...
    {'-dpdf', '-bestfit'} ...
    })