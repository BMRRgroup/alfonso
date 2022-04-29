function ADC = model_mitra( r, D_free, DT )
%MODEL_MITRA calculates the apparent diffusion coefficients (ADC) as
%function of r, D_free and DT
%
%   rho = model_mitra( r, D_free, DT ) assumes the Mitra et al. model (1) 
%       for the short diffusion time limit. 
%
%   Parameters:                                        units 
%   	- r: radius                                  [m] | [mm]
%       - D_free: free diffusion               [m^2/sec] | [mm^2/sec]
%       - DT: diffusion time                       [sec] | [sec]
%                                                        |
%   Returns:                                             |
%       - ADC: apparent diffusion coefficient  [m^2/sec] | [mm^2/sec]
%
% References:
%   Mitra et al. model: 
%       1. Mitra et al., “Short-time behavior of the diffusion coefficient 
%           as a geometrical probe of porous media,” Phys. Rev. B, vol. 47, 
%           no. 14, pp. 8565–8574, Apr. 1993.
%
% See also ALFONSO/model_murdaycotts
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Apr 09, 2020
%
% Revisions:    0.1 (Apr 09, 2020)
%                   Initial version.
%               0.1.1 (May 11, 2020)
%                   Updated documentation. 
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

ADC = D_free .* (1 - ( 4 / (3 * sqrt(pi))) .* sqrt( D_free .* DT ) ./ r);

end