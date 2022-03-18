function Plot2LaTeX( h_in, filename, varargin )
%
%PLOT2LATEX saves matlab figure as a pdf file in vector format for
%inclusion into LaTeX. Requires free and open-source vector graphics 
%editor Inkscape.
%
%   options: 'Renderer':        '' (default, e.g. 'opengl', 'painters')
%            'yCorrFactor':     0.8 (default, in px)
%            'DIR_INKSCAPE':    directory to inkscape.exe
%            'doWaitbar':       true (default)
%            'useOrigFigure'    false (default, Use the original figure
%                                   or create a copy?)
%            'doExportPDF':     true (default)
%            'LabelCorr':       1 (default, in points, Legend box size can
%                                   be modified.)
%
%   PLOT2LATEX(h,filename) saves figure with handle h to a file specified by
%   filename, without extention. Filename can contain a relative location
%   (e.g. 'images\title') to save the figure to different location. 
%
%   PLOT2LATEX(h,filename, 'option1', value,...) saves figure with specified options. 
%   The y-offset of all text can be modified using options.yCorrFactor. 
%   The default is options.yCorrFactor = 0.8. The units are px. With 
%   options.Renderer the renderer of the figure can be specified: 
%   ('opengl', 'painters').
%
%   PLOT2LATEX requires a installation of Inkscape. The program's 
%   location has to be 'hard coded' into this matlab file if it differs 
%   from 'c:\Program Files (x86)\Inkscape\Inkscape.exe'. Please specify 
%   your inscape file location by modifying DIR_INKSC variable on the 
%   first line of the actual code. 
%
%   PLOT2LATEX saves the figures to .svg format. It invokes Inkscape to
%   save the svg to a .pdf and .pdf_tex file to be incorporated into LaTeX
%   document using \begin{figure} \input{image.pdf_tex} \end{figure}. 
%   More information on the svg to pdf conversion can be found here: 
%   ftp://ftp.fu-berlin.de/tex/CTAN/info/svg-inkscape/InkscapePDFLaTeX.pdf
%   
%   PLOT2LATEX produces three files: .svg, .pdf, .pfd_tex. The .svg-file 
%   contains vector image. The .pdf-file contains figure without the text.
%   The .pdf_tex-file contains the text including locations and other
%   type setting.
%
%   The produced .svg file can be manually modified in Inkscape and
%   included into the .tex file using the using the built-in "save to pdf" 
%   functionality of Inkscape.
%
%   PLOT2LATEX saves the figure to a svg and pdf file with the
%   approximately the same width and height. Specify the Font size and size
%   within Matlab for correct conversion.
%
%   Workflow
%   - Matlab renames all strings of the figure to labels. The strings are
%   stored to be used later. To prevent a change in texbox size, labels are
%   padded to match the size of the texbox.
%   - Matlab saves the figure with labels to a svg file.
%   - Matlab opens the svg file and restores the labels  wiht the original
%   string
%   - Matlab invokes Inkscape to save the svg file to a pdf + pdf_tex file.
%   - The pdf_tex is to be included into LaTeX.
%
%   Features:
%   - Complex figures such as plotyy, logarithmic scales.
%   - It parses LaTeX code, even if it is not supported by Matlab LaTeX.
%   - Supports real transparency.
%   - SVG is a better supported, maintained and editable format than eps
%   - SVG allows simple manual modification into Inkscape.
%
%   Limitation:
%   - Text resize is still done in PLOT2LATEX. The LaTeX fonts in matlab do
%   not correspond completely with the LaTeX font size.
%   - Legend size is not always correct, use \hspace or \vspace in matlab 
%   legend to achieve a nicer fit. Requires some iterations.
%   - Rotating 3D images using toolbar does not work, using view([]) works.
%   - Text boxes with LaTeX code which is not interpretable by matlab
%   results in too long text boxes.
%   - Very large figures sometimes result in very large waiting times.
%   - Older versions than matlab 2014b are not supported.
%   - PLOT2LATEX currently does not work with titles consisting of multiple 
%   lines.
%   - PLOT2LATEX does not work with annotation textbox objects.
%   - PLOT2LATEX does not suport colored text.
%
%   Trouble shooting
%   - For Unix users: use the installation folder such as:
%   '/Applications/Inkscape.app/Contents/Resources/script ' as location. 
%   - For Unix users: For some users the bash profiles do not allow to call 
%   Inkscape in Matlab via bash. Therefore change the bash profile in Matlab 
%   to something similar as setenv('DYLD_LIBRARY_PATH','/usr/local/bin/').
%   The bash profile location can be found by using '/usr/bin/env bash'

%   To do:
%   - remove \"u and others 
%   - Annotation textbox objects
%   - Allow multiple line text
%   - Use findall(h,'-property','String')
%   - Speed up code by smarter string replacement of SVG file
%   - Resize of legend box using: [h,icons,plots,str] = legend(); (not so simple)
%   - PLOT2LATEX does not suport colored text. (Matlab limitation in saving to svg)
%   - Size difference .svg and .fig if specifying units other than px.
%       (Matlab limitation?)
%
%   Version:  1.3 / 1.4 / 1.5
%   Autor:    C. Schulte
%   Date:     10.02.2022
%   Contact:  C.Schulte@irt.rwth-aachen.de

%   Version:  1.2
%   Autor:    J.J. de Jong, K.G.P. Folkersma
%   Date:     20/04/2016
%   Contact:  j.j.dejong@utwente.nl
%
%   Change log
%   v 1.1 - 02/09/2015 (not released)
%   - Made compatible for Unix systems
%   - Added a waitbar
%   - Corrected the help file
%   v 1.2 - 20/04/2016
%   - Fixed file names with spaces in the name. (Not adviced to use in latex though)
%   - Escape special characters in XML (<,>,',",&) -> (&lt;,&gt;,&apos;,&quot;,&amp;)
%   v 1.3 - 10/02/2022
%   - figure copy
%   - check Inkscape dir
%   - options as varargin or struct
%   - waitbar optional
%   - export to pdf optional
%   - works with inkscape v1
%   v 1.4 - 18/03/2022
%   - string as input allowed
%   - closes the file, if the programm could not finish
%   - inkscape path with white spaces allowed
%   v 1.5 - 18/03/2022
%   - 2 options (LabelCorr, useOrigFigure) added
%   - fixed a bug, that only one subplot was copied
%   - Constant Line objects added

%% --------------------------- Config --------------------------- %%
%default inkscape location, e.g. 
% "C:\Program Files\Inkscape\bin\inkscape.exe
opts.DIR_INKSCAPE = 'inkscape'; %   Specify location of your inkscape installation, with "inkscape": checks if inkscape.exe is already known to shell.
if ~isempty(getenv('DIR_INKSCAPE')) % check if environment variable already exists
    opts.DIR_INKSCAPE = getenv('DIR_INKSCAPE');
end

opts.yCorrFactor = 0.8; % default, in px
opts.LabelCorr = 1; % default, in points, Legend size correction value
opts.useOrigFigure = false; % should the original figure be used or copied?
opts.Renderer = ''; % do not set default renderer
opts.doWaitbar = true;
opts.doExportPDF = true;
% ------------------------- Config end --------------------------- %
opts = checkOptions(opts,varargin); % update default options based on information in varargin


%% Create a figure copy
if ~strcmp(h_in.Type,'figure')
    error('h object is not a figure')
end
if opts.useOrigFigure
    h = h_in;
else
    h = copy_Figure(h_in);
end


%% Check Filename
if isstring(filename)
    filename = char(filename);
end


%% Check Renderer
if ~isempty(opts.Renderer) %WARNING: large size figures can become very large
    h.Renderer = opts.Renderer; % set render
end


%% init waitbar
if opts.doWaitbar
    nStep = 4; Step = 0; 
    hWaitBar = waitbar(Step/nStep,'Initializing');
end


%% test if inkscape installation is correct
inkscape_valid = check_Inkscape_Dir(opts.DIR_INKSCAPE);
if ~inkscape_valid
    [file,pathname] = uigetfile('inkscape.exe',[opts.DIR_INKSCAPE, ' cannot be found, please select "inkscape.exe".']');
    opts.DIR_INKSCAPE = fullfile(pathname,file);
    if check_Inkscape_Dir(opts.DIR_INKSCAPE)
        setenv('DIR_INKSCAPE',opts.DIR_INKSCAPE);
    else
        error([' - Plot2LaTeX: Inkscape Installation not found.  Matlab command "system(''"',opts.DIR_INKSCAPE,'" --version'')" was not successful.'])
    end
else 
    setenv('DIR_INKSCAPE',opts.DIR_INKSCAPE);
end


%% Check matlab version
if verLessThan('matlab', '8.4.0.')
	error('Older versions than Matlab 2014b are not supported')
end


%% Find all objects with text
TexObj = findall(h,'Type','Text'); % normal text, titels, x y z labels
LegObj = findall(h,'Type','Legend'); % legend objects
AxeObj = findall(h,'Type','Axes');  % axes containing x y z ticklabel
ColObj = findall(h,'Type','Colorbar'); % containg color bar tick

PosAnchSVG      = {'start','middle','end'};
PosAligmentSVG  = {'start','center','end'};
PosAligmentMAT  = {'left','center','right'};

ChangeInterpreter(h,'tex')
h.PaperPositionMode = 'auto'; % Keep current size


%% Replace text with a label
if opts.doWaitbar
    Step = Step + 1;
    waitbar(Step/nStep,hWaitBar,'Replacing text with labels');
end

iLabel = 0; % generate label iterator

n_TexObj = length(TexObj);
for i = 1:n_TexObj % do for text, titles and axes labels
    iLabel = iLabel + 1;
    
    % find text string
    Labels(iLabel).TrueText = TexObj(i).String; %#ok<*AGROW>
    
    % find text aligment
    Labels(iLabel).Alignment = PosAligmentSVG(...
                                    find(ismember(...
                                        PosAligmentMAT,...
                                        TexObj(i).HorizontalAlignment)));
	% find achor aligment svg uses this
    Labels(iLabel).Anchor = PosAnchSVG(...
                                find(ismember(...
                                    PosAligmentMAT,...
                                    TexObj(i).HorizontalAlignment)));
    % generate label
    Labels = LabelText(iLabel,Labels);
    
    %find text posiont
    Labels(iLabel).Position = TexObj(i).Position;
    
    % replace string with label
    TexObj(i).String = Labels(iLabel).LabelText;
end

% do similar for legend objects
n_LegObj = length(LegObj);
for i = 1:n_LegObj 
    n_Str = length(LegObj(i).String);
    
    iLabel = iLabel + 1;
    
    Labels(iLabel).TrueText = LegObj(i).String{1};
    Labels(iLabel).Alignment = PosAligmentSVG(1); % legends are always left aligned
    Labels(iLabel).Anchor = PosAnchSVG(1);
    
    % generate legend label padded with dots to fill text box
    Labels = LabelText(iLabel,Labels);
    LegObj(i).String{1} = Labels(iLabel).LabelText;
    
    for j = 2:n_Str % do short as possible label for other entries
       iLabel = iLabel + 1;
       Labels(iLabel).TrueText = LegObj(i).String{j};
       Labels(iLabel).Alignment = PosAligmentSVG(1);
       Labels(iLabel).Anchor = PosAnchSVG(1);
       Labels = LabelText(iLabel,Labels);
       LegObj(i).String{j} = Labels(iLabel).LabelText;
    end
end

% do similar for axes objects, XTick, YTick, ZTick
n_AxeObj = length(AxeObj);
for i = 1:n_AxeObj 
    n_Str = length(AxeObj(i).XTickLabel);
    for j = 1:n_Str
        iLabel = iLabel + 1;
        Labels(iLabel).TrueText = AxeObj(i).XTickLabel{j};
        Labels(iLabel).Alignment = PosAligmentSVG(2);
        Labels(iLabel).Anchor = PosAnchSVG(2);
        Labels = LabelText(iLabel,Labels);
        AxeObj(i).XTickLabel{j} = Labels(iLabel).LabelText;
    end
    
    isRightAx = strcmp(AxeObj(i).YAxisLocation,'right'); % exeption for yy-plot
    n_Str = length(AxeObj(i).YTickLabel);
    for j = 1:n_Str
        iLabel = iLabel + 1;
        Labels(iLabel).TrueText = AxeObj(i).YTickLabel{j};
        if isRightAx % exeption for yy-plot, aligment is left for the right axis
            Labels(iLabel).Alignment = PosAligmentSVG(1);
            Labels(iLabel).Anchor = PosAnchSVG(1);
        else % normal y labels are right aligned
            Labels(iLabel).Alignment = PosAligmentSVG(3);
            Labels(iLabel).Anchor = PosAnchSVG(3);
        end
        Labels = LabelText(iLabel,Labels);
        AxeObj(i).YTickLabel{j} = Labels(iLabel).LabelText;
    end
    
    n_Str = length(AxeObj(i).ZTickLabel);
    for j = 1:n_Str
        iLabel = iLabel + 1;
        Labels(iLabel).TrueText = AxeObj(i).ZTickLabel{j};
        Labels(iLabel).Alignment = PosAligmentSVG(3);
        Labels(iLabel).Anchor = PosAnchSVG(3);
        Labels = LabelText(iLabel,Labels);
        AxeObj(i).ZTickLabel{j} = Labels(iLabel).LabelText;
    end
end

% do similar for color bar objects
n_ColObj = length(ColObj); 
for i = 1:n_ColObj
    isAxIn = strcmp(ColObj(i).AxisLocation,'in'); % find internal external text location
    isAxEast = strcmp(ColObj(i).Location,'east'); % find location
    isRightAx = isAxIn ~= isAxEast;
    
    n_Str = length(ColObj(i).TickLabels);
    for j = 1:n_Str
        iLabel = iLabel + 1;
        Labels(iLabel).TrueText = ColObj(i).TickLabels{j};
        if isRightAx % if text is right aligned
            Labels(iLabel).Alignment = PosAligmentSVG(1);
            Labels(iLabel).Anchor = PosAnchSVG(1);
        else % if text is left aligned
            Labels(iLabel).Alignment = PosAligmentSVG(3);
            Labels(iLabel).Anchor = PosAnchSVG(3);
        end
        Labels = LabelText(iLabel,Labels);
        ColObj(i).TickLabels{j} = Labels(iLabel).LabelText;
    end
end



% Constant line objects
ConstLineObj = findall(h,'Type','ConstantLine');
n_ConstLineObj = length(ConstLineObj);
for i = 1:n_ConstLineObj % do for text, titles and axes labels
    if isempty(ConstLineObj(i).Label)
    iLabel = iLabel + 1;
    
    % find text string
    Labels(iLabel).TrueText = ConstLineObj(i).Label; %#ok<*AGROW>
    
    % find text aligment
    Labels(iLabel).Alignment = PosAligmentSVG(2);
	% find achor aligment svg uses this
    if isequal(ConstLineObj(i).InterceptAxis,'y')
        p_temp = {'top','middle','bottom'};
    else
        p_temp = {'bottom','middle','top'};
    end
    Labels(iLabel).Anchor = PosAnchSVG(find(ismember(p_temp,ConstLineObj(i).LabelVerticalAlignment)));
    % generate label
    Labels = LabelText(iLabel,Labels);
    
    %find text posiont
    Labels(iLabel).Position = [];
    
    % replace string with label
    ConstLineObj(i).Label = Labels(iLabel).LabelText;
    end
end
nLabel = iLabel;
% set text interpreter to plain text
ChangeInterpreter(h,'none');  


%% Save to fig and SVG
if opts.doWaitbar
    Step = Step + 1;
    waitbar(Step/nStep,hWaitBar,'Saving figure to .svg file');
end

if ~(~isempty(strfind(filename,'/')) || ~isempty(strfind(filename,'\')))
    filename = [pwd,'\',filename];
end

saveas(h,filename,'svg'); % export to svg


%% Modify SVG file to replace labels with original text
if opts.doWaitbar
    Step = Step + 1;
    waitbar(Step/nStep,hWaitBar,'Restoring text in .svg file');
end

for iLabel = 1:nLabel
    Labels(iLabel).XMLText = EscapeXML(Labels(iLabel).TrueText);
end

try
    fin = fopen([filename,'.svg']); % open svg file
    fout = fopen([filename,'_temp.svg'],'w'); % make a temp file for modification

    StrLine_new = fgetl(fin);%skip first line
    iLine = 1; % Line number
    nFoundLabel = 0; % Counter of number of found labels
    while ~feof(fin)
        StrPref = StrLine_new; % process new line
        iLine = iLine + 1;
        StrLine_old = fgetl(fin);

        FoundLabelText = regexp(StrLine_old,'>.+</text','match'); %try to find label
        StrLine_new = StrLine_old;
        if ~isempty(FoundLabelText)
            nFoundLabel = nFoundLabel + 1;
            iLabel = find(ismember(...
                                {Labels.LabelText},...
                                FoundLabelText{1}(2:end-6))); % find label number

            % Append text alignment in prevous line
            StrPrefTemp = [StrPref(1:end-1),...
                            'text-align:', Labels(iLabel).Alignment{1},...
                            ';text-anchor:', Labels(iLabel).Anchor{1}, '"'];

            % correct x - position offset
            StrPrefTemp = regexprep(StrPrefTemp,'x="\S*"','x="0"');

            % correct y - position offset, does not work correctly
            [startIndex,endIndex] = regexp(StrPrefTemp,'y="\S*"');
            yOffset = str2double(StrPrefTemp((startIndex+3):(endIndex-1)));
            StrPrefTemp = regexprep(...
                                StrPrefTemp,...
                                'y="\S*"',...
                                ['y="', num2str(yOffset*opts.yCorrFactor), '"']); 

            % Replace label with original string
            StrCurrTemp = strrep(StrLine_old, ...
                                    FoundLabelText,...
                                    ['>',Labels(iLabel).XMLText,'</text']);

            StrLine_new = StrCurrTemp{:};
            StrPref = StrPrefTemp;
        end
        fprintf(fout,'%s\n',StrPref);
    end
    fprintf(fout,'%s\n',StrLine_new);

    fclose(fin);
    fclose(fout);
    movefile([filename,'_temp.svg'],[filename,'.svg'])
catch
    fclose(fin);
    fclose(fout);
end

%% Invoke Inkscape to generate PDF + LaTeX
if opts.doExportPDF
    if opts.doWaitbar
        Step = Step + 1;
        waitbar(Step/nStep,hWaitBar,'Saving .svg to .pdf file');
    end
    if check_Inkscape_Version(opts.DIR_INKSCAPE)
        cmdtext = sprintf('"%s" "%s.svg" --export-filename="%s.pdf" --export-latex --export-area-drawing',...
            opts.DIR_INKSCAPE, filename, filename);
    else % inkscape v0
        cmdtext = sprintf('"%s" "%s.svg" --export-pdf "%s.pdf" --export-latex -export-area-drawing',...
            opts.DIR_INKSCAPE, filename, filename);
    end
    [~,cmdout] = system(cmdtext);

    % test if a .pdf and .pdf_tex file exist
    if exist([filename,'.pdf'],'file')~= 2 || exist([filename,'.pdf_tex'],'file')~= 2
        warning([' - Plot2LaTeX: No .pdf or .pdf_tex file produced, please check your Inkscape installation and specify installation directory correctly: ', cmdout])
    end
end


%% Clean up
if opts.doWaitbar
    close(hWaitBar);
end
close(h)
end

%% ------------------------------------------------------------------------
function Labels = LabelText(index, Labels)
% LABELTEXT generates labels based on label number
text = Labels(index).TrueText;
if isfield(Labels,'LabelText')
    LabelList = {Labels(1:index-1).LabelText};
    
    
    while ismember(text,LabelList)
        text = [text,'.'];
    end
end
Labels(index).LabelText = text;
end

%% ------------------------------------------------------------------------
function Str = LegText(iLedEntry)
% LEGTEXT generates legend labels based on legend entry number
    Str = num2str(iLedEntry);
end

%% ------------------------------------------------------------------------
function ChangeInterpreter(h,Interpreter)
% CHANGEINTERPRETER puts interpeters in figure h to Interpreter

    TexObj = findall(h,'Type','Text');
    LegObj = findall(h,'Type','Legend');
    AxeObj = findall(h,'Type','Axes');  
    ColObj = findall(h,'Type','Colorbar');
    
    Obj = [TexObj;LegObj]; % Tex and Legend opbjects can be treated similar
    
    n_Obj = length(Obj);
    for i = 1:n_Obj
        Obj(i).Interpreter = Interpreter;
    end
    
    Obj = [AxeObj;ColObj]; % Axes and colorbar opbjects can be treated similar
    
    n_Obj = length(Obj);
    for i = 1:n_Obj
        Obj(i).TickLabelInterpreter = Interpreter;
    end
end

%% ------------------------------------------------------------------------
function strXML = EscapeXML(str)
% ESCAPEXML repaces special characters(<,>,',",&) -> (&lt;,&gt;,&apos;,&quot;,&amp;)
    escChar = {'&','<','>','''','"'};
    repChar = {'&amp;','&lt;','&gt;','&apos;','&quot;'};
    strXML = regexprep(str,escChar,repChar);
end

%% ------------------------------------------------------------------------
function [fig] = copy_Figure(fig_orig)
% this program copies a figure to another figure
% 

Name = 'Plot2LaTeX';
figurefile = fullfile(pwd,[Name,'.fig']);
savefig(fig_orig,figurefile)

fig = openfig(figurefile);
fig.Name = Name;
set(fig,'Units',get(fig_orig,'Units'));
set(fig,'position',get(fig_orig,'position'));
drawnow()
warning('on')
delete(figurefile)
end

%% ------------------------------------------------------------------------
function options = checkOptions(options, inputArgs, doWarning)
% options = checkOptions(options, inputArgs, doWarning)
%
% options: struct with valid fields
% inputargs: a cell of inputs -> varargin of a higher function or a cell of a struct
% doWarning: true (default), false
%

if nargin == 2
    doWarning = true;
end

if doWarning
    stack = dbstack(1);
    fcnName = stack(1).name;
end

% List of valid options to accept, simple way to deal with illegal user input
validEntries = fieldnames(options);

% Loop over each input name-value pair, check whether name is valid and overwrite fieldname in options structure.
for ii = 1:2:length(inputArgs)
    entry = inputArgs{ii};
    
    [isValid,validEntry] = isValidEntry(validEntries,entry,fcnName,doWarning);
    if ischar(entry) && isValid
        options.(validEntry) = inputArgs{ii+1};
        
    elseif isstruct(entry)
        fieldNames = fieldnames(entry);
        for idx = 1:length(fieldNames)
            subentry = fieldNames{idx};
            isval = isValidEntry(validEntries,subentry,fcnName,doWarning);
            if isval 
                options.(subentry) = entry.(subentry);
            end
        end
    else
        continue;
    end
end
end

function [bool,idx] = isValidEntry(validEntries, input, fcnName,doWarning)
% allow input of an options structure that overwrites existing fieldnames with its own, for increased flexibility
bool = false;
idx = -1;
valIdx = strcmpi(input,validEntries);
if nnz(valIdx) == 0
    valIdx = contains(validEntries,input,'IgnoreCase',true);
end
if nnz(valIdx) > 1
    strings = [validEntries(1); strcat(',', validEntries(2:end)) ] ; % removes ' ' at the end when concatenating
    longString = [strings{:}];
    longString = strrep(longString,',',', ');
    if doWarning
        error(['-',fcnName,'.m: Option "', input,'" not correct. Allowed options are [', longString, '].'])
    end
elseif nnz(valIdx) > 0 % All else options
    idx = validEntries{valIdx};
    bool = true;
else
    strings = [validEntries(1); strcat(',', validEntries(2:end)) ] ; % removes ' ' at the end when concatenating
    longString = [strings{:}];
    longString = strrep(longString,',',', ');
    if doWarning
        warning(['-',fcnName,'.m: Option "', input,'" not found. Allowed options are [', longString, '].'])
    end
end
end

%% ------------------------------------------------------------------------
function isValid = check_Inkscape_Dir(inkscape_path)
% isValid = CHECK_INKSCAPE_DIR(path) checks if the path to inkscape is
% correct
[status, result] = system(['"',inkscape_path,'" --help']);
isValid = ~isempty(strfind(result,'-export-area-drawing')) && ...
          ~isempty(strfind(result,'--export-latex')) && ...
          ~isempty(strfind(result,'--export-pdf')) && status == 0;
if status ~= 0 && status ~= 1
    warning([' - check_Inkscape_Dir.m: system(''',inkscape_path,' --help'') was not successful. System response was ',num2str(status),'.'])
end
end

%% ------------------------------------------------------------------------
function [isAboveV1, version]= check_Inkscape_Version(inkscape_path)
% isValid = CHECK_INKSCAPE_VERSION(path) checks if inkscape is
% in version 1 or above
[status, result] = system(['"',inkscape_path,'" --version']);
[reg_idx,reg_idx_end] = regexp(result,'Inkscape [0-9.]+','ONCE');
isValid = ~isempty(reg_idx) && status == 0;

if isValid
    version = result(reg_idx+length('Inkscape '):reg_idx_end);
    [reg_idx,reg_idx_end] = regexp(version,'[0-9]+','ONCE');
    isAboveV1 = num2str(version(reg_idx:reg_idx_end)) >= 1;
else
    version = '';
    isAboveV1 = false;
    warning([' - check_Inkscape_Version.m: system(''',inkscape_path,' --version'') was not successful. System response was ',num2str(status),'.'])
end
end
