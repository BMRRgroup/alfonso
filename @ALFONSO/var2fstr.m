function str = var2fstr( v, FORMAT, DELIMITER )
%VAR2FSTR converts v to a formatted string.
%   str = var2fstr( v ) returns a joined string of all scalars with spaces
%       as delimiter. 
%   str = var2fstr( v, FORMAT ) returns a joined string of all scalars in 
%       the given FORMAT with spaces as delimiter. 
%   str = var2fstr( v, FORMAT, DELIMITER ) returns a joined string of all 
%       scalars in the given FORMAT with DELIMITER as delimiter. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Mar 26, 2020
%
% Revisions: 	0.1 (Mar 26, 2020)
%				Initial version.
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
    FORMAT = '%.f';
end
if nargin < 3
    DELIMITER = ' ';
end

switch class(v)
    case 'cell'
        str = strjoin(cellfun(@(x) sprintf( FORMAT, x ), v, 'UniformOutput', false), DELIMITER);
    case 'double'
        str = strjoin(arrayfun(@(x) sprintf( FORMAT, x ), v, 'UniformOutput', false), DELIMITER);
    otherwise
        error(['Cannot handle variable of type ' class(v) '.'])
end

end
