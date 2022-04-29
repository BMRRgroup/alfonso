function reset_flags( this )
%RESET_flags resets all processing flags
%   Resets all flags under ALFONSO.flags.() to 0.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Mar 06, 2020
%
% Revisions: 	0.1 (Mar 06, 2020)
%					      Initial version.
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

fields = fieldnames(this.flags);
for iField = 1:length(fields)
    this.flags.(fields{iField}) = 0;
end

end
