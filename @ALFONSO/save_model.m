function save_model( this )
%SAVE_MODEL exports the quantification models from quant.model.param to a
%JSON definition file
%   ALFONSO.save_model()
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Oct 13, 2018
%
% Revisions: 	1.0 (Oct 13, 2018)
%				Initial version.
%               1.1 (Oct 21, 2019)
%               Added handling for multiple quantifications.
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

% save JSON model definition
this.quant{this.cur_quant}.model.paramtest = ...
    savejson( '', ...
              this.quant{this.cur_quant}.model.param, ...
              [ this.reconparam.script.modeldir this.quant{this.cur_quant}.model.param.model_name '.json'] );

end
