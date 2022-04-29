function save_plots(filepath, FORMAT)
%SAVE_PLOTS saves all open plots to filepath in the requested format(s)
%
%   ALFONSO.save_plots('./figures', 'fig') save all open figures as .fig
%   under './figures'.
%
%   ALFONSO.save_plots([], {'png', 'fig', 'tex'}) save all open figures
%   in the current working directory as .png, .fig and .tex file using
%   Matlab's saveas method and matlab2tikz, respectively.
%
%   ALFONSO.save_plots([], {{'-dpng', '-r0'}, 'tex'}) save all open figures
%   in the current working directory as .png and .tex file using
%   Matlab's print method and matlab2tikz, respectively.
%
%   FORMAT:
%       - if string: saveas is used to produce the figure
%       - if cell: print is used and allows to pass additional switches
%
%   Requirements:
%       Tex file export requires matlab2tikz
%       (https://github.com/matlab2tikz/matlab2tikz).
%
%   Some part of the code was shamelessly taken from Maximilian
%   Diefenbach.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Nov 3, 2018
%
% Revisions:    0.1 (Nov 3, 2018)
%					Initial prototype version.
%               0.1.1 (Mar 09, 2020)
%                   Added support for using Matlab's print method to pass
%                   additional arguments.
%                   Make use of InvertHardcopy = 'off' as default to enable
%                   color backgrounds.
%               0.1.2 (May 13, 2020)
%                   Added filename sanitization.
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

if nargin < 1
    filepath = pwd;
else
    if isempty(filepath)
        filepath = pwd;
    end
end

if nargin < 2
    FORMAT = {'png'};
else
    if ~iscell(FORMAT)
        FORMAT = {FORMAT};
    end
end

if ~exist(filepath, 'dir')
    mkdir(filepath);
end

figArray = get(0, 'Children');
nFigures = numel(figArray);

if nFigures == 0
    return
end

figNumberCell = {figArray.Number};
minFigNumber = min(cell2mat(figNumberCell));
maxFigNumber = max(cell2mat(figNumberCell));

figArray = flip(figArray, 1);

for iFig = minFigNumber:maxFigNumber
    
    hfigure = get_hfigureFromArray(figArray, iFig);
    
    if isempty(hfigure)
        continue;
    end
    
    hfigure.InvertHardcopy = 'off';
    
    figure(hfigure)
    if ~ isempty(get(hfigure, 'Name'))
        filename = [datestr(now, 'yyyymmdd_HHMMSS') '_' get(hfigure, 'Name')];
    else
        prompt = sprintf('Filename for figure %d: ', iFig);
        filename = char(inputdlg(prompt, 's'));
        if isempty(filename)
            filename = [datestr(now, 'yyyymmdd_HHMMSS')];
        end
    end
    
    filename = sanitize( filename );
    
    for iformat = 1:length(FORMAT)
        
        CUR_FORMAT = FORMAT{iformat};
        
        % extraxt file extension from FORMAT argument
        % if FORMAT is a string, saveas is used to produce the figure
        % if FOMRAT is a cell array, print is used and allows to pass
        % additional switches
        if iscell(CUR_FORMAT)
            FORMAT_EXT = CUR_FORMAT{1};
        else
            FORMAT_EXT = CUR_FORMAT;
        end
        
        % strip switch - if needed
        if FORMAT_EXT(1) == '-'
            FORMAT_EXT(1) = [];
        end
        
        filename_ext = [filename '.' FORMAT_EXT];
        
        if strcmpi(filename_ext(end-3:end), '.tex')
            matlab2tikz(fullfile(filepath, filename_ext), ...
                'standalone', true, ...
                'showInfo', false, ...
                'strict', true)
            fprintf('matlab2tikz: saved %s\n', filename_ext)
        else
            if iscell(CUR_FORMAT)
                print(hfigure, ...
                    fullfile(filepath, filename), ...
                    CUR_FORMAT{:})
                fprintf('print: saved %s\n', filename)
            else
                saveas(hfigure, ...
                    fullfile(filepath, filename_ext));
                fprintf('saveas: saved %s\n', filename_ext)
            end
        end
    end
end

    function hfig = get_hfigureFromArray(figArray, figNumber)
        nFigs = numel(figArray);
        hfig = [];
        for iFigIdx = 1:nFigs
            if figArray(iFigIdx).Number == figNumber
                hfig = figArray(iFigIdx);
            end
        end
        
    end

    function s = sanitize( s )
        s = regexprep(s,'[^a-zA-Z_0-9]','_');
    end

end