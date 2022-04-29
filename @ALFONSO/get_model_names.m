function [model_names] = get_model_names( this )
%GET_MODEL_NAMES returns an array of the model names that were assigned
%   model_names = ALFONSO.get_model_names()
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Feb 11, 2020
%
% Revisions: 	0.1 (Feb 11, 2020)
%                   Initial version.
%               0.2 (Mar 28, 2020)
%                   Renamed to get_model_names
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

if isempty(this.quant)
    model_names = [];
else
    model_names = cellfun(@(x) x.model.name, this.quant, 'UniformOutput', false);
end

end

