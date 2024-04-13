% Get the current directory of this file
folderPath = fileparts(mfilename('fullpath'));

% Get the name of the folder
[~, folderName] = fileparts(folderPath);

% open the figure with the name of the folder
open(fullfile(folderPath, [folderName '.fig']));
fig = gcf;

% Export with matlab to svg
saveas(fig, fullfile(folderPath, [folderName '_matlab.svg']), 'svg');

% Call the function Plot2LaTeX to convert the figure to a svg file
replacement_list = {'1...', '$u_\mathrm{S,1}$'; '2...', '$u_\mathrm{S,1}^*$'};
fileName = fullfile(folderPath, [folderName,'_latex']);
Plot2LaTeX(fig, fileName,'ReplaceList', replacement_list, ...
    'FontSize', 9, 'Inkscape_Export_Mode', 'export-area-page');


% Close the figure
close(fig);

