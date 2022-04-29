function vec = ensure_col( vec )
%ENSURE_COL returns vec as column vector if vector, matrices stay the same
%   Helper performing vec = vec(:).' if vector
%
%   See also ensure_row, to_row, to_col
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Apr 09, 2020
%
% Revisions: 	0.1 (Apr 09, 2020)
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

if sum(size(vec) > 1) == 1
    vec = vec(:).';
end

end

