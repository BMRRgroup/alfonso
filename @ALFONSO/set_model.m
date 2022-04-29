function set_model( this, model_name, quant_idx )
%SET_MODEL loads the quantification model of choice from it's JSON
%definition
%   set_model( MODEL_NAME ) adds a new qunatifation using MODEL_NAME
%   set_model( MODEL_NAME, quant_idx ) sets the model of quant_idx to
%   MODEL_NAME
%   If the MODEL_NAME string ends with .json, the model will be read
%   form the JSON file MODEl_NAME is poiting to. (e.g.
%   './custom_models/mymodel.json') Otherwise the model will be load from
%   the ./models directory.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Oct 13, 2018
%
% Revisions: 	0.1 (Oct 13, 2018)
%                   Initial version.
%               0.2 (Oct 21, 2019)
%                   Added handling for multiple quantifications.
%               0.2.1 (May 08, 2020)
%                   Added capability to load model directly from json file,
%                   if the passed MODEL_NAME ends with .json
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

if nargin < 3
    
    if ~isempty(this.quant) && isstruct(this.quant)
        % save existing struct into cell
        tmp = this.quant;
        this.quant = [];
        this.quant{1} = tmp;
    end
    
    num_exist_quant = length(this.quant);
    this.cur_quant = num_exist_quant + 1;
    
    load_JSON_model(this.cur_quant, model_name);
    
else % set specific quantification
    
    this.cur_quant = quant_idx;
    
    if ~isempty(this.quant) && isstruct(this.quant)
        this.quant{1} = this.quant;
    end
    
    load_JSON_model(this.cur_quant, model_name);
end

    function load_JSON_model(quant_idx, model_name)
        % handle model_name is json file name if ends with .json
        if endsWith(model_name,'.json','IgnoreCase',true)
            jsonfile = model_name;
        else % otherwise load model from default model directory
            jsonfile = [ this.reconparam.script.modeldir model_name '.json' ];
        end
        
        % load JSON model definition
        opt.SimplifyCell = 1;
        this.quant{quant_idx}.model.param = loadjson( jsonfile, opt );
        
        % also set model name
        this.quant{quant_idx}.model.name = this.quant{quant_idx}.model.param.model_name;
        
        % test of model name of requested model is the same as in the json
        % file, otherwise inform the user
        [ ~, passed_modelname ] = fileparts(model_name);
        if ~strcmp(this.quant{quant_idx}.model.name,passed_modelname)
            warning(['Name of requested model (' passed_modelname ') deviates from the model name given in it''s definition file (' this.quant{quant_idx}.model.name ').'])
        end
        
    end
end
