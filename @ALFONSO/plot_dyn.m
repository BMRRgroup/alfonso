function fh = plot_dyn( this, dyn, type )
%PLOT_DYNS plots one of the spectrum stored from data
%    fh = ALFONSO.plot_dyn( dyn, type) plots the type spectrum of the
%    dyn-th dynamic, where dyn is the integer index of the dynamic and type
%    is the name (string) of a function mapping the complex-valued spectrum
%    to a real-valued representation (e.g. abs, angle, real, imag). The
%    figure handle is returned as fh. type is optional (default: real)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Oct 23, 2018
%
% Revisions: 	0.1 (Oct 23, 2018)
%                   Initial version.
%               0.1.1 (Jul 14, 2021)
%                   Bugfixed plotting range definition.
%
% Authors:
%
%   Stefan Ruschke (stefan.ruschke@tum.de)
%
% -------------------------------------------------------------------------
%
% Body Magnetic Resonance Research Group
% Department of Diagnostic and Interventional Radiology
% Technical University of Munich
% Klinikum rechts der Isar
% 22 Ismaninger St., 81675 Munich
%
% https://www.bmrr.de
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



known_dynamics = {'x', 'TI', 'TE', 'TM', 'TR', 'bvalue'};

found_dyn = known_dynamics(ismember(known_dynamics, this.dims));

disp(['Found the following dyanmics: ' ALFONSO.var2fstr( found_dyn, '%s', ', ')]);

n_dyn = length(found_dyn);

if (n_dyn - 1) ~= length(dyn)
    error(['Argument dyn has to be a vector with the length of the number of dynamics dimensions (n=' num2str(n_dyn-1) ')'])
end

if nargin < 3
    type = 'real';
elseif isempty(type)
    type = 'real';
end

propfh = str2func(['@(x) ' type '(x)']);

% get plotting range according to ppm range
[~,idx1] = min( abs( this.scanparam.ppm_rel-this.reconparam.plotting.ppm_range(1) ) );
[~,idx2] = min( abs( this.scanparam.ppm_rel-this.reconparam.plotting.ppm_range(2) ) );
x_plot_rang_idx = sort([idx1 idx2]);
x_plot_rang = x_plot_rang_idx(1):x_plot_rang_idx(2);

[~, objfilename ] = fileparts(this.scanparam.filename);

switch n_dyn
    case 0
        error([mfilename ': cannot find any known dimensions. I am currently aware of the follwing ones: ' ALFONSO.var2fstr( known_dynamics ) ])
    case 1
        error('Not implemented!')
    case 2
        
        spec = this.ifft( this.get_data(found_dyn) );
        
        fh = figure;
        fh.Color = [1 1 1];
        hold all
        
        % create figure name
        pltname_txt = [objfilename '_dynamic' found_dyn{2}];
        if nargin > 2
            pltname_txt = [pltname_txt '_' type '_spectrum'];
        end
        fh.Name = pltname_txt;
        
        % create plot title
        plttitle_txt = ['dynamic ' found_dyn{2} ' series @ ' found_dyn{2} ' = ' num2str((this.get_scanparam_val(found_dyn{2},dyn)) * 1e3) ' ms'];
        if nargin > 2
            plttitle_txt =  [plttitle_txt ' ' type ' spectrum'];
        end
        title(plttitle_txt)
        
        if nargin > 2
            plot( this.scanparam.ppm_rel( x_plot_rang ), ...
                  propfh( spec(x_plot_rang,dyn) ), ...
                  'LineWidth', 2)
        else
            plot( this.scanparam.ppm_rel(x_plot_rang), ...
                  abs( spec(x_plot_rang,dyn) ), ...
                  'LineWidth', 2)
            plot( this.scanparam.ppm_rel(x_plot_rang), ...
                  real( spec(x_plot_rang,dyn) ), ...
                  'LineWidth', 2)
            plot( this.scanparam.ppm_rel(x_plot_rang), ...
                  imag( spec(x_plot_rang,dyn) ), ...
                  'LineWidth', 2)
        end
        
        % set axis
        ax = gca;
        ax.Box = 'on';
        
        % x axis
        ax.XLabel.String = 'ppm';
        ax.XDir = 'rev';
        ax.XLim = this.reconparam.plotting.ppm_range;
        ax.XGrid = 'on';
        ax.XMinorGrid = 'on';
        ax.XMinorTick = 'off';
        ax.XAxis.MinorTickValues = this.reconparam.plotting.ppm_range(1):0.1:this.reconparam.plotting.ppm_range(2);
        
        % y axis
        if nargin > 2
            ax.YLabel.String = [type ' signal (a.u.)'];
        else
            ax.YLabel.String = ['abs / real / imag signal (a.u.)'];
        end
        ax.YGrid = 'on';
        ax.YTick = 0;
        
        if nargin > 2
            legend_txt = {type};
        else
            legend_txt = {'magn', 'real', 'imag'};
        end
        legend(legend_txt)
        
    otherwise
        error('Not implemented!')
end
end
