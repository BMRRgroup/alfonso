function [ array ] = dimfun( fh, array, dim, sq )
%DIMFUN performs a function 'along' a given dimension 
%   Converts the array to a cell array, and then performs the given
%   function on each cell. The result is returned as a mat array again. 
%   [ array ] = dimfun( fh, array, dim )
%   It is equivalent to: 
%       array = cell2mat( cellfun(@fh, num2cell(array, dim), ...
%                         'UniformOutput', false));
%
%   [ array ] = dimfun( fh, array, dim, sq=1 ) squeezes the results. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Mar 22, 2015
%
% Revisions: 
%
% Authors: 
%
%   stefan.ruschke@tum.de
% 
% --------------------------------
%
% Body Magnetic Resonance Research Group
% Department of Diagnostic and Interventional Radiology
% Technical University of Munich
% Klinikum rechts der Isar
% 22 Ismaninger St., 81675 Munich
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 4
    sq = 0;
end

array = cellfun( fh, num2cell( array, dim ), 'UniformOutput', false );

% try cell2mat(), otherwise return cell array
try
    if sq
        array = cell2mat( array(:) );
    else
        array = cell2mat( array );
    end
catch err

   % Give more information for mismatch.
   if ( strcmp( err.identifier, 'MATLAB:cell2mat:UnsupportedCellContent' ) )

       msg = 'Output is a cell array.';
       
       warning('MATLAB:BMRR:dimfun:CellContent', msg);

   % Display any other errors as usual.
   else
      rethrow( err );
   end

end 

end

