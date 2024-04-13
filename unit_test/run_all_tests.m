% This script will open a figure for each folder in this directory and call
% the function "Plot2LaTeX" to convert all plots to a svg file. After that,
% it will call latex to compile each tex file in each test and
% create a pdf file. Finally, it will open the pdf file in the default pdf
% viewer.

% Get the current directory of this file
currentDir = fileparts(mfilename('fullpath'));

% Get all folder names
folderList = dir(currentDir);
folderList = folderList([folderList.isdir]);
folderList = folderList(~ismember({folderList.name}, {'.', '..'}));

% Loop through all folders
% idxList = 7;
idxList = 1:length(folderList);
for i = idxList
    % Get the folder name
    folderName = folderList(i).name;
    
    % Get the full path of the folder
    folderPath = fullfile(currentDir, folderName);
    
    % Run a script that exports all svgs (script name is folder)
    cd(folderPath)
    
    % Remove old Files
    files = {[folderName,'_latex.svg'],[folderName,'_latex.pdf'],[folderName,'_latex.pdf_tex'],[folderName,'_matlab.svg'],[folderName,'.pdf']};
    folders = {'svg-inkscape'};
    
    for idx = 1:length(files)
        if exist(files{idx}, 'file') == 7
            delete(files{idx});
        end
    end
    for idx = 1:length(folders)
        if exist(folders{idx}, 'dir') == 2
            rmdir(files{idx},'s');
        end
    end
    
    % Run Script for plot
    run(folderName)

    % Call latex to compile the tex file
    fileName = fullfile(folderPath, [folderName '.tex']);
    % system(sprintf('latexmk --shell-escape -output-directory="%s" -pdf "%s"', folderPath,fileName));
end

cd(currentDir)

% Call latex to compile the main tex file
% system(sprintf('latexmk --shell-escape -output-directory="%s" -pdf "%s"', currentDir,'Tests.tex'));