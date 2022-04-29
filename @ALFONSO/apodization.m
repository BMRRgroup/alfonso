function apodization( this )
%APODIZATION performs signal apodization
%   Apodizes the FID signals in data using the ALFONSO.apodize
%   Parameters: 
%       reconparam.apodization.enable - [0 (default)|1] enable apodization
%       reconparam.apodization.debug - [0 (default)|1] enable debugging
%                                      output
%       reconparam.apodization.param - will be passed to ALFONSO.apodize, 
%                                      please see ALFONSO/apodize for 
%                                      details. 
%           .mode - auto or manual mode (see ALFONSO/apodize)
%           .filter - filter function (see ALFONSO/apodize)
%           .d - decay parameter (see ALFONSO/apodize)
%
% See also ALFONSO/apodize
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Sep 26, 2018
%
% Revisions: 	0.1 (Sep 26, 2018)
%                   Initial version.
%               0.2 (Apr 25, 2022)
%                   Updated param passing to apodize method. 
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

DEBUG = this.reconparam.apodization.debug;

if this.reconparam.apodization.enable && ~this.flags.apodization
    
    FID = this.get_data({'x'});
    param = this.reconparam.apodization.param;
    
    [FID, filter_func] = this.apodize( FID, param );
    
    % debug helper
    if DEBUG
        figure;
        hold all
        title('Inspection of FID and filter function')
        plot(abs(FID(:,:))./maxn(abs(FID(:))), 'k')
        plot(filter_func, 'r')
        legend('magnitude FID', 'filter function')
    end
    
    this.set_data( FID, {'x'} );

    this.flags.apodization = 1;

else
    warning('Skipped ALFONSO.apodization.')
end

end