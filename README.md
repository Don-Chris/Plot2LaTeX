# Plot2LaTeX

Fork of Plot2LaTex.m by Jan de Jong. This fork adds the following features:

- [x] Support for newer versions of Matlab
- [x] Support for Inkscape v1.*
- [x] Support for multiple line text
- [x] Support for legend box resizing
- [x] Support for colored text
- [x] Additional options like removal of white background


**Original files**: https://www.mathworks.com/matlabcentral/fileexchange/52700-plot2latex

**Creator**: Jan de Jong https://www.mathworks.com/matlabcentral/profile/authors/4045895

Tested with Matlab 2016b-2020b on Microsoft Windows and Inkscape v1.*.

[![View Plot2LaTeX on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://de.mathworks.com/matlabcentral/fileexchange/108554-plot2latex)

## Overview

**PLOT2LATEX** saves matlab figure as a PDF file in vector format for inclusion into LaTeX. Requires free and open-source vector graphics editor Inkscape. This allows links of varible names to be placed within the axis or legend and so on, or variables can be subsequently renamed without having to recreate the Matlab plot.

## Options

**`PLOT2LATEX(h, filename, 'option1', value, 'option2', value, ...)`** or **`PLOT2LATEX(h, filename, options_struct)`** saves figure with specified options as name value pairs or with an options-struct with a subset of the following fieldnames:

| Option | Value | Discription |
| --- | --- | --- |
| `'Renderer'` | 'painters' (default), 'opengl', '' (no change)| Renderer of the figure. Only change if you know what you are doing.|
| `'yCorrFactor'`| 0 (default, in px)| Offset of most text elements in y-direction.|
| `'legendPadding'`| [1,1,1,1] (default, in pt)| Option for manually add padding to the legends [top, bottom, left, right], only works for legends with vertical orientation.|
| `'DIR_INKSCAPE'`| 'inkscape' (default), 'C:\Program Files\Inkscape\Inkscape.exe', ... |Path to inkscape.exe|
| `'Verbose'`| 'console' (default), 'waitbar', 'both'| Should a waitbar appear to show progress or a console text|
| `'useOrigFigure'`| false (default)| Use the original figure or create a copy?|
| `'OnlySVG'`| false (default)| Option to stop after creating the SVG file. Can be used, if the plots are used as SVG files with the package SVG in LaTeX or if inkscape is not installed.|
| `'Interpreter'`| '' (default), 'latex', 'none', tex'| Changes the matlab text interpreter, if empty no change is made.|
| `'FontSize'`| 'auto' (default), ' ' (do nothing), 'fixed', 14 (in pt)|Should be equal to the font size inside the document, use '' if the font size should not be changed beforehand. 'fixed': all font sizes will be preset with \fontsize in latex. 'auto': the prevalent fontsize will be found and all text elements will be changed to this fontsize.|
| `'ReplaceList'`| '' (default), a cell with 2 columns|first column: text in figure, second column: new text in .svg: Should a placeholder text in the figure be replaced with a LaTeX command that e.g. matlab can't correctly display? Example : {'placeholder','\acr{thickness}'; 'placeholder2','$\exp{-4r^2}$'}|
| `'SquishedText'`| false (default)| Option to horizontal squish all text elements in the svg-file, so that the export mode of inkscape works better with commands that go outside the drawing area.|
| `'Inkscape_Export_Mode'`| 'export-area-page' (default), 'export-area-drawing'| inkscape export options, see wiki.inkscape.org|
| `'RemoveWhiteBackground'`| true (default)| Should the white background of the figure be removed from the SVG file?|

## Example function calls

- **`PLOT2LATEX(gcf, 'FirstPlot')`**
- **`PLOT2LATEX(gcf, 'FirstPlot', 'Verbose', false)`**
- **`PLOT2LATEX(gcf, 'FirstPlot', 'doExportPDF', false, 'FontSize', '')`**

## Info

**`Plot2LaTeX(h, filename)`** saves figure with handle h to a file specified by filename, without extention. Filename can contain a full path or a name (e.g. 'C:\images\title', 'title') to save the figure to a different location other than the current folder.

**PLOT2LATEX** requires an installation of **Inkscape**. The program's location can be 'hard coded' into this matlab file if 'inkscape' is not a valid command for the command window. Please specify your inscape file location by modifying opts.DIR_INKSCAPE variable on the first line of the actual code or specify the location of inkscape.exe on the first run.

**PLOT2LATEX** saves the figures to SVG format. It invokes Inkscape to save the SVG to a PDF and PDF_TEX file to be incorporated into LaTeX document using \begin{figure} \input{image.pdf_tex} \end{figure}.  More information on the SVG to PDF conversion can be found here:
[ftp://ftp.fu-berlin.de/tex/CTAN/info/svg-inkscape/InkscapePDFLaTeX.pdf](ftp://ftp.fu-berlin.de/tex/CTAN/info/svg-inkscape/InkscapePDFLaTeX.pdf)

**PLOT2LATEX** produces three files: SVG, PDF and PDF_TEX. The SVG-file contains thw vector image. The PDF-file contains the figure without the text. The PDF_TEX-file contains the text including locations and other type setting.

The produced SVG file can be manually modified in Inkscape and included into the .tex file using the built-in 'save to PDF' functionality of Inkscape.

**PLOT2LATEX** saves the figure to a SVG and PDF file with approximately the same width and height. Specify the Font size and size within Matlab for correct conversion.

## Workflow of the code

1. Matlab renames duplicate strings of the figure. The strings are stored to be used later. To prevent a change in texbox size, duplicate labels get '.' at the end of the label.
2. Matlab saves the Figure with modified labels to a SVG file.
3. Matlab opens the SVG file and restores the labels with the original string
4. Matlab invokes Inkscape to save the SVG file to a PDF + PDF_TEX file.
5. The pdf_tex is to be included into LaTeX. Instruction can be found inside the PDF_TEX file.

## Features

- [x] Complex figures such as plotyy, logarithmic scales.
- [x] It parses LaTeX code, even if it is not supported by Matlab LaTeX.
- [x] support real transparency.
- [x] SVG is a better supported, maintained and editable format than eps
- [x] SVG allows simple manual modification into Inkscape.
- [x] PLOT2LATEX sets all text to the same size, based on the median of all text sizes present with option 'fontSize'='auto'. Use 'FontSize'='fixed' for variing text sizes in LaTeX.

## Limitations

- [ ] Text resize is still done in PLOT2LATEX. The LaTeX fonts in matlab do not correspond completely with the LaTeX font size.
- [ ] Legend size is not always correct, use placeholder text elements that will be replaced based on the replaceList-option. Works with latex-functions that can't be compiled by matlab.
- [ ] Text boxes with LaTeX code which is not interpretable by matlab results in too long text boxes. Use the replaceList-option.
- [ ] Very large figures sometimes result in very large waiting times.
- [ ] Older versions than matlab 2014b are not supported.

## Troubleshooting

- For Unix users: use the installation folder such as:
'/Applications/Inkscape.app/Contents/Resources/script' as location.
- For Unix users: For some users the bash profiles do not allow to call Inkscape in Matlab via bash. Therefore, change the bash profile in Matlab to something similar as setenv('DYLD_LIBRARY_PATH','/usr/local/bin/').
The bash profile location can be found by using '/usr/bin/env bash'

## To do

- [ ] Allow multiple line text
- [ ] Resize of legend box using: [h,icons,plots,str] = legend(); (not so simple)
- [ ] Size difference .svg and .fig if specifying units other than px. (Matlab limitation?)
