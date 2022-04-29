function invertFigureContrast(hFig)
% INVERTFIGURECONTRAST turns a positive figure contrast into a negative
% contrast and vice versa.

if ~ strcmp(get(hFig,'type'),'figure')
    error('Figure handle required!')
end

switchColorDiff = 0.2;

if ispostiveconstrast(hFig)
    % convert to negative contrast
    bgColor = [0 0 0];
    fgColor = [1 1 1];
    gridColor = [0.9 0.9 0.9];
    minorGridColor = [0.9 0.9 0.9];
    gridAlpha = 0.85;
    minorGridAlpha = 0.75;
    switchColorFactor = 1;
else
    % convert to positive contrast
    bgColor = [1 1 1];
    fgColor = [0 0 0];
    gridColor = [0.15 0.15 0.15];
    minorGridColor = [0.1 0.1 0.1];
    gridAlpha = 0.15;
    minorGridAlpha = 0.25;
    switchColorFactor = -1;
end

hChild = findall(hFig);

for iChild = 1:length(hChild)
    switch get(hChild(iChild),'Type')
        case 'figure'
            set(hChild(iChild),'Color',bgColor)
        case 'axes'
            % background
            set(hChild(iChild),'Color','none')
            
            % lines
            for iLine = 1:length(hChild(iChild).Children)
                switchColor(hChild(iChild).Children(iLine))
            end
            
            % axes
            set(hChild(iChild),'XColor',fgColor)
            set(hChild(iChild),'YColor',fgColor)
            set(hChild(iChild),'ZColor',fgColor)
            
            % grid
            set(hChild(iChild),'GridColor',gridColor)
            set(hChild(iChild),'MinorGridColor',minorGridColor)
            set(hChild(iChild),'GridAlpha',gridAlpha)
            set(hChild(iChild),'MinorGridAlpha',minorGridAlpha)
            
            % legend
            hLegend = get(hChild(iChild),'Legend');
            if ~isempty(hLegend)
                set(hLegend,'Color',bgColor)
                set(hLegend,'TextColor',fgColor)
                set(hLegend,'EdgeColor',fgColor)
            end
            
        case 'text'
            set(hChild(iChild),'Color',fgColor)
    end
    
end

    function b = ispostiveconstrast(hFig)
        if all(hFig.Color == [1 1 1])
            % positive contrast (= white background)
            b = true;
        elseif all(hFig.Color == [0.94 0.94 0.94])
            % positive contrast (= standard matlab background)
            b = true;
        else
            % treat all other backgrounds a negative constrasts
            b = false;
        end
    end

    function switchColor(hObj)
        newColor = [1 1 1]  - hObj.Color;
        %disp(['Changed' num2str(hObj.Color) ' to ' num2str(newColor)])
        set(hObj,'Color',newColor)
    end

end