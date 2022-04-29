function fh = plot_fid( this )
%PLOT_FID plots the FID signal stored in this.data
%   fh = ALSONFO.fid plots the FID signal and returns the figure handle.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Sep 8, 2018
%
% Revisions: 	1.0 (Sep 8, 2018)
%				Initial version.
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

fh = figure;
%set(gcf, 'Position', [0 0 1800 400])

fid = this.get_data('x');
fid = fid ./ max(abs(fid)); % normalize

spec = this.ifft( this.get_data('x') );

subplot(1,3,1);
title('FID');
hold all
plot(real(fid));
plot(imag(fid));
plot(abs(fid));
if this.reconparam.apodize.enable
    plot(this.reconparam.apodization.applied_filter, 'r', 'LineWidth', 2);
end
legend('real', 'imag', 'abs', 'apodization');
axis([0 (this.scanparam.n_sample) -1 1]);

subplot(1,3,2);
title('FID phase');
hold all
plot(unwrap(angle(fid)));
xlim([0 size(fid,1)]);

subplot(1,3,3);
hold all
title('Spectrum');
h{1} = plot(this.scanparam.ppm_abs, real(spec), 'r');
h{2} = plot(this.scanparam.ppm_abs, imag(spec), 'b');
h{3} = plot(this.scanparam.ppm_abs, abs(spec), 'k');
legend([h{1}(1) h{2}(1) h{3}(1)], 'real', 'imag', 'abs');
ylabel('signal (a.u.)')
xlabel('ppm')
%xlim([0 this.scanparam.n_sample]);
set(gca,'Xdir','rev');

end

