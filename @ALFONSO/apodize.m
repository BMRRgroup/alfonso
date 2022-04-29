function [FID, filter] = apodize( FID, param )
%APODIZE performs 1D signal apodization along the first dimension in FID
%   Input paramters: 
%   FID - Array of free inducation decays (FIDS) with FID in first
%         dimension
%   param
%     .mode = ['auto' (default) | 'manual']
%     .filter = ['cut-off' (default) | 'gaussian' | 'lorentzian']
%     .d = decay rate parameter, depending on filter_type (default = 
%          size(FID,1) / 2 )
%
%   Returns filtered FID array and filter function
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Oct 27, 2018
%
% Revisions: 	0.1 (Oct 27, 2018)
%					Initial version.
%               0.1.1 (Mar 07, 2020)
%                   Updated modes: manual mode 
%               0.2 (Apr 21, 2022)
%                   Update behavoir using auto-mode: auto mode now only
%                   used cut-off filter.
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
    param = [];
end

% default parameter handling
if ~ isfield(param, 'mode')
    param.mode = 'auto';
end
if ~ isfield(param, 'filter_type')
    param.filter = 'cut-off';
end
if ~ isfield(param, 'd')
    param.d = size(FID,1) / 2;
end

d = param.d;

num_samples = size(FID,1);
time = linspace(0,1,num_samples);

% estimate meaningful decay rate in auto mode 
if strcmpi(param.mode, 'auto')

    % estiamte max noise signal from the tail of the FID
    noise_max = max(abs(FID(end-round(num_samples*0.05):end,1)));

    % estimate beginning of noise floor
    d = find(abs(FID(:,1)) > noise_max * 1.5, 1, 'last');

    % slightly increase cutoff (but limit to num_samples)
    d = min([d + round( d * 0.1 ),  num_samples]);
    
    param.filter = 'cut-off';
end

% calculate filter function
    switch param.filter
        case 'cut-off'
            filter = [ones(1,ceil(d)) cos(linspace(0,1,size(FID,1)-ceil(d))).^size(FID,1)];
        case 'gaussian'
            filter = exp(-d*(time).^2);
        case 'lorentzian'
            filter = exp(-d*time);
        otherwise
            error('Unkown filter type! Known filter_types: cut-off, gaussian, lorentzian.');
    end

% apply filter
if isempty( filter )
    warning('Apodization not possible: apodize was not able to obtain a filter function!')
else
    FID = FID .* filter(:);
end

end
