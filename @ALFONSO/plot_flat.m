function fh = plot_flat( this, type )
%PLOT_FLAT tries to plot all of the spectrum stored from data
%    fh = ALFONSO.plot_flat( type) plots the type spectrum of all
%    dynamics, where type is the name (string) of a function mapping the
%    complex-valued spectrum to a real-valued representation (e.g. abs, 
%    angle, real, imag). The figure handle is returned as fh. 
%    Parameter type is optional (default: real)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Nov 06, 2024
%
% Revisions: 	0.1 (Nov 06, 2024)
%                   Initial version.
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

if nargin < 2
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

spec = this.ifft( this.get_data({'x'}) );

fh = figure;
fh.Color = [1 1 1];
hold all

% create figure name
pltname_txt = [objfilename '_flat-plot_' this.var2fstr(this.dims, '%s', '-')];
fh.Name = pltname_txt;

% create plot title
plttitle_txt = ['FLAT PLOT ' this.var2fstr(this.dims, '%s', '-') ' ' {type}];
title(plttitle_txt, 'Interpreter', 'none')

plot( this.scanparam.ppm_rel( x_plot_rang ), ...
      propfh( spec(x_plot_rang,:) ), ...
      'LineWidth', 2)

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
ax.YLabel.String = [type ' signal (a.u.)'];
ax.YGrid = 'on';
ax.YTick = 0;

%legend_txt = {type};
legend_txt = num2str(to_row(1 : size(spec,2)));
legend(legend_txt);

end