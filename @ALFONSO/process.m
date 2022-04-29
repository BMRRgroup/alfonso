function process( this )
%PROCESS performs a simple example spectroscopy processing pipeline
%   ALFONSO.process() performs the following steps with default settings:
%      1. ALFONSO.read_data;
%      2. ALFONSO.data_info;
%      3. ALFONSO.coilcombination;
%      4. ALFONSO.averaging;
%      5. ALFONSO.phase_correction;
%      6. ALFONSO.plot_dynSeries;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Sep 7, 2018
%
% Revisions: 	0.1 (Sep 7, 2018)
%			       Initial version.
%               0.1.1 (Mar 30, 2020)
%                  Minor adjustements to keep the example as general as
%                  possible. 
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
disp('Performing ALFONSO.process')
disp('===================================================================')
if isempty(this.data)
    this.read_data;
end
this.data_info;
this.coilcombination;
this.averaging;
this.phase_correction;
this.plot_dynSeries;
disp('===================================================================')

end

