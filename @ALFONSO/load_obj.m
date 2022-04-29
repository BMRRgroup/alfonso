function [ ALFONSOobj ] = load_obj( this, filename )
%LOAD_OBJ loads ALFONSO object (ALFONSOobj) from a mat file
%   ALFONSO.load_obj( filename ) loads the ALFONSO object (ALFONSOobj) from
%   filename. Therefore, the struct in ALFONSOobj is loaded into the object.
%   [ ALFONSOobj ] = ALFONSO.load_obj( filename ) also returns the loaded
%   ALFONSOobj
%
%   See also ALFONSO.save_obj, ALFONSO.exists_obj
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Nov 2, 2018
%
% Revisions: 	0.1 (Nov 2, 2018)
%					Initial version.
%               0.2 (Oct 09, 2020)
%                   Improved ALFONSOobj loading mechanism. New parameters will
%                   not be automatically deleted anymore but keep their
%                   default values.
%               0.2.1 (Apr 29, 2022)
%                   Further imporved robustness of loading mechanism:
%                   correct handling of empty properties. 
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
    error('Please provide .mat file to load ALFONSO obj from!')
end

load(filename, 'ALFONSOobj');

% load ALFONSOobj struct into object
this = recurive_merge(this, ALFONSOobj, fieldnames(ALFONSOobj));

    function thisobj = recurive_merge(thisobj, obj, fields)
        % recursively load ALFONSOobj into class
        % this ensures that new parameters as defined by the class
        % properties will not be overwritten and additional parameters
        % in the ALFONSOobj propagate into the object.
        for iField = 1:length(fields)
            % if the field is a struct in the class, enter it
            if (isfield( thisobj, fields{iField} ) || isprop( thisobj, fields{iField} )) ...
                    &&  isstruct( thisobj.(fields{iField}) )
                if isstruct( obj.(fields{iField}) )
                    thisobj.(fields{iField}) = recurive_merge( ...
                        thisobj.(fields{iField}), ...
                        obj.(fields{iField}), ...
                        fieldnames(obj.(fields{iField})));
                else % empty struct
                    thisobj.(fields{iField}) = recurive_merge( ...
                        thisobj.(fields{iField}), ...
                        obj.(fields{iField}), ...
                        []);
                end
            else % field is not a struct in the class -> grab data from ALFONSOobj
                try
                    thisobj.(fields{iField}) = obj.(fields{iField});
                catch
                    warning([fields{iField} ' could not be loaded from ' filename])
                end
            end
        end
        
    end

end