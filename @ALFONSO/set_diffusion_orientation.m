function set_diffusion_orientation( this )
%SET_DIFFUSION_ORIENTATION is a helper to set the diffusion orientation
%dimension.
%   The function is called at the end of the read_data process and uses the
%   information from scanparam.diffusion_gradient_mode.
%   E.g. set_diffusion_orientation( data )
%       In case of scanparam.diffusion_gradient_mode == 2:
%           It is assumed that gradient polarity is switched for all even
%           averages. Averages are accordingly sorted into an additional
%           dimension diffusion_orientation.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Nov 05, 2021
%
% Revisions:    0.1 (Nov 05, 2021)
%                   Initial version.
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

if ~ isempty(this.scanparam.diffusion_gradient_mode) ...
        &&  this.scanparam.diffusion_gradient_mode == 2
    
    fid = this.get_data({'x','average'});
    
    % make space for polarity dimension at position 3
    fid = permute(fid, [1 2 4 3]);
    
    % sort polarities
    fid = cat(3,fid(:,1:2:end,:,:),fid(:,2:2:end,:,:));
    
    this.set_data(fid, {'x','average','diffusion_orientation'});
    
end

end