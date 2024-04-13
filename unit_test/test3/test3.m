% Get the current directory of this file
folderPath = fileparts(mfilename('fullpath'));

% Get the name of the folder
[~, folderName] = fileparts(folderPath);

% open the figure with the name of the folder
fig = open(fullfile(folderPath, [folderName '.fig']));

% Export with matlab to svg
saveas(fig, fullfile(folderPath, [folderName '_matlab.svg']), 'svg');

% Call the function Plot2LaTeX to convert the figure to a svg file
fileName = fullfile(folderPath, [folderName,'_latex']);
Plot2LaTeX(fig, fileName, 'FontSize', 'fixed');


% Close the figure
close(fig);