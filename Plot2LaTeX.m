function Plot2LaTeX(h_in, filename, varargin)
%
% PLOT2LATEX saves matlab figure as a pdf file in vector format for
%   inclusion into LaTeX. Requires free and open-source vector graphics
%   editor Inkscape. This allows links of varible names to be placed within
%   the axis or legend and so on, or variables can be subsequently renamed
%   without having to recreate the Matlab plot.
%
% options:
%   'Renderer':        'painters' (default), 'opengl', ''(no change)
%                        Should the 'Renderers' Option of the plot be
%                        changed? 'painters' is important for vector
%                        graphics
%   'yCorrFactor':     0.8 (default, in px)
%                        Option for manually correcting the y position of
%                        all text elements inside of the svg-file.
%   'legCorrFactor':   1.02 (default, in percent so 102%)
%                        Option for manually correct the horizontal size of
%                        a legend entry.
%   'DIR_INKSCAPE':    'inkscape.exe' (default), 'C:/Program Files/
%                      Inkscape/bin/inkscape.exe'
%                        directory to the inkscape.exe that is used inside
%                        the command window. If the path to inkscape is
%   'Verbose':         'console' (default), 'waitbar', 'both', false
%                        Should a waitbar appear to show progress or a 
%                        console text
%   'useOrigFigure'    false (default)
%                        Use the original figure or create a copy? Some
%                        features of a plot (e.g. background color) copied
%                        at all or correctly.
%   'OnlySVG':         false (default)
%                        Option to stop after creating the svg file. Can
%                        be used, if the plots are used as svg files or
%                        if inkscape is not installed.
%   'Interpreter':     '' (default) , 'latex', 'none', 'tex'
%                        changes the matlab text interpreter if not left
%                        empty
%   'FontSize':        auto (default), '', 'fixed', 14 (in pt)
%                        Option to update the fontSize inside of the Figure
%                        So that the proportions of the svg Plot are
%                        correct use '' if the fontSize should not be
%                        altered beforehand (could lead to wrong legend
%                        sizes, etc.). Use 'fixed', if all fontsizes should
%                        be set inside the SVG file corresponding to the
%                        predefined fontsize. Use 'auto' if the prevalent
%                        font size should be selected.
%   'ReplaceList':     '' (default), [a cell with 2 columns, first column: 
%                        text in figure, second column: new text in .svg]
%             	         Should a placeholder text in the figure be 
%                        replaced with a LaTeX command that e.g. matlab 
%                        can't correctly display?
%                        example : {'placeholder','\acr{thickness}';
%                                   'placeholder2','$\exp{-4r^2}$'}
%'Inkscape_Export_Mode': 'export-area-drawing' (default), 'export-area',
%                        'export-area-page', 'export-use-hints'
%                        inkscape export options, see wiki.inkscape.org
%
% Example function calls:
%   - PLOT2LATEX(gcf, 'FirstPlot')
%   - PLOT2LATEX(gcf, 'FirstPlot', 'Verbose', false)
%   - PLOT2LATEX(gcf, 'FirstPlot', 'OnlySVG', false, 'FontSize', '')
%   - PLOT2LATEX(gcf, 'FirstPlot', options_struct) with
%     options_struct = struct('OnlySVG', false, 'option2',value,...);
%
% PLOT2LATEX(h,filename) saves figure with handle h to a file specified by
%   filename, without extention. Filename can contain a a full path or a
%   name (e.g. 'C:\images\title', 'title') to save the figure to a
%   different location.
%
% PLOT2LATEX(h,filename, 'option1', value,...) saves figure with specified
%   options.
%
% PLOT2LATEX requires a installation of Inkscape. The program's
%   location can be 'hard coded' into this matlab file if 'inkscape' is not
%   a valid command for the command window. Please specify your inscape
%   file location by modifying opts.DIR_INKSCAPE variable on the
%   first line of the actual code or use
%   PLOT2LATEX(...,'DIR_INKSCAPE',dir_to_inkscape).
%
% PLOT2LATEX saves the figures to .svg format. It invokes Inkscape to
%   save the svg to a .pdf and .pdf_tex file to be incorporated into LaTeX
%   document using \begin{figure} \input{image.pdf_tex} \end{figure}.
%   More information on the svg to pdf conversion can be found here:
%   ftp://ftp.fu-berlin.de/tex/CTAN/info/svg-inkscape/InkscapePDFLaTeX.pdf
%
% PLOT2LATEX produces three files: .svg, .pdf, .pfd_tex. The .svg-file
%   contains vector image. The .pdf-file contains figure without the text.
%   The .pdf_tex-file contains the text including locations and other
%   type setting.
%
%   The produced .svg file can be manually modified in Inkscape and
%   included into the .tex file using the using the built-in "save to pdf"
%   functionality of Inkscape.
%
% PLOT2LATEX saves the figure to a svg and pdf file with
%   approximately the same width and height. Specify the Font size and size
%   within Matlab for correct conversion. For FontSize use
%   set(findall(h,'-property','FontSize'),'FontSize',opts.FontSize)
%   For PlotSize use: set(h,'Units',unit) with unit='cm','pt','px'
%   set(h,'position',[0,0, width, height]) with width/height in unit
%
% Workflow:
% - Matlab renames duplicate strings of the figure. The strings are
%   stored to be used later. To prevent a change in text size, duplicate
%   labels get "." at the end of the label.
% - Matlab saves the figure with modified labels to a svg file.
% - Matlab opens the svg file and restores the labels with the original
%   string
% - Matlab invokes Inkscape to save the svg file to a pdf + pdf_tex file.
% - The pdf_tex is to be included into LaTeX.
%
% Features:
% - Complex figures such as plotyy, logarithmic scales.
% - It parses LaTeX code, even if it is not supported by Matlab LaTeX.
% - Supports real transparency.
% - SVG is a better supported, maintained and editable format than eps
% - SVG allows simple manual modification into Inkscape.
%
% Limitation:
% - Text resize is still done in PLOT2LATEX. The LaTeX fonts in matlab do
%   not correspond completely with the LaTeX font size.
% - Text boxes with LaTeX code which is not interpretable by matlab
%   results in too long text boxes. Use a placeholder text with the option
%   'ReplaceList' instead (the placeholder should have the right length).
% - Very large figures sometimes result in very large waiting times.
% - Older versions than matlab 2014b are not supported.
% - PLOT2LATEX currently does not work with titles consisting of multiple
%   lines.
% - PLOT2LATEX does not work with annotation textbox objects.
%
% To do:
% - Annotation textbox objects
% - Allow multiple line text
% - Use findall(h,'-property','String')
% - Size difference .svg and .fig if specifying units other than px.
%     (Matlab limitation?)
%
% Version:  1.3 / 1.4 / 1.5 / 1.6/ 1.7/ 1.8/ 1.9/ 2.0
%   Author:    C. Schulte
%   Date:     27.05.2023
%   Contact:  C.Schulte@irt.rwth-aachen.de
%
% Version:  1.10
%   Author:    M. Zimmer
%   Date:     13.01.2023
%
% Version:  1.2
%   Author:    J.J. de Jong, K.G.P. Folkersma
%   Date:     20/04/2016
%   Contact:  j.j.dejong@utwente.nl

%% ---------------- Config ------------------------------------------------
% default inkscape location, e.g.
% DIR_INKSCAPE = ['C:\Program Files\Inkscape\bin\inkscape.exe', 'inkscape',
% any Path to the inkscape.exe] : Specify location of your inkscape installation,
% if 'inkscape': checks if inkscape.exe is already known to shell (system path).
opts.DIR_INKSCAPE = 'inkscape';
if ~isempty(getenv('DIR_INKSCAPE')) % check if environment variable already exists
    opts.DIR_INKSCAPE = getenv('DIR_INKSCAPE');
    check_INKSCAPE_Installation = false;
else
    check_INKSCAPE_Installation = true;
end

% yCorrFactor = [any number]: correcting the y position of some text elements
opts.yCorrFactor = 0.8;

% legCorrFactor = [any number]: correcting the legend horizontal size in percent
opts.legCorrFactor = 1.02;

% useOrigFigure = [false, true] : should the original figure be used or copied?
opts.useOrigFigure = false;

% Renderer = ['painters','opengl',...] : "painters" renderer recommended
opts.Renderer = 'painters';

% FontSize = ['auto', 'fixed', '', any number in pt] : Font Size of all Text,
%       use '' if the size should not be changed, use 'auto' if the primary
%       fontsize should be evaluated, use 'fixed', if all text should stay
%       in the predefined fontsizes 
opts.FontSize = 'auto';

% Verbose = ['waitbar', 'console', 'both', false] : Should a waitbar appear
%       to show progress or a console text
opts.Verbose = 'console';

% OnlySVG = [false, true] : Option to stop after creating the svg file. Can
%       be used, if the plots are used as svg files or if inkscape is not
%       installed.
opts.OnlySVG = false;

% Inkscape_Export_Mode = ['export-area', 'export-area-drawing',
%                         'export-use-hints', 'export-area-page']
%                      : See https://wiki.inkscape.org/wiki/Using_the_Command_Line
opts.Inkscape_Export_Mode = 'export-area-drawing';

% Interpreter = ['','tex','latex','none'] : matlab text interpreter option
%                                           '' -> dont change
opts.Interpreter = '';

% ReplaceList = ['',a cell with 2 columns, first column: text in figure,
%                                          second column: new text in .svg]
%             : Should a placeholder text in the figure be replaced with a
%               LaTeX command that e.g. matlab can't display?
%     example : {'placeholder','\acr{thickness}';'placeholder2','$\exp{-4r^2}$'}
opts.ReplaceList = {};

% ------------------------- Config end --------------------------- %
opts = checkOptions(opts, varargin); % update default options based on information in varargin


%% ---------------- Check Verbose -----------------------------------------
switch opts.Verbose
    case 'waitbar'
        opts.Verbose = [true, false];
    case 'console'
        opts.Verbose = [false, true];
    case 'both'
        opts.Verbose = [true, true];
    otherwise
        opts.Verbose = [false, false];
end


%% ---------------- Check Filename ----------------------------------------
if isstring(filename)
    filename = char(filename);
end


%% ---------------- init waitbar ------------------------------------------
if opts.Verbose(1)
    nStep = 4;
    Step = 0;
    hWaitBar = waitbar(Step/nStep, 'Initializing');
end
if opts.Verbose(2)
    [~, figureName] = fileparts(filename);
    disp([' - Plot2LaTeX.m: Export of Figure "', figureName, '" started.'])
end


%% ---------------- Create a figure copy ----------------------------------
if ~strcmp(h_in.Type, 'figure')
    if ~isempty(findobj('type', 'figure')) % Check if a figure exists
        warning(' - Plot2LaTeX.m: h_in object is not a figure. Using "gcf" instead.')
        h_in = gcf;
    else
        error(' - Plot2LaTeX.m: h_in object is not a figure.')
    end
end
if opts.useOrigFigure
    h = h_in;
    if opts.Verbose(2)
        disp(' - Plot2LaTeX.m: Using the original Figure to export the svg.')
    end
else
    h = copy_Figure(h_in);
    if opts.Verbose(2)
        disp(' - Plot2LaTeX.m: Creating a copy of the figure.')
    end
end


%% ---------------- Check Font Size ---------------------------------------
if strcmp(opts.FontSize, 'auto')
    opts.FontSizeMode = 'set';
elseif strcmp(opts.FontSize, 'fixed')
    opts.FontSizeMode = 'fixed';
elseif strcmp(opts.FontSize, '')
    opts.FontSizeMode = 'none';
else
    opts.FontSizeMode = 'set';
end

% Evaluate median fontsize -> default size
if strcmp(opts.FontSize, 'auto') || strcmp(opts.FontSize, 'fixed')
    FontSizes = cell2mat(get(findall(h, '-property', 'FontSize'), 'FontSize'));
    if ~isempty(FontSizes)
        opts.FontSize = median(FontSizes);
    else
        if opts.Verbose(2)
            disp(' - Plot2LaTeX.m: No text elements found.')
        end
    end
end

% Set Font Sizes
if strcmp(opts.FontSizeMode,'set') && ~isempty(opts.FontSize)
    set(findall(h, '-property', 'FontSize'), 'FontSize', opts.FontSize)
    set(findall(h, '-property', 'LabelFontSizeMultiplier'), 'LabelFontSizeMultiplier', 1)
    set(findall(h, '-property', 'TitleFontSizeMultiplier'), 'TitleFontSizeMultiplier', 1)
    %drawnow
    if opts.Verbose(2)
        disp([' - Plot2LaTeX.m: Fontsize of the figure set to "', num2str(opts.FontSize), '".'])
    end
end


%% ---------------- Check Renderer ----------------------------------------
if ~isempty(opts.Renderer) %WARNING: large size figures can become very large
    if opts.Verbose(2)
        disp(' - Plot2LaTeX.m: Updating the Renderer.')
    end
    h.Renderer = opts.Renderer; % set render
end


%% ---------------- test if inkscape installation is correct --------------
if ~opts.OnlySVG && check_INKSCAPE_Installation
    inkscape_valid = check_Inkscape_Dir(opts.DIR_INKSCAPE);
    if ~inkscape_valid && ~opts.OnlySVG
        if opts.Verbose(2)
            disp(' - Plot2LaTeX.m: Invalid Inkcape path. Opening the UI.')
        end
        [file, pathname] = uigetfile('inkscape.exe', [opts.DIR_INKSCAPE, ' cannot be found, please select "inkscape.exe".']');
        opts.DIR_INKSCAPE = fullfile(pathname, file);
        if check_Inkscape_Dir(opts.DIR_INKSCAPE)
            setenv('DIR_INKSCAPE', opts.DIR_INKSCAPE);
        else
            opts.OnlySVG = true;
            disp([' - Plot2LaTeX.m: Inkscape Installation not found.  Matlab command "system(''"', opts.DIR_INKSCAPE, '" --version'')" was not successful.'])
        end
    elseif inkscape_valid
        disp(' - Plot2LaTeX.m: Inkscape Installation found.')
        setenv('DIR_INKSCAPE', opts.DIR_INKSCAPE);
    end
end

%% ---------------- Check matlab version ----------------------------------
if verLessThan('matlab', '8.4.0.')
    error(' - Plot2LaTeX.m: Older versions than Matlab 2014b are not supported')
end


%% ---------------- Find all objects with text ----------------------------
TexObj = findall(h, 'Type', 'Text'); % normal text, titels, x y z labels
LegObj = findall(h, 'Type', 'Legend'); % legend objects
AxeObj = findall(h, 'Type', 'Axes'); % axes containing x y z ticklabel
ColObj = findall(h, 'Type', 'Colorbar'); % containg color bar tick
ConstLineObj = findall(h, 'Type', 'ConstantLine');

PosAnchSVG = {'start', 'middle', 'end'};
PosAligmentSVG = {'start', 'center', 'end'};

ChangeInterpreter(h, opts.Interpreter) % Change Interpreter if specified
h.PaperPositionMode = 'auto'; % Keep current size
getShortName('','',true); % reset the persistent variable


%% ---------------- Replace text with a label -----------------------------
Labels = struct('type','','TrueText','','FontSize','','Color','','Alignment','',...
    'Anchor','','setLabel','','Position','','Obj','','mode','','LabelText','','XMLText','');
Labels(1) = [];

if opts.Verbose(1)
    Step = Step + 1;
    waitbar(Step/nStep, hWaitBar, 'Cataloging all text elements.');
end
if opts.Verbose(2)
    disp(' - Plot2LaTeX.m: Cataloging all text elements.');
end

for i = 1:length(TexObj) % do for text, titles and axes labels
    if ~isempty(TexObj(i).String)
        Labels = addElement(TexObj(i),'Text',Labels);
    end
end
for i = 1:length(ColObj) % color bar objects
    Labels = addElement(ColObj(i),'ColorBar',Labels);
end
for i = 1:length(LegObj) % legend objects  
    LegObj(i).Units = 'pixels';
    Labels = addElement(LegObj(i),'Legend',Labels);
end
for i = 1:length(ConstLineObj) % Constant line objects
    if ~isempty(ConstLineObj(i).Label)
        Labels = addElement(ConstLineObj(i),'ConstantLine',Labels);
    end
end
for i = 1:length(AxeObj) %do similar for axes objects, XTick, YTick, ZTick
    % Y-Axis
    if strcmp(AxeObj(i).YAxisLocation, 'right') % exeption for yy-plot, aligment is left for the right axis
        type = 'YYAxis';
    else % normal y labels
        type = 'YAxis';
    end
    Labels = addElement(AxeObj(i).YAxis,type,Labels);
end
for i = 1:length(AxeObj) %do similar for axes objects, XTick, YTick, ZTick
    % Z-Axis
    Labels = addElement(AxeObj(i).ZAxis,'ZAxis', Labels);
end
for i = 1:length(AxeObj) %do similar for axes objects, XTick, YTick, ZTick
    % X-Axis
    Labels = addElement(AxeObj(i).XAxis,'XAxis', Labels);
end

% Support for exponential expression
% original figure: x10^exponent, in exported svg-file: #10^exponent
% replace # with x:
i = length(Labels)+1;
Labels(i).LabelText = {'#'};
Labels(i).TrueText = {'$\times$'};
Labels(i).Alignment = PosAligmentSVG{1};
Labels(i).Anchor = PosAnchSVG{1};
Labels(i).Color = {[0,0,0]};
Labels(i).type = 'None';

% Create the XML Text for each element
nLabel = length(Labels);
for iLabel = 1:nLabel
    Labels(iLabel).XMLText = Text2LaTeX(Labels(iLabel), opts);
end


%% ---------------- set text interpreter to plain text --------------------
ChangeInterpreter(h, 'none');


%% ---------------- Save to fig and SVG -----------------------------------
if opts.Verbose(1)
    Step = Step + 1;
    waitbar(Step/nStep, hWaitBar, 'Saving figure to .svg file');
end
if opts.Verbose(2)
    disp(' - Plot2LaTeX.m: Saving figure to .svg file.')
end
if ~contains(filename, filesep)
    filename = fullfile(pwd, filename);
end

saveas(h, filename, 'svg'); % export to svg


%% ---------------- Modify SVG file to replace labels with original text --
if opts.Verbose(1)
    Step = Step + 1;
    waitbar(Step/nStep, hWaitBar, 'Restoring text in .svg file');
end
if opts.Verbose(2)
    disp(' - Plot2LaTeX.m: Restoring text in .svg file.')
end

try
    updateSVG(filename, Labels, opts)
catch
    warning(' - Plot2LaTeX.m: Could not update the svg. No permission?')
    fclose('all');
end


%% ---------------- Invoke Inkscape to generate PDF + PDF_TeX -------------
if ~opts.OnlySVG
    if opts.Verbose(1)
        Step = Step + 1;
        waitbar(Step/nStep, hWaitBar, 'Converting .svg to .pdf file');
    end
    if opts.Verbose(2)
        disp(' - Plot2LaTeX.m: Converting .svg to .pdf file')
    end
    if check_Inkscape_Version(opts.DIR_INKSCAPE) % inkscape v1 and above
        cmdtext = sprintf('"%s" "%s.svg" --export-filename="%s.pdf" --export-latex --%s', opts.DIR_INKSCAPE, filename, filename, opts.Inkscape_Export_Mode);
    else % inkscape v0
        cmdtext = sprintf('"%s" "%s.svg" --export-pdf "%s.pdf" --export-latex -%s', opts.DIR_INKSCAPE, filename, filename, opts.Inkscape_Export_Mod);
    end
    [~, cmdout] = system(cmdtext);

    % test if a .pdf and .pdf_tex file exist
    if exist([filename, '.pdf'], 'file') ~= 2 || exist([filename, '.pdf_tex'], 'file') ~= 2
        warning([' - Plot2LaTeX.m: No .pdf or .pdf_tex file found, please check your Inkscape installation and specify installation directory correctly: ', cmdout])
    end
end


%% ---------------- Clean up ----------------------------------------------
if opts.Verbose(1)
    close(hWaitBar);
end
if opts.Verbose(2)
    disp(' - Plot2LaTeX.m: Finished.');
end
close(h)
end

%% ------------------------------------------------------------------------
function Labels = addElement(elem, type, Labels)
PosAnchSVG = {'start', 'middle', 'end', 'auto'};
PosAligmentSVG = {'start', 'center', 'end', 'auto'};
PosAnchMAT = {'left', 'center', 'right'};
PosAligmentMAT = {'top', 'middle', 'bottom'};

% iLabel = length(Labels);

persistent list

if isempty(list)
    % Text Elements
    list = struct('type','Text','TrueText',@(obj) {obj.String},...
        'FontSize',@(obj) {obj.FontSize},'Color',@(obj) {obj.Color},...
        'Alignment',@(obj) PosAligmentSVG{ismember(PosAligmentMAT, obj.VerticalAlignment)},...
        'Anchor',@(obj) PosAnchSVG{ismember(PosAnchMAT, obj.HorizontalAlignment)},...
        'setLabel',@(obj,label) @(label) set(obj,'String',label),...
        'Position',@(obj) '','Obj',@(obj) obj,'mode', 1,'XMLText','');
    
    % Legend Elements
    list(2) = struct('type','Legend','TrueText',@(obj) erv(obj.String),...
        'FontSize',@(obj) {obj.FontSize},'Color',@(obj) {obj.TextColor},...
        'Alignment', PosAligmentSVG{2},...
        'Anchor', PosAnchSVG{1},...
        'setLabel',{@(obj,label) @(label) set(obj,'String',label)},...
        'Position',@(obj) obj.Position,'Obj',@(obj) obj,'mode', @(obj) strcmp(obj.Orientation,'horizontal')+1,'XMLText','');
    
    % ColorBar Elements
    list(3) = struct('type','ColorBar','TrueText',@(obj) erv(obj.TickLabels),...
        'FontSize',@(obj) {obj.FontSize},'Color',@(obj) {obj.Color},...
        'Alignment',@(obj) getAlignmentColorBar(obj),...
        'Anchor',@(obj) getAnchorColorBar(obj),...
        'setLabel',{@(obj,label) @(label) set(obj,'TickLabels',label)},...
        'Position',@(obj) '','Obj',@(obj) obj,'mode', 0,'XMLText','');
    
    % Constant Line Elements
    list(4) = struct('type','ConstantLine','TrueText',@(obj) {obj.Label},...
        'FontSize',@(obj) {obj.FontSize},'Color',@(obj) {obj.Color},...
        'Alignment',@(obj) getAlignmentConstantLine(obj), ...
        'Anchor',@(obj) getAnchorConstantLine(obj),...
        'setLabel',{@(obj,label) @(label) set(obj,'Label',label)},...
        'Position',@(obj) '','Obj',@(obj) obj,'mode', 0,'XMLText','');
    
    % YAxis Elementt
    list(5) = struct('type','YAxis','TrueText',@(obj) erv(obj.TickLabels),...
        'FontSize',@(obj) {obj.FontSize},'Color',@(obj) {obj.Color},...
        'Alignment',PosAligmentSVG{4},...
        'Anchor',PosAnchSVG{4},... 
        'setLabel',{@(obj,label) @(label) set(obj,'TickLabels',label)},...
        'Position',@(obj) '','Obj',@(obj) obj,'mode', @(obj) (obj.Exponent~=0)*3,'XMLText','');
    
    % YY-Plot Element
    list(6) = struct('type','YYAxis','TrueText',@(obj) erv(obj.TickLabels),...
        'FontSize',@(obj) {obj.FontSize},'Color',@(obj) {obj.Color},...
        'Alignment',PosAligmentSVG{4},...
        'Anchor',PosAnchSVG{4},... 
        'setLabel',{@(obj,label) @(label) set(obj,'TickLabels',label)},...
        'Position',@(obj) '','Obj',@(obj) obj,'mode', @(obj) (obj.Exponent~=0)*3,'XMLText','');
    
    % XAxis
    list(7) = struct('type','XAxis','TrueText',@(obj) erv(obj.TickLabels),...
        'FontSize',@(obj) {obj.FontSize},'Color',@(obj) {obj.Color},...
        'Alignment',PosAligmentSVG{4},...
        'Anchor',PosAnchSVG{4},... 
        'setLabel',{@(obj,label) @(label) set(obj,'TickLabels',label)},...
        'Position',@(obj) '','Obj',@(obj) obj,'mode', @(obj) (obj.Exponent~=0)*3,'XMLText','');
    
    %ZAxis
    list(8) = struct('type','ZAxis','TrueText',@(obj) erv(obj.TickLabels),...
        'FontSize',@(obj) {obj.FontSize},'Color',@(obj) {obj.Color},...
        'Alignment',PosAligmentSVG{4},...
        'Anchor',PosAnchSVG{4},... 
        'setLabel',{@(obj,label) @(label) set(obj,'TickLabels',label)},...
        'Position',@(obj) '','Obj',@(obj) obj,'mode', @(obj) (obj.Exponent~=0)*3,'XMLText','');
end


idxElement = ismember({list.type},type);
if any(idxElement)
    listElement = list(idxElement);
    names = fieldnames(listElement);
    data = cell(2,length(names));
    for idx = 1:length(names)
        if ~isa(listElement.(names{idx}),'function_handle')
            data(:,idx) = [names(idx);listElement.(names{idx})];
        else
            data(:,idx) = [names(idx);{{listElement.(names{idx})(elem)}}];
        end
    end
    
    % Create Struct
    newLabel = struct(data{:});
    [newLabel,changed] = getShortName(newLabel,newLabel.mode);
    
    % Rename if needed
    if changed
        newLabel.setLabel(newLabel.LabelText);
    end
    Labels = [Labels,newLabel];
end

function Alignment = getAlignmentColorBar(obj)
isAxIn = strcmp(obj.AxisLocation, 'in'); % find internal external text location
    location = obj.Location;
    if contains(location, 'east') && isAxIn % text is right aligned
        Alignment = PosAligmentSVG{2};
    elseif contains(location, 'east') % text is left aligned
        Alignment = PosAligmentSVG{2};
    elseif contains(location, 'west') && isAxIn % text is left aligned
        Alignment = PosAligmentSVG{2};
    elseif contains(location, 'west') % text is right aligned
        Alignment = PosAligmentSVG{2};
    else % text is centered
        Alignment = PosAligmentSVG{4};
    end
end
function Anchor = getAnchorColorBar(obj)
isAxIn = strcmp(obj.AxisLocation, 'in'); % find internal external text location
    location = obj.Location;
    if contains(location, 'east') && isAxIn % text is right aligned
        Anchor = PosAnchSVG{3};
    elseif contains(location, 'east') % text is left aligned
        Anchor = PosAnchSVG{1};
    elseif contains(location, 'west') && isAxIn % text is left aligned
        Anchor = PosAnchSVG{1};
    elseif contains(location, 'west') % text is right aligned
        Anchor = PosAnchSVG{3};
    else % text is centered
        Anchor = PosAnchSVG{2};
    end
end
function Alignment = getAlignmentConstantLine(obj)
isXLine = strcmp(obj.InterceptAxis, 'x');
if isXLine
    Alignment = PosAligmentSVG{ismember(fliplr(PosAnchMAT),obj.LabelHorizontalAlignment)};
else
    Alignment = PosAligmentSVG{ismember(fliplr(PosAligmentMAT),obj.LabelVerticalAlignment)};
end
end
function Anchor = getAnchorConstantLine(obj)
isXLine = strcmp(obj.InterceptAxis, 'x');
if isXLine 
    Anchor = PosAnchSVG{ismember(fliplr(PosAligmentMAT),obj.LabelVerticalAlignment)};
else
    Anchor = PosAnchSVG{ismember(PosAnchMAT,obj.LabelHorizontalAlignment)};
end
end
end

%% ------------------------------------------------------------------------
function updateSVG(filename, Labels, opts)

% Load SVG to memory and change the line breaks
text = parseSVG(filename);
fout = fopen([filename, '.svg'], 'w'); % open svg file
nFoundLabel = 0;

text = checkForLegend(text, Labels, opts);
LabelList = {Labels.LabelText};

getLabelIndex = @(label) cellfun(@(x) any(ismember(x,label)),LabelList,'UniformOutput', true);

% Loop over every line in svg-text
for line_idx = 1:length(text)
    text_line = text{line_idx};

    % Search for text elements, extract 4 tokens (x-pos, y-pos, style, text-label)
    pattern1 = '<text.*x="([-0-9.]+)".*y="([-0-9.]+)".*style="(.*)".*>(.*)<\/text>';
    tokens = regexp(text_line, pattern1,'tokens'); %try to find Text label
    if ~isempty(tokens)
        FoundLabelText = tokens{1}{4};
        iLabel = getLabelIndex(FoundLabelText); % find label number
        if nnz(iLabel)
            alignment = Labels(iLabel).Alignment;
            anchor = Labels(iLabel).Anchor;
            idxText = ismember(Labels(iLabel).LabelText,FoundLabelText);
            newText = Labels(iLabel).XMLText{idxText};
        else
            alignment = 'start';
            anchor = 'start';
            newText = FoundLabelText;
        end
        
        % XOffset
        XOffset = str2double(tokens{1}{1});
        if strcmp(anchor,'auto')
            approxEnd = 4 + length(FoundLabelText) * Labels(iLabel).FontSize{:} * 0.4;
            approxCenter = length(FoundLabelText) * Labels(iLabel).FontSize{:} * 0.28;
            if XOffset == 0
                anchor = 'start';
            elseif abs(XOffset + approxCenter) < abs(XOffset + approxEnd)
                anchor = 'middle';
            else
                anchor = 'end';
            end
        end
        newXOffset = '0';
        
        % Create new Style
        newStyle = [tokens{1}{3},';text-anchor:',anchor,';']; % ';text-align:',alignment

        % Create new Offsets
        switch alignment
            case 'start'
                newYOffset = num2str(Labels(iLabel).FontSize{:}*1.12);
            case 'center'
                newYOffset = num2str(Labels(iLabel).FontSize{:}*0.44);
            case 'end'
                newYOffset = num2str(-Labels(iLabel).FontSize{:}*0.24);
            case 'auto'
                newYOffset = num2str(str2double(tokens{1}{2})*opts.yCorrFactor);
        end
        
        % Regular expression replace, everything in the parentheses won't be changed
        pattern2 = '(<text.*x=")[-0-9.]+(".*y=")[-0-9.]+(".*style=").*(".*>).*(<\/text>)';
        text_line = regexprep(text_line, pattern2, ['$1',newXOffset,'$2',newYOffset,'$3',newStyle,'$4',newText,'$5']);
        nFoundLabel = nFoundLabel +1;
    end

    % Search for white rectangles that build the background -> "delete" corresponding lines
    pattern3 = '<g.*style="fill:white;.*stroke:white;".*><rect.*x="0".*y="0".*</g>';
    text_line = regexprep(text_line, pattern3, '');
    
    fprintf(fout, '%s\n', text_line);
end
fclose(fout);
if nFoundLabel == 0
    warning(' - Plot2LaTeX.m: No text elements found and updated. Please check if no text is used or if the Renderer is "painters" and if there are any characters present that can''t be correctly printed to text.')
end
end

%% ------------------------------------------------------------------------
function text = checkForLegend(text, Labels, opts)
isLegend = arrayfun(@(x)strcmp(x.type,'Legend')&& x.mode == 1,Labels);

% getSVGSize:
pattern1 = '<rect x="0" width="([0-9]+)" height="([0-9]+)" y="0"';
[tokens] = regexp(text,pattern1,'tokens');
idx_Valid = find(cellfun(@(x) ~isempty(x),tokens),1);
height = str2double(tokens{idx_Valid}{1}{2});

for idx_is_legend = find(isLegend)
    labelsStr = strjoin(Labels(idx_is_legend).LabelText,'|');
    pattern2 = ['<text.*x="[-0-9.]+".*y="[-0-9.]+".*style=".*".*>(',labelsStr,')<\/text>'];
    
    % Search for the legend entries
    idxList = regexp(text,pattern2);
    idx_firstEntry = find(cellfun(@(x) ~isempty(x),idxList),1);
    idx_lastEntry = find(cellfun(@(x) ~isempty(x),idxList),1,'last');
    
    if isempty(idx_firstEntry) || isempty(idx_lastEntry)
        % warning(' - Plot2LaTeX.m: Legend element not found in the svg-file. No Text elements found!')
        continue
    end
    
    currLegendSize = Labels(idx_is_legend).Obj.Position;
    newLegendSize = Labels(idx_is_legend).Position;
    translateStr = sprintf('<g transform="translate(%f,0)">',newLegendSize(1)-currLegendSize(1) + (1-opts.legCorrFactor)*newLegendSize(3));
    
    legend_XPos = currLegendSize(1);
    legend_YPos = height - currLegendSize(2);
    legend_dim = newLegendSize(3:4);
    legend_dim(1) = legend_dim(1)*opts.legCorrFactor;
    newRectangleStr = sprintf('d="M%0.2f %0.2f L%0.2f %0.2f L%0.2f %0.2f L%0.2f %0.2f Z"',legend_XPos,legend_YPos,legend_XPos,legend_YPos-legend_dim(2),legend_XPos + legend_dim(1),legend_YPos-legend_dim(2),legend_XPos+legend_dim(1),legend_YPos);
    pattern3 = 'd="M[0-9]+ [0-9]+ L[0-9]+ [0-9]+ L[0-9]+ [0-9]+ L[0-9]+ [0-9]+ Z"';
    idxList = regexp(text,pattern3);
    idx_legend_background = find(cellfun(@(x) ~isempty(x),idxList(1:idx_firstEntry-1)),1,'last');
    idx_legend_trim = idx_lastEntry + find(cellfun(@(x) ~isempty(x),idxList(idx_lastEntry+1:end)),1,'first');
    
    text([idx_legend_background,idx_legend_trim]) = regexprep(text([idx_legend_background,idx_legend_trim]),pattern3,newRectangleStr);
    
    % Add Transform
    text{idx_legend_background} = [translateStr,' ',text{idx_legend_background}];
    pattern4 = '(<g style=.*?>)(.*)(<path .*?/>)(.*)</g>';
    text{idx_legend_trim} = regexprep(text{idx_legend_trim},pattern4,'$1$2$3</g></g>$1$4</g>');
end
end

%% ------------------------------------------------------------------------
function textCell = parseSVG(file)
% parseSVG(file, varargin)
% parseSVG(file, 'opt1', value1, ...)
%
% Loads a svg file and redos the parsing with new linebreaks.
% Every element gets its own line from start to finish. 

%% Options
opts.REGEXP_OpeningTag = '<[A-Za-z]+|<\?|<!--';
opts.REGEXP_ClosingTag = '<\/[A-Za-z:]+>|\?>|-->|\/>';
opts.REGEXP_ClosingTagWithSpace = '<\/[A-Za-z:]+ >';
opts.MAX_LENGTH = 1000;

%% Read SVG File
textRaw = readLines_noLineBreak([file, '.svg']); % compatible with v2020a and older

%% Fix closing Tags, that can have a whitespace inbetween
% e.g. "</text >" to "</text>"
[idx_errStart, idx_errEnd] = regexp(textRaw, opts.REGEXP_ClosingTagWithSpace);
cntFixed = length(idx_errEnd);
if ~isempty(idx_errStart)
    textRaw(arrayfun(@(x) idx_errEnd(x)-1, 1:cntFixed)) = '';
end


%% Find Opening and Closing Tags
openingTags = regexp(textRaw, opts.REGEXP_OpeningTag) - 1; % Get the last char that is not an openingTag
[~, closingTags] = regexp(textRaw, opts.REGEXP_ClosingTag); % Get the last char that is a closingTag


%% Init the Output
textCell = cell(length(closingTags),1);
line_idx = 1;

%% Parse text
TagList = [closingTags, openingTags];
TagValue = [-ones(length(closingTags), 1); ones(length(openingTags), 1)]; %-1: Closing, +1: Opening
[TagList, idxSort] = sort(TagList);
TagValue = TagValue(idxSort);

% find the right lineBreaks
idx_Tags = 1;
text_idx = 1;
while true
    idx_Tags_new = idx_Tags - 1 + find(cumsum(TagValue(idx_Tags:end)) <= 0, 1, 'first');
    if isempty(idx_Tags_new)
        idx_Tags_new = idx_Tags - 1 + find(TagList(idx_Tags:end)-text_idx+1 > opts.MAX_LENGTH, 1, 'first');
    end

    % Check for end
    if text_idx > TagList(end)
        if text_idx <= length(textRaw)
            printLine(text_idx, length(textRaw));
        end
        break;
    end


    % Check if line is too long
    len_text_add = TagList(idx_Tags_new) - text_idx + 1;
    if len_text_add > opts.MAX_LENGTH % Choose another tag to split
        idx_Tags_new = idx_Tags - 1 + find(TagList(idx_Tags:end)-text_idx+1 > opts.MAX_LENGTH, 1, 'first');
        len_text_add = TagList(idx_Tags_new) - text_idx + 1;
    end

    % Add new Line
    printLine(text_idx, TagList(idx_Tags_new));

    text_idx = text_idx + len_text_add;
    idx_Tags = idx_Tags_new + 1;
end

%% Remove empty cells
textCell(cellfun(@isempty, textCell)) = [];

    function printLine(idx_start, idx_end)
        idx_start_real = idx_start -1 + find(textRaw(idx_start:idx_end) ~= ' ',1,'first');
        if isempty(idx_start_real)
            idx_start_real = idx_start;
        end
        textCell{line_idx} = textRaw(idx_start_real:idx_end);
        line_idx = line_idx +1;
    end
end

%% ------------------------------------------------------------------------
function text = readLines_noLineBreak(file)
% text = readLines_noLineBreak(file)
% 
% Reads a file and creates a char with all lines in a row with whitespaces
% before and after linebreak removed

text = fileread(file);

text = regexprep(text,'\r\n|\r|\n',' '); % replaces line breaks with a single space
text = regexprep(text,'\s+',' '); % replaces multiple whitespaces with a single space

text(1:find(text ~= ' ',1,'first')-1) = ''; % Remove white spaces at the start
text(find(text ~= ' ',1,'last')+1:end) = ''; % Remove white spaces at the end
end

%% ------------------------------------------------------------------------
function [LabelElement,changed] = getShortName(LabelElement,mode,reset)

changed = false;
disallowedChars = '\\'; % Backslash-char cant be converted by matlab 

if nargin == 2
    reset = false;
end

persistent cellElement idx list idx2 list2
if isempty(cellElement) || reset
    cellElement = {0};
    idx = 1;
    list = {};
    idx2 = 1;
    list2 = {'.',';','''','^'};
end
if reset 
    return
end

names = LabelElement.TrueText;
dim = length(names);

text = cell(1,dim);
for i = 1:dim
    if ~isempty(regexp(names{i},disallowedChars, 'once'))
        names{i} = regexprep(names{i},disallowedChars,'.');
        changed = true;
    end
    switch mode
        case 0 % normal
            while ismember(names{i},list) % add a "."/","/...
                newElementAdded = false;
                for i2 = 1:length(list2)
                    if ~ismember([names{i},list2{i2}],list) % add a "."
                        names{i} = [names{i},list2{i2}];
                        newElementAdded = true;
                        changed = true;
                        break;
                    end
                end
                if ~newElementAdded
                    names{i} = [names{i},list2{idx2}];
                    idx2 = mod(idx2 +1,length(list2));
                    changed = true;
                end
            end
            text{i} = names{i};
        case 1 % shorten
            celllen = length(cellElement);
            if cellElement{idx} == 26 && idx == celllen % Add new Char
                idx = 1;
                cellElement = num2cell(ones(1, celllen+1));
            elseif cellElement{idx} == 26 % increment the char at postion idx
                idx = idx + 1;
                cellElement{idx} = cellElement{idx} + 1;
            else
                cellElement{idx} = cellElement{idx} + 1;
            end

            elements = cell2mat(cellElement) - 1;
            text{i} = char(char('a')+elements);
            changed = true;
        case 2 % add length to the end
            text{i} = [names{i},'..'];
            changed = true;
        case 3 % Axis with an Exponent 
            suffix = '';
            origFormat = LabelElement.Obj.TickLabelFormat;
            doChange = any(ismember(LabelElement.Obj.TickLabels, list));
            while doChange
                suffix = [suffix, '.']; %#ok<AGROW>
                LabelElement.Obj.TickLabelFormat = [origFormat, suffix];
                doChange = any(ismember(LabelElement.Obj.TickLabels, list));
            end
            text = erv(LabelElement.Obj.TickLabels);
            break
    end
end
LabelElement.LabelText = text;
list = [list,text];
end

%% ------------------------------------------------------------------------
function ChangeInterpreter(h, Interpreter)
% CHANGEINTERPRETER puts interpeters in figure h to Interpreter

if ~isempty(Interpreter)
    TexObj = findall(h, 'Type', 'Text');
    LegObj = findall(h, 'Type', 'Legend');
    AxeObj = findall(h, 'Type', 'Axes');
    ColObj = findall(h, 'Type', 'Colorbar');
    ConLiObj = findall(h, 'Type', 'ConstantLine');

    Obj = [TexObj; LegObj; ConLiObj]; % Tex and Legend opbjects can be treated similar

    n_Obj = length(Obj);
    for i = 1:n_Obj
        Obj(i).Interpreter = Interpreter;
    end

    Obj = [AxeObj; ColObj]; % Axes and colorbar opbjects can be treated similar

    n_Obj = length(Obj);
    for i = 1:n_Obj
        Obj(i).TickLabelInterpreter = Interpreter;
    end
end
end

%% ------------------------------------------------------------------------
function text = Text2LaTeX(Label, opts)
% Text2LaTeX repaces special characters(<,>,',",&) -> (&lt;,&gt;,&apos;,&quot;,&amp;)
dim = length(Label.TrueText);
text = cell(1,dim);
for idx = 1:dim
    if ~isempty(opts.ReplaceList) && ismember(opts.ReplaceList(:,1),Label.TrueText{idx})
        Label.TrueText{idx} = opts.ReplaceList{find(ismember(opts.ReplaceList(:,1),Label.TrueText{idx}),1),2};
    end
    escChar = {'&', '<', '>', '''', '"'};
    repChar = {'&amp;', '&lt;', '&gt;', '&apos;', '&quot;'};
    text{idx} = regexprep(Label.TrueText{idx}, escChar, repChar);
    color = [Label.Color{:}];
    if ~isempty(Label.Color) && any(color ~= [0,0,0]) && any(color ~= 0.15)
        text{idx} = ['{\definecolor{col}{rgb}{',num2str(color(1)),',',num2str(color(2)),',',num2str(color(3)),'} \color{col}',text{idx},'}'];
    end
    if strcmp(opts.FontSizeMode,'fixed') && ~isempty(opts.FontSize) && ~isempty(Label.FontSize) && opts.FontSize ~= Label.FontSize{1}
        text{idx} = ['{\fontsize{',num2str(Label.FontSize{1}),'}{',num2str(Label.FontSize{1}*1.2),'}\selectfont ',text{idx},'}'];
    end
    text{idx} = regexprep(text{idx},'\\','\\\\');
end
end

%% ------------------------------------------------------------------------
function fig = copy_Figure(fig_orig)
% this program copies a figure

Name = 'Plot2LaTeX';
fig = figure('Name',Name);
ax_children = fig_orig.Children;
copyobj(ax_children,fig)

properties = {'Units','position','Color','Colormap','Alphamap'};
set(fig, properties, get(fig_orig, properties)); 
end

%% ------------------------------------------------------------------------
function options = checkOptions(options, inputArgs, doWarning)
% options = checkOptions(options, inputArgs, doWarning)
%
% options: struct with valid fields
% inputargs: a cell of inputs -> varargin of a higher function or a cell of a struct
% doWarning: true (default), false

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

    [isValid, validEntry] = isValidEntry(validEntries, entry, fcnName, doWarning);
    if ischar(entry) && isValid
        options.(validEntry) = inputArgs{ii+1};

    elseif isstruct(entry)
        fieldNames = fieldnames(entry);
        for idx = 1:length(fieldNames)
            subentry = fieldNames{idx};
            isval = isValidEntry(validEntries, subentry, fcnName, doWarning);
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
function [bool, validEntry] = isValidEntry(validEntries, input, fcnName, doWarning)
% allow input of an options structure that overwrites existing fieldnames with its own, for increased flexibility
bool = false;
validEntry = '';
valIdx = strcmp(input, validEntries); % Check case sensitive

if nnz(valIdx) == 0 && ~isstruct(input) && ischar(input)
    valIdx = strcmpi(input, validEntries); % Check case insensitive
end

if nnz(valIdx) == 0 && ~isstruct(input) && ischar(input)
    valIdx = contains(validEntries, input, 'IgnoreCase', true); % Check case insensitive
end

if nnz(valIdx) > 1 && doWarning
    strings = [validEntries(1); strcat(',', validEntries(2:end))]; % removes ' ' at the end when concatenating
    longString = [strings{:}];
    longString = strrep(longString, ',', ', ');
    error(['-', fcnName, '.m: Option "', input, '" not correct. Allowed options are [', longString, '].'])
elseif nnz(valIdx) > 0 % All else options
    validEntry = validEntries{valIdx};
    bool = true;
elseif doWarning && ~isstruct(input) && ischar(input)
    strings = [validEntries(1); strcat(',', validEntries(2:end))]; % removes ' ' at the end when concatenating
    longString = [strings{:}];
    longString = strrep(longString, ',', ', ');
    warning(['-', fcnName, '.m: Option "', input, '" not found. Allowed options are [', longString, '].'])
end
end

%% ------------------------------------------------------------------------
function isValid = check_Inkscape_Dir(inkscape_path)
% isValid = CHECK_INKSCAPE_DIR(path) checks if the path to inkscape is
% correct
[status, result] = system(['"', inkscape_path, '" --version']);
isValid = contains(result, 'Inkscape') && status == 0;
if status ~= 0 && status ~= 1
    warning([' - check_Inkscape_Dir.m: system(''', inkscape_path, ' --help'') was not successful. System response was ', num2str(status), '.'])
end
end

%% ------------------------------------------------------------------------
function [isAboveV1, version] = check_Inkscape_Version(inkscape_path)
% isValid = CHECK_INKSCAPE_VERSION(path) checks if inkscape is
% in version 1 or above
[status, result] = system(['"', inkscape_path, '" --version']);
[reg_idx, reg_idx_end] = regexp(result, 'Inkscape [0-9.]+', 'ONCE');
isValid = ~isempty(reg_idx) && status == 0;

if isValid
    version = result(reg_idx+length('Inkscape '):reg_idx_end);
    [reg_idx, reg_idx_end] = regexp(version, '[0-9]+', 'ONCE');
    isAboveV1 = num2str(version(reg_idx:reg_idx_end)) >= 1;
else
    version = '';
    isAboveV1 = false;
    warning([' - check_Inkscape_Version.m: system(''', inkscape_path, ' --version'') was not successful. System response was ', num2str(status), '.'])
end
end

%% ------------------------------------------------------------------------
function dataOut = erv( data )
dataOut = reshape(data, [1 numel(data)]);
end

% Change log (end of File):
% v 1.1 - 02/09/2015 (not released)
%   - Made compatible for Unix systems
%   - Added a waitbar
%   - Corrected the help file
% v 1.2 - 20/04/2016
%   - Fixed file names with spaces in the name.
%     (Not adviced to use in latex though)
%   - Escape special characters in XML (<,>,',",&)
%     -> (&lt;,&gt;,&apos;,&quot;,&amp;)
% v 1.3 - 10/02/2022
%   - figure copy
%   - check Inkscape dir
%   - options as varargin or struct
%   - waitbar optional
%   - export to pdf optional
%   - works with inkscape v1
% v 1.4 - 18/03/2022
%   - string as input allowed
%   - closes the file, if the programm could not finish
%   - inkscape path with white spaces allowed
% v 1.5 - 21/03/2022
%   - 2 options (Interpreter, useOrigFigure) added
%   - fixed a bug, that only one subplot was copied
%   - Constant Line objects added
% v 1.6 - 21/03/2022
%   - exponential exponents on axis added
%   - not supported text-elements don't stop svg-export
% v 1.7 - 13/09/2022
%   - fixed a bug in colorbar
%   - legend size is fixed based on initial position
%   - added an option for fontSize
% v 1.8 - 22/09/2022
%   - changed 'doExportPDF' to 'OnlySVG'
%   - added an option for Inkscape Export Mode
% v 1.9 - 13/10/2022
%   - manually positioned legends fixed
%   - fixed a typo in line 569
%   - replaceList added
%   - FontSize 'auto' added
%   - option 'waitbar' to 'Verbose' changed
% v 1.10 - 13/01/2023
%   - Removes the white background of a figure, thanks to M.Zimmer
% v 2.00 - 27/05/2023
%   - Full Overhaul, speed up of up to 50%
%   - yline (horizontal position) fixed 
%   - Color Text and different fontSizes ('fixed' new option) now possible
%   - Fixed the export of figures that had previously the warning "No text
%     elements found."
%   - Speed up of copy_figure.m
% v 2.1 - 01/06/2023
%   - fixed a bug with opts.replaceList