# Dichromacy <a href="https://jolars.github.io/dichromacy"><img src="https://github.com/jolars/dichromacy/raw/main/images/logo.png" align="right" width="140" /></a>

Dichromacy is a LaTeX package for simulating color vision deficiency.

## Installation

The package is not yet on CTAN, so you need to install it from source. Assuming
you have [l3build](https://https://github.com/latex3/l3build) installed as well
as an up-to-date LaTeX distribution, you can install dichromacy by running:

```bash
git clone https://github.com/jolars/dichromacy.git
cd dichromacy
l3build install
```

## Usage

Dichromacy requires LuaTeX to work and currently supports

- any colors defined with `\textcolor`, `\colorbox`, `\fcolorbox`, etc.
- PDF images included with `\includegraphics`

## Raster Images

Raster images are optionally supported via a custom script, but this requires
compiling LuaTeX with the `--shell-escape` flag enabled.

## Usage

```latex
%! TEX program = luatex
\documentclass{article}
\usepackage{graphicx}

\usepackage{dichromacy}

\cvdtype{deuteranopia}
\cvdseverity{0.9}

\begin{document}

\subsection{Basic Colors}

\textcolor{red}{Red text} and \textcolor{green}{green text} and \textcolor{blue}{blue text} and \textcolor{cyan}{cyan text} and \textcolor{magenta}{magenta text} and \textcolor{yellow}{yellow text}.

\subsection{Color Boxes}

\fcolorbox{black}{red}{\color{white} Red Box}
\fcolorbox{black}{green}{\color{white} Green Box}
\fcolorbox{black}{blue}{\color{white} Blue Box}
\fcolorbox{black}{cyan}{\color{white} Cyan Box}
\fcolorbox{black}{magenta}{\color{white} Magenta Box}
\fcolorbox{black}{yellow}{\color{white} Yellow Box}

\subsection{Custom RGB Colors}

\definecolor{myred}{rgb}{0.8, 0.1, 0.1}
\definecolor{mygreen}{rgb}{0.1, 0.8, 0.1}
\definecolor{myblue}{rgb}{0.1, 0.1, 0.8}

\textcolor{myred}{Custom red}, \textcolor{mygreen}{custom green}, \textcolor{myblue}{custom blue}.

\subsection{Custom CMYK Colors}

\definecolor{mycyan}{cmyk}{0.8, 0.1, 0.1, 1}
\definecolor{mymagenta}{cmyk}{0.1, 0.8, 0.1, 1}
\definecolor{myyellow}{cmyk}{0.1, 0.1, 0.8, 1}

\textcolor{mycyan}{Custom cyan}, \textcolor{mymagenta}{custom magenta}, \textcolor{myyellow}{custom yellow}.

\subsection{Severity Test}

Normal text in black.

\cvdseverity{0.5}
\textcolor{red}{Red at 50\% severity} and \textcolor{green}{green at 50\% severity}.

\cvdseverity{1.0}
\textcolor{red}{Red at 100\% severity} and \textcolor{green}{green at 100\% severity}.

\subsection{Disable/Enable}

\cvddisable
CVD disabled - \textcolor{red}{normal red} and \textcolor{green}{normal green}.

\cvdenable
CVD enabled - \textcolor{red}{simulated red} and \textcolor{green}{simulated green}.

\cvdseverity{0.85}
\cvdtype{protanopia}

\cvdincludegraphics{test-image.pdf}

\end{document}
```

## Contributing

Contributions are welcome!

Also, when writing commit messages, please use the [conventional commits
format](https://www.conventionalcommits.org/en/v1.0.0/).

## Versioning

The project uses [semantic versioning](https://semver.org).
