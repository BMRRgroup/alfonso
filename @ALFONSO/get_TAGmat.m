function M = get_TAGmat( nSpecies )
%GET_TAGMAT returns the TAG model matrix based on the number of species. 
%   M = get_TAGmat( 10 ) returns the model matrix for the 10 peak
%   triglyceride model:
%
%        M = [   9   0   0   0; ... % methyl
%              -24  -8   2   6; ... % methylene
%                6   0   0   0; ... % beta-carboxyl
%                0   4  -4   0; ... % alpha-olefinic
%                6   0   0   0; ... % alpha-carboxyl
%                0   0   2   0; ... % diallylic methylene
%                2   0   0   0; ... % glycerol
%                2   0   0   0; ... % glycerol
%                1   0   0   0; ... % glycerol
%                0   2   0   0];    % olefinic
%
% Currently supported number of frequencies: 
%   - 10 (recommended)
%   - 8 
%   - 6
%
% References: 
%   Triacylglyceride model: 
%       1. Hamilton et al. “In vivo characterization of the liver fat 1H MR 
%           spectrum.,” NMR Biomed, vol. 24, no. 7, pp. 784–790, Aug. 2011.
%
% See also ALFONSO/model_TAG
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Jul 08, 2019
%
% Revisions:    0.1 (Jul 08, 2019)
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

if nargin < 1
    nSpecies = 10;
end

switch nSpecies
    case 10
        M = [   9   0   0   0; ... % methyl
              -24  -8   2   6; ... % methylene
                6   0   0   0; ... % beta-carboxyl
                0   4  -4   0; ... % alpha-olefinic
                6   0   0   0; ... % alpha-carboxyl
                0   0   2   0; ... % diallylic methylene
                2   0   0   0; ... % glycerol
                2   0   0   0; ... % glycerol
                1   0   0   0; ... % glycerol
                0   2   0   0];    % olefinic
    case 8
        M = [   9   0   0   0; ... % methyl
              -24  -8   2   6; ... % methylene
                6   0   0   0; ... % beta-carboxyl
                0   4  -4   0; ... % alpha-olefinic
                6   0   0   0; ... % alpha-carboxyl
                0   0   2   0; ... % diallylic methylene
                4   0   0   0; ... % glycerol
                1   2   0   0];    % glycerol & olefinic
    
    case 6
        M = [   9   0   0   0; ... % peak A: methyl
              -18  -8   2   6; ... % peak B: methylene & beta-carboxyl
                6   4  -4   0; ... % peak C: alpha-olefinic & alpha-carboxyl
                0   0   2   0; ... % peak D: diallylic methylene
                4   0   0   0; ... % peak E: glycerol
                1   2   0   0];    % peak F: glycerol & olefinic
    
end

end