function output = estimate_profile_shifts( prof, param )
%ESTIMATE_PROFILE_SHIFTS estimates profiles shifts vs. a reference profile
%   Detailed explanation goes here
%   Input:
%       ref( profile, 1)
%       prof( profile, N)
%       param
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Oct 23, 2018
%
% Revisions: 	0.1 (Oct 23, 2018)
%					Initial version.
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

if nargin < 3
    param = [];
end

if ~isfield(param, 'padfactor')
    param.padfactor = 4;
end
if ~isfield(param, 'MAXLAG')
    param.MAXLAG = 0.5;
end

MAXLAG = param.MAXLAG * param.padfactor;

n = size(prof,1);

padfactor = param.padfactor;
N = padfactor * n;
x = linspace(0,1,n);
fftc = @(x) ALFONSO.fft(x);
ifftc = @(x) ALFONSO.ifft(x, N);
phasor = @(k) exp(2j * pi * k .* x(:));
traffo = @(x) (x);

ref = traffo(ifftc(fftc(double(squeeze(prof(:,1))))));
prof = fftc(double(squeeze(prof(:,2:end))));

% solver options
lsqnonlin_options = optimset( 'Algorithm', 'levenberg-marquardt', ...
    'Display', 'off', ...
    'TolFun', 1e-22, ...
    'MaxFunEvals', 500, ...
    'MaxIter', 50, ...
    'TolX', 1e-22);

for iP = 1:size(prof,2)
    
    %% find kspace offset
    %[ xfit(iP), resnorm(iP), residual(iP), exitflag(iP), lsqnonlinoutput(iP) ] = ...
    [ xfit(iP) ] = ...
        lsqnonlin( @lsqnonlin_fun, ...
        0, [], [], ...
        lsqnonlin_options, ...
        ref, ...
        prof(:,iP) );
end

k = [0 xfit];
corr_func = phasor(to_col(k));

output.shifts = k;
output.corr_func = corr_func;

%% lsqnonlin_fun
    function res = lsqnonlin_fun( x, p1, p2 )
        tp1 = p1;
        tp2 = traffo(ifftc( p2 .* phasor(x) ));
        res = abs(tp1) - abs(tp2);  
    end

%% alternative method  
    function output = get_profile_shifts( spec )
        
        n = size(spec,1);
        
        padfactor = 8;
        N = padfactor * n;
        x = linspace(0,1,n);%0:(n-1);
        fftc = @(x) ALFONSO.fft(x);
        ifftc = @(x) ALFONSO.ifft(x, N);
        phasor = @(k) exp(1j * k .* x(:));
        
        % set MAXLEG based on the 
        ppm_per_sample = abs(this.scanparam.ppm_abs(2)-this.scanparam.ppm_abs(1));
        MAXLAG = ceil(this.reconparam.averaging.crosscorr_max_ppm_shift / ppm_per_sample * padfactor);
        
        A = abs(diff(ifftc(fftc(spec(:,:)))));
        c = filter2(triang(size(A,1)),A);
        [~,x_init] = max(c);
        x_init = x_init - x_init(1);
        
        k = -2*pi*x_init/N;
        corr_func = phasor(to_col(k));
            
        output.shifts = k;
        output.corr_func = corr_func;
    end
end