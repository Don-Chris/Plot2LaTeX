# Plot2LaTeX
Fork of Plot2LaTex.m by Jan de Jong 

**Original files**: https://www.mathworks.com/matlabcentral/fileexchange/52700-plot2latex

**Creator**: Jan de Jong https://www.mathworks.com/matlabcentral/profile/authors/4045895

Tested with Matlab 2016b
on Microsoft Windows
and Inkscape v1.1.1

[![View Plot2LaTeX on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://de.mathworks.com/matlabcentral/fileexchange/108554-plot2latex)

# Overview
**PLOT2LATEX** saves matlab figure as a pdf file in vector format for inclusion into LaTeX. Requires free and open-source vector graphics editor Inkscape. This allows links of varible names to be placed within the axis or legend and so on, or variables can be subsequently renamed without having to recreate the Matlab plot.

# Options
**PLOT2LATEX(h, filename, 'option1', value, 'option2', value, ...)** or **PLOT2LATEX(h, filename, options_struct)** saves figure with specified options. 
- 'Renderer':'painters' (default), 'opengl', ''(no change)
- 'yCorrFactor': 0.8 (default, in px)
- 'legCorrFactor': 1.02 (default in Percent): Option for manually correct the horizontal size of a (vertical) legend.
- 'DIR_INKSCAPE': directory to inkscape.exe
- 'Verbose': 'console' (default), 'waitbar', 'both', boolean: Should a waitbar appear to show progress or a console text
- 'useOrigFigure': false (default): Use the original figure or create a copy?
- 'OnlySVG': false (default): Option to stop after creating the svg file. Can be used, if the plots are used as svg files or if inkscape is not installed.
- 'Interpreter': 'tex' (default), 'latex','none': Changes the matlab text interpreter
- 'FontSize': auto (default), '', 'fixed', 14 (in pt): Should be equal to the font size inside of the document, use '' if the font size should not be changed before hand.
- 'ReplaceList': '' (default), a cell with 2 columns, first column: text in figure, second column: new text in .svg: Should a placeholder text in the figure be  replaced with a LaTeX command that e.g. matlab can't correctly display? example : {'placeholder','\acr{thickness}'; 'placeholder2','$\exp{-4r^2}$'}
- 'Inkscape_Export_Mode': 'export-area-page' (default), 'export-area', 'export-area-drawing', 'export-use-hints': inkscape export options, see wiki.inkscape.org

# Example function calls:
- **PLOT2LATEX(gcf, 'FirstPlot')**
- **PLOT2LATEX(gcf, 'FirstPlot', 'Verbose', false)**
- **PLOT2LATEX(gcf, 'FirstPlot', 'doExportPDF', false, 'FontSize', '')**

# Info
**PLOT2LATEX(h, filename)** saves figure with handle h to a file specified by filename, without extention. Filename can contain a a full path or a name (e.g. 'C:\images\title', 'title') to save the figure to a different location. 

**PLOT2LATEX** requires a installation of **Inkscape**. The program's location can be 'hard coded' into this matlab file if 'inkscape' is not a valid command for the command window. Please specify your inscape file location by modifying opts.DIR_INKSCAPE variable on the first line of the actual code or specify the location of inkscape.exe on the first run. 

**PLOT2LATEX** saves the figures to .svg format. It invokes Inkscape to save the svg to a .pdf and .pdf_tex file to be incorporated into LaTeX document using \begin{figure} \input{image.pdf_tex} \end{figure}.  More information on the svg to pdf conversion can be found here: 
[ftp://ftp.fu-berlin.de/tex/CTAN/info/svg-inkscape/InkscapePDFLaTeX.pdf](ftp://ftp.fu-berlin.de/tex/CTAN/info/svg-inkscape/InkscapePDFLaTeX.pdf)

**PLOT2LATEX** produces three files: .svg, .pdf, .pfd_tex. The .svg-file contains vector image. The .pdf-file contains figure without the text. The .pdf_tex-file contains the text including locations and other type setting.

The produced .svg file can be manually modified in Inkscape and included into the .tex file using the using the built-in "save to pdf"  functionality of Inkscape.

**PLOT2LATEX** saves the figure to a svg and pdf file with approximately the same width and height. Specify the Font size and size within Matlab for correct conversion.

The y-offset of all text can be modified using yCorrFactor. The default is 'yCorrFactor' = 0.8. The units are px. With options.Renderer the renderer of the figure can be specified: ('opengl', 'painters').

# Workflow of the code
1. Matlab renames duplicate strings of the figure. The strings are stored to be used later. To prevent a change in texbox size, duplicate  labels get "." at the end of the label.
2. Matlab saves the figure with modified labels to a svg file.
3. Matlab opens the svg file and restores the labels with the original string
4. Matlab invokes Inkscape to save the svg file to a pdf + pdf_tex file.
5. The pdf_tex is to be included into LaTeX. Instruction can be found inside the pdf_tex file.

# Features:
- [x] Complex figures such as plotyy, logarithmic scales.
- [x] It parses LaTeX code, even if it is not supported by Matlab LaTeX.
- [x] Supports real transparency.
- [x] SVG is a better supported, maintained and editable format than eps
- [x] SVG allows simple manual modification into Inkscape.
- [x] PLOT2LATEX sets all text to the same size, based on the median of all text sizes present with option "fontSize"="auto". Use "FontSize"="fixed" for variing text sizes in LaTeX.

# Limitations:
- [ ] Text resize is still done in PLOT2LATEX. The LaTeX fonts in matlab do not correspond completely with the LaTeX font size.
- [ ] Legend size is not always correct, use placeholder text elements that will be replaced based on the replaceList-option. Works with latex-functions that can't be compiled by matlab.
- [ ] Text boxes with LaTeX code which is not interpretable by matlab results in too long text boxes. Use the replaceList-option.
- [ ] Very large figures sometimes result in very large waiting times.
- [ ] Older versions than matlab 2014b are not supported.
- [ ] PLOT2LATEX currently does not work with titles consisting of multiple lines.


# Trouble shooting
- For Unix users: use the installation folder such as:
'/Applications/Inkscape.app/Contents/Resources/script ' as location. 
- For Unix users: For some users the bash profiles do not allow to call 
Inkscape in Matlab via bash. Therefore change the bash profile in Matlab 
to something similar as setenv('DYLD_LIBRARY_PATH','/usr/local/bin/').
The bash profile location can be found by using '/usr/bin/env bash'

# To do:
- [ ] Allow multiple line text
- [ ] Speed up code by smarter string replacement of SVG file
- [ ] Resize of legend box using: [h,icons,plots,str] = legend(); (not so simple)
- [ ] Size difference .svg and .fig if specifying units other than px. (Matlab limitation?)
