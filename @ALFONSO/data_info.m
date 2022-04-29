function data_info( this )
%DATA_INFO displays information about the dataset
%   E.g. ALFONSO/data_info()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Oct 19, 2018
%
% Revisions: 	0.1 (Oct 19, 2018)
%                   Initial version.
%               0.1.1 (Mar 07, 2020)
%                   Added some more timing information.
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

disp('===================================================================')
disp('Data information:')
disp('-------------------------------------------------------------------')
disp(['Patient ID: ' this.scanparam.patient_id])
disp('-------------------------------------------------------------------')
disp(['Dimensions: ' ALFONSO.var2fstr( this.dims, '%s' )])

disp(['Dimension size: ' ALFONSO.var2fstr( size(this.data) )])

if ~is_empty_param('TE_s')
    disp(['TE (ms): ' ALFONSO.var2fstr(this.scanparam.TE_s .* 1e3, '%.f', ', ')])
end

if ~is_empty_param('TM_s')
    disp(['TM (ms): ' ALFONSO.var2fstr(this.scanparam.TM_s .* 1e3, '%.f', ', ') ])
end

if ~is_empty_param('TI_s')
    disp(['TI (ms): ' ALFONSO.var2fstr(this.scanparam.TI_s .* 1e3, '%.f', ', ') ])
end

if ~is_empty_param('TR_s')
    disp(['TR (ms): ' ALFONSO.var2fstr(this.scanparam.TR_s .* 1e3, '%.f', ', ') ])
end

if ~is_empty_param('bvalue_spm2')
    disp(['b-values (s/mm^2): ' ALFONSO.var2fstr(this.scanparam.bvalue_spm2 .* 1e-6, '%.f', ', ') ])
end

if ~is_empty_param('DT_s')
    disp(['DT (ms): ' ALFONSO.var2fstr(this.scanparam.DT_s .* 1e3, '%.f', ', ') ])
end

if ~is_empty_param('voxel_size_mm')
    disp(['Voxel size (mm^3): ' ALFONSO.var2fstr(this.scanparam.voxel_size_mm, '%.f', ' x ') ])
end

if ~is_empty_param('bandwidth_Hz')
    disp(['Bandwidth (Hz): ' ALFONSO.var2fstr( this.scanparam.bandwidth_Hz, '%.f ' ) ])
end

if ~is_empty_param('fieldstrength_T')
    disp(['Fieldstrength (T): ' ALFONSO.var2fstr( this.scanparam.fieldstrength_T, '%.f ' ) ])
end

disp('===================================================================')

    function b = is_empty_param(p)
        % returns true if scanparameter p is empty or is not existing
        b = true;
        if isfield( this.scanparam, p)
            if ~isempty( this.scanparam.(p) )
                b = false;
            end
        end
    end

end