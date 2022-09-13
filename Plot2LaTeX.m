function Plot2LaTeX( h_in, filename, varargin )
%
%PLOT2LATEX saves matlab figure as a pdf file in vector format for
%inclusion into LaTeX. Requires free and open-source vector graphics 
%editor Inkscape.
%
%   options: 'Renderer':        'painters' (default), 'opengl', ''(no change)
%            'yCorrFactor':     0.8 (default, in px)
%            'DIR_INKSCAPE':    directory to inkscape.exe
%            'doWaitbar':       true (default)
%            'useOrigFigure'    false (default, Use the original figure
%                                   or create a copy?)
%            'doExportPDF':     true (default)
%            'Interpreter':     'tex' (default, 'latex','none'), changes the
%                                   matlab text interpreter
%            'FontSize':        11 (default, use '' if the fontSize should
%                                   not be changed)
%
%   PLOT2LATEX(h,filename) saves figure with handle h to a file specified by
%   filename, without extention. Filename can contain a a full path or a name 
%   (e.g. 'C:\images\title', 'title') to save the figure to a different location. 
%
%   PLOT2LATEX(h,filename, 'option1', value,...) saves figure with specified  
%   options. The y-offset of all text can be modified using yCorrFactor. 
%   The default is 'yCorrFactor' = 0.8. The units are px. With 
%   options.Renderer the renderer of the figure can be specified: 
%   ('opengl', 'painters').
%
%   PLOT2LATEX requires a installation of Inkscape. The program's 
%   location can be 'hard coded' into this matlab file if 'inkscape' is not a
%   valid command for the command window. Please specify your inscape 
%   file location by modifying opts.DIR_INKSCAPE variable on the 
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
%   PLOT2LATEX saves the figure to a svg and pdf file with
%   approximately the same width and height. Specify the Font size and size
%   within Matlab for correct conversion.
%
%   Workflow
%   - Matlab renames duplicate strings of the figure. The strings are
%   stored to be used later. To prevent a change in texbox size, duplicate 
%   labels get "." at the end of the label.
%   - Matlab saves the figure with modified labels to a svg file.
%   - Matlab opens the svg file and restores the labels with the original
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
%   - PLOT2LATEX does not support colored text.
%
%   Trouble shooting
%   - For Unix users: use the installation folder such as:
%   '/Applications/Inkscape.app/Contents/Resources/script ' as location. 
%   - For Unix users: For some users the bash profiles do not allow to call 
%   Inkscape in Matlab via bash. Therefore change the bash profile in Matlab 
%   to something similar as setenv('DYLD_LIBRARY_PATH','/usr/local/bin/').
%   The bash profile location can be found by using '/usr/bin/env bash'

%   To do:
%   - Annotation textbox objects
%   - Allow multiple line text
%   - Use findall(h,'-property','String')
%   - Speed up code by smarter string replacement of SVG file
%   - Size difference .svg and .fig if specifying units other than px.
%       (Matlab limitation?)
%
%   Version:  1.3 / 1.4 / 1.5 / 1.6
%   Autor:    C. Schulte
%   Date:     21.03.2022
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
%   - Fixed file names with spaces in the name. 
%     (Not adviced to use in latex though)
%   - Escape special characters in XML (<,>,',",&) 
%     -> (&lt;,&gt;,&apos;,&quot;,&amp;)
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
%   v 1.5 - 21/03/2022
%   - 2 options (Interpreter, useOrigFigure) added
%   - fixed a bug, that only one subplot was copied
%   - Constant Line objects added
%   v 1.6 - 21/03/2022
%   - exponential exponents on axis added
%   - not supported text-elements don't stop svg-export
%   v 1.7 - 13/09/2022
%   - fixed a bug in colorbar
%   - legend size is fixed based on initial position
%   - added an option for fontSize

%% ---------------- Config ------------------------------------------------
% default inkscape location, e.g. 
% "C:\Program Files\Inkscape\bin\inkscape.exe
% Specify location of your inkscape installation, 
% if opts.DIR_INKSCAPE = "inkscape": checks if inkscape.exe is already known to shell.
opts.DIR_INKSCAPE = 'inkscape'; 
if ~isempty(getenv('DIR_INKSCAPE')) % check if environment variable already exists
    opts.DIR_INKSCAPE = getenv('DIR_INKSCAPE');
end

opts.yCorrFactor = 0.8; % default, in px
opts.useOrigFigure = false; % should the original figure be used or copied?
opts.Renderer = 'painters'; % use the "painters" renderer, so that the text 
%                             elements can be found inside the svg
opts.FontSize = 11;   % Font Size of all Text, use '' if the size should not be changed
opts.doWaitbar = true;
opts.doExportPDF = true;
opts.Interpreter = ''; % matlab text interpreters, others: 'tex','none', '' -> dont change
% ------------------------- Config end --------------------------- %
opts = checkOptions(opts,varargin); % update default options based on information in varargin


%% ---------------- Create a figure copy ----------------------------------
if ~strcmp(h_in.Type,'figure')
    error(' - Plot2LaTeX: h_in object is not a figure.')
end
if opts.useOrigFigure
    h = h_in;
else
    h = copy_Figure(h_in);
end


%% ---------------- Check Font Size ---------------------------------------
if ~isempty(opts.FontSize)
    set(findall(h,'-property','FontSize'),'FontSize',opts.FontSize)
    drawnow
end


%% ---------------- Check Filename ----------------------------------------
if isstring(filename)
    filename = char(filename);
end


%% ---------------- Check Renderer ----------------------------------------
if ~isempty(opts.Renderer) %WARNING: large size figures can become very large
    h.Renderer = opts.Renderer; % set render
end


%% ---------------- init waitbar ------------------------------------------
if opts.doWaitbar
    nStep = 4; Step = 0; 
    hWaitBar = waitbar(Step/nStep,'Initializing');
end


%% ---------------- test if inkscape installation is correct --------------
inkscape_valid = check_Inkscape_Dir(opts.DIR_INKSCAPE);
if ~inkscape_valid
    [file,pathname] = uigetfile('inkscape.exe',[opts.DIR_INKSCAPE, ' cannot be found, please select "inkscape.exe".']');
    opts.DIR_INKSCAPE = fullfile(pathname,file);
    if check_Inkscape_Dir(opts.DIR_INKSCAPE)
        setenv('DIR_INKSCAPE',opts.DIR_INKSCAPE);
    else
    	opts.doExportPDF = false;
        warning([' - Plot2LaTeX: Inkscape Installation not found.  Matlab command "system(''"',opts.DIR_INKSCAPE,'" --version'')" was not successful.'])
    end
else 
    setenv('DIR_INKSCAPE',opts.DIR_INKSCAPE);
end


%% ---------------- Check matlab version ----------------------------------
if verLessThan('matlab', '8.4.0.')
	error('Older versions than Matlab 2014b are not supported')
end


%% ---------------- Find all objects with text ----------------------------
TexObj = findall(h,'Type','Text'); % normal text, titels, x y z labels
LegObj = findall(h,'Type','Legend'); % legend objects
AxeObj = findall(h,'Type','Axes');  % axes containing x y z ticklabel
ColObj = findall(h,'Type','Colorbar'); % containg color bar tick
ConstLineObj = findall(h,'Type','ConstantLine');

PosAnchSVG      = {'start','middle','end'};
PosAligmentSVG  = {'start','center','end'};
PosAligmentMAT  = {'left','center','right'};

ChangeInterpreter(h,opts.Interpreter) % Change Interpreter if specified
h.PaperPositionMode = 'auto'; % Keep current size
getShortName(true); % reset the persistent variable


%% ---------------- Check Legend Position ---------------------------------
n_LegObj = length(LegObj);
legend_Position = cell(n_LegObj,1);
for i = 1:n_LegObj
    drawnow
    legend_Position{i} = LegObj(i).Position;
end


%% ---------------- Replace text with a label -----------------------------
if opts.doWaitbar
    Step = Step + 1;
    waitbar(Step/nStep,hWaitBar,'Replacing text with labels');
end

iLabel = 0; % generate label iterator
n_TexObj = length(TexObj);
for i = 1:n_TexObj % do for text, titles and axes labels
    if ~isempty(TexObj(i).String)
        iLabel = iLabel + 1;

        % find text string
        Labels(iLabel).TrueText = TexObj(i).String; %#ok<*AGROW>

        % find text aligment
        Labels(iLabel).Alignment = PosAligmentSVG{ismember(...
                                            PosAligmentMAT,...
                                            TexObj(i).HorizontalAlignment)};
        % find achor aligment svg uses this
        Labels(iLabel).Anchor = PosAnchSVG{ismember(...
                                        PosAligmentMAT,...
                                        TexObj(i).HorizontalAlignment)};
        % generate label
        [Labels,changed] = LabelText(iLabel,Labels);
        if changed
            TexObj(i).String = Labels(iLabel).LabelText;
        end

        %find text position
        Labels(iLabel).Position = TexObj(i).Position;
    end
end


%% ---------------- legend objects ----------------------------------------
n_LegObj = length(LegObj);
for i = 1:n_LegObj 
    n_Str = length(LegObj(i).String);
    for j = 1:n_Str
        iLabel = iLabel + 1;

        Labels(iLabel).TrueText = LegObj(i).String{j};
        Labels(iLabel).Alignment = PosAligmentSVG{1}; % legends are always left aligned
        Labels(iLabel).Anchor = PosAnchSVG{1};

        % generate legend label as a short string ('a' -> 'z')
        [Labels,changed] = LabelText(iLabel,Labels,true);
        if changed
            LegObj(i).String{j} = Labels(iLabel).LabelText;
        end
    end
    
    % Check if the substitute label are long enough
    while LegObj(i).Position(3) < legend_Position{i}(3)*0.97
        Labels(iLabel).LabelText = [Labels(iLabel).LabelText,'.'];
        LegObj(i).String{j} = Labels(iLabel).LabelText;
    end
    LegObj(i).Position = legend_Position{i};
end


%% ---------------- color bar objects -------------------------------------
n_ColObj = length(ColObj); 
for i = 1:n_ColObj
    isAxIn = strcmp(ColObj(i).AxisLocation,'in'); % find internal external text location
    location = ColObj(i).Location;
    if contains(location,'east') && isAxIn % text is right aligned
        Alignment = PosAligmentSVG{3};
        Anchor = PosAnchSVG{3};
    elseif contains(location,'east') % text is left aligned
        Alignment = PosAligmentSVG{1};
        Anchor = PosAnchSVG{1};
    elseif contains(location,'west') && isAxIn % text is left aligned
        Alignment = PosAligmentSVG{1};
        Anchor = PosAnchSVG{1};
    elseif contains(location,'west') % text is right aligned
        Alignment = PosAligmentSVG{3}; 
        Anchor = PosAnchSVG{3};
    else % text is centered
        Alignment = PosAligmentSVG{2};
        Anchor = PosAnchSVG{2};
    end
    
    n_Str = length(ColObj(i).TickLabels);
    for j = 1:n_Str
        iLabel = iLabel + 1;
        Labels(iLabel).TrueText = ColObj(i).TickLabels{j};
        Labels(iLabel).Alignment = Alignment;
        Labels(iLabel).Anchor = Anchor;

        [Labels,changed] = LabelText(iLabel,Labels);
        if changed
            ColObj(i).TickLabels{j} = Labels(iLabel).LabelText;
        end
    end
end


%%  ---------------- Constant line objects --------------------------------
n_ConstLineObj = length(ConstLineObj);
for i = 1:n_ConstLineObj % do for text, titles and axes labels
    if ~isempty(ConstLineObj(i).Label)
        iLabel = iLabel + 1;

        % find text string
        Labels(iLabel).TrueText = ConstLineObj(i).Label; %#ok<*AGROW>

        % find text aligment
        Labels(iLabel).Alignment = PosAligmentSVG{2};
        % find achor aligment svg uses this
        if isequal(ConstLineObj(i).InterceptAxis,'y')
            p_temp = {'top','middle','bottom'};
        else
            p_temp = {'bottom','middle','top'};
        end
        Labels(iLabel).Anchor = PosAnchSVG{ismember(p_temp,ConstLineObj(i).LabelVerticalAlignment)};
        % generate label
        [Labels,changed] = LabelText(iLabel,Labels);
        if changed
            ConstLineObj(i).Label = Labels(iLabel).LabelText;
        end
        
        %find text position
        Labels(iLabel).Position = [];        
    end
end


%% ---------------- do similar for axes objects, XTick, YTick, ZTick ------
n_AxeObj = length(AxeObj);
for i = 1:n_AxeObj 
    
    % Y-Axis
    if strcmp(AxeObj(i).YAxisLocation,'right') 
        % exeption for yy-plot, aligment is left for the right axis
        alignment = PosAligmentSVG{1}; %left
        anchor = PosAnchSVG{1};        %left
    else % normal y labels are right aligned
        alignment = PosAligmentSVG{3}; %right
        anchor = PosAnchSVG{3};        %right
    end
    [Labels, iLabel] = checkAxis(AxeObj(i).YAxis, Labels, iLabel, alignment, anchor);
    
    % Z-Tick
    alignment = PosAligmentSVG{3}; %right
    anchor = PosAnchSVG{3};        %right
    [Labels, iLabel] = checkAxis(AxeObj(i).ZAxis, Labels, iLabel, alignment, anchor);

    % X-Axis
    alignment = PosAligmentSVG{2}; %center
    anchor = PosAnchSVG{2};        %center
    [Labels, iLabel] = checkAxis(AxeObj(i).XAxis, Labels, iLabel, alignment, anchor);
end


%% ---------------- set text interpreter to plain text --------------------
ChangeInterpreter(h,'none');  
drawnow


%% ---------------- Support for exponential expression --------------------
% original figure: x10^exponent, in exported svg-file: #10^exponent
% replace # with x:
iLabel = iLabel +1;
Labels(iLabel).LabelText = '#'; 
Labels(iLabel).TrueText = '$\times$';
Labels(iLabel).Alignment = PosAligmentSVG{1};
Labels(iLabel).Anchor = PosAnchSVG{1};


%% ---------------- Save to fig and SVG -----------------------------------
if opts.doWaitbar
    Step = Step + 1;
    waitbar(Step/nStep,hWaitBar,'Saving figure to .svg file');
end

if ~(~contains(filename,'/') || ~contains(filename,'\'))
    filename = [pwd,'\',filename];
end

saveas(h,filename,'svg'); % export to svg


%% ---------------- Modify SVG file to replace labels with original text --
if opts.doWaitbar
    Step = Step + 1;
    waitbar(Step/nStep,hWaitBar,'Restoring text in .svg file');
end

nLabel = iLabel;
for iLabel = 1:nLabel
    Labels(iLabel).XMLText = EscapeXML(Labels(iLabel).TrueText);
end

try
    fin = fopen([filename,'.svg']); % open svg file
    fout = fopen([filename,'_temp.svg'],'w'); % make a temp file for modification

    string_line_in = fgetl(fin);%skip first line
    iLine = 1; % Line number
    nFoundLabel = 0; % Counter of number of found labels
    while ~feof(fin)
        string_line_out = string_line_in; % process new line
        iLine = iLine + 1;
        string_line_in = fgetl(fin);

        FoundLabelText = regexp(string_line_in,'>.+</text','match'); %try to find label
        if ~isempty(FoundLabelText)
            iLabel = find(ismember(...
                                {Labels.LabelText},...
                                FoundLabelText{1}(2:end-6))); % find label number
            if ~isempty(iLabel)
                doAlignment = true;
                nFoundLabel = nFoundLabel + 1;
                alignment = Labels(iLabel).Alignment;
                anchor = Labels(iLabel).Anchor;
                text = ['>',Labels(iLabel).XMLText,'</text'];
            else
                doAlignment = true;
                alignment = PosAligmentSVG{1};
                anchor = PosAnchSVG{1};
                text = FoundLabelText{1};
            end
            
            % Append text alignment in prevous line
            if doAlignment
                string_line_out_temp = [string_line_out(1:end-1),...
                            'text-align:', alignment,...
                            ';text-anchor:', anchor, '"'];
            end
            
            % correct x - position offset
            string_line_out_temp = regexprep(string_line_out_temp,'x="\S*"','x="0"');

            % correct y - position offset, does not work correctly
            [startIndex,endIndex] = regexp(string_line_out_temp,'y="\S*"');
            yOffset = str2double(string_line_out_temp((startIndex+3):(endIndex-1)));
            string_line_out_temp = regexprep(...
                                string_line_out_temp,...
                                'y="\S*"',...
                                ['y="', num2str(yOffset*opts.yCorrFactor), '"']); 

            % Replace label with original string
            string_line_in_temp = strrep(string_line_in, ...
                                    FoundLabelText{:},...
                                    text);

            string_line_in = string_line_in_temp;
            string_line_out = string_line_out_temp;
        end
        fprintf(fout,'%s\n',string_line_out);
    end
    fprintf(fout,'%s\n',string_line_in);

    fclose(fin);
    fclose(fout);
    movefile([filename,'_temp.svg'],[filename,'.svg'])
    if nFoundLabel == 0
        warning(' - Plot2LaTeX: No text elements found and updated. Please check if no text is used or if the Renderer is "painters".')
    end
catch
    warning(' - Plot2LaTeX: Could not update the svg. No permission?')
    fclose('all');
    delete([filename,'_temp.svg']);
end


%% ---------------- Invoke Inkscape to generate PDF + PDF_TeX -------------
if opts.doExportPDF
    if opts.doWaitbar
        Step = Step + 1;
        waitbar(Step/nStep,hWaitBar,'Saving .svg to .pdf file');
    end
    if check_Inkscape_Version(opts.DIR_INKSCAPE)
        cmdtext = sprintf('"%s" "%s.svg" --export-filename="%s.pdf" --export-latex --export-area-page',...
            opts.DIR_INKSCAPE, filename, filename);
    else % inkscape v0
        cmdtext = sprintf('"%s" "%s.svg" --export-pdf "%s.pdf" --export-latex -export-area-page',...
            opts.DIR_INKSCAPE, filename, filename);
    end
    [~,cmdout] = system(cmdtext);

    % test if a .pdf and .pdf_tex file exist
    if exist([filename,'.pdf'],'file')~= 2 || exist([filename,'.pdf_tex'],'file')~= 2
        warning([' - Plot2LaTeX: No .pdf or .pdf_tex file produced, please check your Inkscape installation and specify installation directory correctly: ', cmdout])
    end
end


%% ---------------- Clean up ----------------------------------------------
if opts.doWaitbar
    close(hWaitBar);
end
close(h)
end


%% ------------------------------------------------------------------------
function [Labels, iLabel] = checkAxis(ax, Labels, iLabel, alignment, anchor)
n_labels = length(ax.TickLabels);
if ax.Exponent ~= 0
    suffix = '';
    origFormat = ax.TickLabelFormat;
    list = {Labels.LabelText};
    doChange = any(ismember(ax.TickLabels,list));
    while doChange
        suffix = [suffix,'.']; 
        ax.TickLabelFormat = [origFormat,suffix];
        doChange = any(ismember(ax.TickLabels,list));
    end
    
    for j = 1:n_labels
        iLabel = iLabel + 1;
        if isempty(suffix)
            Labels(iLabel).TrueText = ax.TickLabels{j};
            Labels(iLabel).LabelText = ax.TickLabels{j};
        else
            Labels(iLabel).LabelText = ax.TickLabels{j};
            Labels(iLabel).TrueText = Labels(iLabel).LabelText(1:end-length(suffix));
        end
        Labels(iLabel).Alignment = alignment;
        Labels(iLabel).Anchor = anchor;
    end
else
    for j = 1:n_labels
        iLabel = iLabel + 1;
        Labels(iLabel).Alignment = alignment;
        Labels(iLabel).Anchor = anchor;
        Labels(iLabel).TrueText = ax.TickLabels{j};
        [Labels,changed] = LabelText(iLabel,Labels);
        if changed
            ax.TickLabels{j} = Labels(iLabel).LabelText;
        end
    end
end
end


%% ------------------------------------------------------------------------
function [Labels, changed] = LabelText(index, Labels, doShorten)
% LABELTEXT generates labels based on label number
if nargin == 2 % Check Input
    doShorten = false;
end

if doShorten % Get Initial Text
    text = getShortName();
else
    text = Labels(index).TrueText;
end

if isfield(Labels,'LabelText')
    LabelList = {Labels(1:index-1).LabelText};
    
    text = change_chars(text);
    while ismember(text,LabelList) % Check if Label already exists
        if doShorten
            text = getShortName();
        else
            text = [text,'.'];
        end
    end
end
changed = ~strcmp(text,Labels(index).TrueText);
Labels(index).LabelText = text;
end


%% ------------------------------------------------------------------------
function ChangeInterpreter(h,Interpreter)
% CHANGEINTERPRETER puts interpeters in figure h to Interpreter

if ~isempty(Interpreter)
    TexObj = findall(h,'Type','Text');
    LegObj = findall(h,'Type','Legend');
    AxeObj = findall(h,'Type','Axes');  
    ColObj = findall(h,'Type','Colorbar');
    ConLiObj = findall(h,'Type','ConstantLine');

    Obj = [TexObj;LegObj;ConLiObj]; % Tex and Legend opbjects can be treated similar
    
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
end


%% ------------------------------------------------------------------------
function strXML = EscapeXML(str)
% ESCAPEXML repaces special characters(<,>,',",&) -> (&lt;,&gt;,&apos;,&quot;,&amp;)
    escChar = {'&','<','>','''','"'};
    repChar = {'&amp;','&lt;','&gt;','&apos;','&quot;'};
    strXML = regexprep(str,escChar,repChar);
end


%% ------------------------------------------------------------------------
function str = change_chars(str)
% \"U -> U, etc.
    escChar = {char(228),char(246),char(228),char(228),char(228),char(228)};
    repChar = {'a','o','u','A','O','U'};
    str = regexprep(str,escChar,repChar);
end


%% ------------------------------------------------------------------------
function [fig] = copy_Figure(fig_orig)
% this program copies a figure 

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


%% ------------------------------------------------------------------------
function [bool,validEntry] = isValidEntry(validEntries, input, fcnName, doWarning)
% allow input of an options structure that overwrites existing fieldnames with its own, for increased flexibility
bool = false;
validEntry = '';
valIdx = strcmp(input,validEntries); % Check case sensitive

if nnz(valIdx) == 0 && ~isstruct(input) && ischar(input)
    valIdx = strcmpi(input,validEntries); % Check case insensitive
end

if nnz(valIdx) == 0 && ~isstruct(input) && ischar(input)
    valIdx = contains(validEntries,input,'IgnoreCase',true); % Check case insensitive
end

if nnz(valIdx) > 1 && doWarning
    strings = [validEntries(1); strcat(',', validEntries(2:end)) ] ; % removes ' ' at the end when concatenating
    longString = [strings{:}];
    longString = strrep(longString,',',', ');
    error(['-',fcnName,'.m: Option "', input,'" not correct. Allowed options are [', longString, '].'])
elseif nnz(valIdx) > 0 % All else options
    validEntry = validEntries{valIdx};
    bool = true;
elseif doWarning && ~isstruct(input) && ischar(input)
    strings = [validEntries(1); strcat(',', validEntries(2:end)) ] ; % removes ' ' at the end when concatenating
    longString = [strings{:}];
    longString = strrep(longString,',',', ');
    warning(['-',fcnName,'.m: Option "', input,'" not found. Allowed options are [', longString, '].'])
end
end


%% ------------------------------------------------------------------------
function isValid = check_Inkscape_Dir(inkscape_path)
% isValid = CHECK_INKSCAPE_DIR(path) checks if the path to inkscape is
% correct
[status, result] = system(['"',inkscape_path,'" --version']);
isValid = contains(result,'Inkscape') && status == 0;
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


%% ------------------------------------------------------------------------
function text = getShortName(reset)

if nargin == 0
    reset = false;
end
    

persistent cellElement idx
if isempty(cellElement) || reset
    cellElement = {0};
    idx = 1;
end

if ~reset 
    celllen = length(cellElement);
    if cellElement{idx} == 26 && idx == celllen % Add new Char
        idx = 1;
        cellElement = num2cell(ones(1,celllen+1));
    elseif  cellElement{idx} == 26 % increment the char at postion idx
        idx = idx+1; 
        cellElement{idx} = cellElement{idx}+1;
    else
        cellElement{idx} = cellElement{idx}+1;
    end

    elements = cell2mat(cellElement)-1;
    text = char(char('a')+elements);
else
    text = [];
end
end