function [fname, ALFONSOobj] = save_obj( this, filename, dest )
%SAVE_OBJ exports the object as mat file
%   [fname, ALFONSOobj] = ALFONSO.save_obj() saves the ALFONSOobj as a mat
%   file in the working directory. Returns filename (fname) and the ALFONSOobj struct. 
%
%   [...] = ALFONSO.save_obj( filename, dest ) exports the ALFONSOobj using
%   filename to the directory (dest). Both, filename and dest are optional.
%
%   See also ALFONSO/load_obj
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Oct 27, 2018
%
% Revisions: 	0.1 (Oct 27, 2018)
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

if nargin < 2
    fname = this.get_obj_filename();
else
    if isempty(filename)
        fname = this.get_obj_filename();
    else
        fname = filename;
    end
end

if nargin < 3
    dest = '.';
else
    % create directory if it does not exist yet
    if ~exist(dest, 'dir')
        mkdir(dest);
    end
end

% append .mat to filename if needed
if ~ strcmpi(fname(end-3:end), '.mat')
    fname = [fname '.mat'];
end

% prepare ALFONSOobj struct for export
fields = fieldnames(this);
for iField = 1:length(fields)
    ALFONSOobj.(fields{iField}) = this.(fields{iField});
end

% save file
save([dest filesep fname], 'ALFONSOobj', '-v7.3')

end
