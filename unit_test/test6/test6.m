% Get the current directory of this file
folderPath = fileparts(mfilename('fullpath'));

% Get the name of the folder
[~, folderName] = fileparts(folderPath);

% open the figure with the name of the folder
open(fullfile(folderPath, [folderName '.fig']));
fig = gcf;
ax = gca;
ax.YAxis.Exponent = 2;


% Export with matlab to svg
saveas(fig, fullfile(folderPath, [folderName '_matlab.svg']), 'svg');

% Call the function Plot2LaTeX to convert the figure to a svg file
fileName = fullfile(folderPath, [folderName,'_latex']);
Plot2LaTeX(fig, fileName, 'Inkscape_Export_Mode', 'export-area-page', 'ReplaceList',...
  {'xlabel1', 'time / s';...
   'xlabel2', 'time / s';...
   'xlabel3', 'time / s';...
   'xlabel4', 'time / s';...
   'xlabel5', 'time / s';...
   'ylabel1', 'wind speed / $\frac{\text{m}}{\text{s}}$';...
   'ylabel2', 'wind speed / $\frac{\text{m}}{\text{s}}$';...
   'ylabel3', 'wind speed / $\frac{\text{m}}{\text{s}}$';...
   'ylabel4', 'wind speed / $\frac{\text{m}}{\text{s}}$';...
   'ylabel5', 'wind speed / $\frac{\text{m}}{\text{s}}$'})

close(fig)