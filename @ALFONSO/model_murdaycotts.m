function mcw = model_murdaycotts( r, D, DT, G_str, G_dur, gamma_bar, J0_roots )
%MODEL_MURDAYCOTTS calculates the restricted diffusion modulation according
%to Murday and Cotts (see Ref. 3)
%
%   mcw = model_murdaycotts( r, D, DT, G_str, G_dur, gamma_bar ) calculates
%       the signal modulation (relative weighting factor) for restricted 
%       diffusion effects according to Murday and Cotts (3). Therefore the 
%       function M( 2*tau, delta, G) / M_0 as described in Eq. 4 from 
%       Ref. 3 is calucalted excluding T2 relaxation.  
%
%   Parameters:
%   	- r: radius [m]
%       - D: diffusion constant (temperature dep.) [m^2/sec]
%       - DT: diffusion time [s]
%       - G_str: gradient strength [T/m]
%       - G_dur: gradient pulse duration [s]
%       - gamma_bar: gamma_bar in [Hz/Tesla]
%       - J0_roots: roots (optional)
%
%   Returns:
%       - mcw: normalized signal weighting factor [-]
%
% References:
%       1. Wayne and Cotts, “Nuclear-Magnetic-Resonance Study of
%           Self-Diffusion in a Bounded Medium,” Phys. Rev., vol. 151,
%           no. 1, pp. 264–272, Nov. 1966.
%       2. Robertson, “Spin-Echo Decay of Spins Diffusing in a Bounded
%           Region,” Phys. Rev., vol. 151, no. 1, pp. 273–277, Nov. 1966.
%       3. Murday and Cotts, “Self‐Diffusion Coefficient of Liquid
%           Lithium,” J. Chem. Phys., vol. 48, no. 11, pp. 4938–4945,
%           Sep. 2003.
%
% See also ALFONSO/model_mitra
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Apr 09, 2020
%
% Revisions:    0.1 (Apr 09, 2020)
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

if nargin < 7 
    J0_roots = get_bessel_roots;
end

alpha = to_col(J0_roots)./r; % J0_roots = ( alpha * r )

gamma = gamma_bar; % 2 * pi * gamma_bar; ?!?

prefactor = - 2 * gamma^2 * G_str.^2;

sumval = 0;

for m = 2:length(J0_roots) 
    
    alpha2D = alpha(:,m).^2 .* D; 
    sumfac1 = ( alpha(:,m).^2 .* ( alpha(:,m).^2 .* r.^2 - 2) ).^(-1);
    sumfac2 = ( (2 * G_dur ) ./ (alpha2D) ) ...
        - ( ( 2 + exp( - alpha2D .* (DT - G_dur)) - 2 * exp( - alpha2D .* G_dur) - 2 * exp( - alpha2D .* DT ) + exp( - alpha2D .* ( DT + G_dur ) ) ) ./ (alpha2D).^2 );
    
    sumval = sumval + (sumfac1 .* sumfac2);
end

mcw = exp( prefactor .* sumval );

    function J0_roots = get_bessel_roots()
        % GET_BESSEL_ROOTS calculats roots for Eq.5 from Ref. 3:
        %   0 = x * diff( besselj( 1.5, x ) ) - 0.5 * besselj( 1.5, x )
        % Roots are caluclated using the chebfun toolbox:
        %   https://www.chebfun.org/examples/roots/BesselRoots.html
        
        % function evalulation limit
        maxvalexp = 4;
        
        try % loading roots from mat temp file
            filecontents = load(fullfile( fileparts(which(mfilename)), ['J0_roots_e' num2str(maxvalexp) '.mat'] ),'J0_roots');
            J0_roots = filecontents.J0_roots;
        catch
            warning(['Could not load J0_roots_e' num2str(maxvalexp) '.mat. Calculate roots now ...'] );
            maxval = 10^maxvalexp;
            
%             the following expression is equivalent to
%               x * diff( besselj( 1.5, x ) ) - 0.5 * besselj( 1.5, x )
%             and was obtained throught the matlab console typing:
%              > syms x
%              > x*diff(besselj(1.5,x))-0.5*besselj(1.5,x)
            
            J0 = chebfun(@(x) x*((2^(1/2)*(cos(x) - sin(x)/x))/(2*x^(3/2)*pi^(1/2)) + (2^(1/2)*(sin(x) + cos(x)/x - sin(x)/x^2))/(x^(1/2)*pi^(1/2))) + (2^(1/2)*(cos(x) - sin(x)/x))/(2*x^(1/2)*pi^(1/2)), [0 maxval]);
            J0_roots = roots(J0);
            
%             figure, hold all;
%             title('Bessel function J_0 (R=1)')
%             plot(J0,'k')
%             plot(J0_roots, J0(J0_roots), 'xr', 'markersize', 20)
            
            
            save(fullfile( fileparts(which(mfilename)), ['J0_roots_e' num2str(maxvalexp) '.mat'] ), ...
                'J0_roots', ...
                'J0');
        end

    end

end