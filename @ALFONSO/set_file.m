function set_file( this, filename )
%SET_FILE correctly sets scanparam.filepathname and scanparam.filename
%   E.g. set_file( filename ) set the input filename. This can be a
%   ALFONSOobj file (.mat) or supported raw data file.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	September 26, 2018
%
% Revisions: 	1.0 (Sep 26, 2018)
%				        Initial version.
%             1.1 (Dec 7, 2022)
%               Updated logic to allow reading from .mat files which do not
%               contain ALFONSO objects.
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

[PATHSTR, NAME, EXT] = fileparts( filename );

if strcmpi(EXT, '.mat')
    is_ALFONSOobj_file = any(strcmp(fieldnames(matfile(filename,'Writable',false)),'ALFONSOobj'));
    if is_ALFONSOobj_file % check if .mat includes ALFONSOobj
        this.load_obj(filename);
    else
        set_scanparam();
    end
else
    set_scanparam();
end

    function set_scanparam()
        this.scanparam.filepathname = [PATHSTR filesep];
        this.scanparam.filename = [NAME EXT];
    end

end
