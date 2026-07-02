# Examples

This page provides practical examples demonstrating various use cases for the `cvd` package.

## Basic Usage

### Quick Check for Deuteranopia

The simplest way to check your document for the most common form of color blindness:

```latex
\documentclass{article}
\usepackage[deuteranopia]{cvd}
\usepackage{xcolor}

\begin{document}

This document simulates deuteranopia (green-blind) color vision.

\textcolor{red}{Red text} \textcolor{green}{Green text} \textcolor{blue}{Blue text}

\end{document}
```

### Comparing Multiple CVD Types

Create a comparison document showing how colors appear with different CVD types:

```latex
\documentclass{article}
\usepackage{cvd}
\usepackage{xcolor}

\begin{document}

\section{Normal Vision}
\cvddisable
\textcolor{red}{Red} \textcolor{green}{Green} \textcolor{blue}{Blue}

\section{Protanopia (Red-blind)}
\cvdenable
\cvdtype{protanopia}
\cvdseverity{1.0}
\textcolor{red}{Red} \textcolor{green}{Green} \textcolor{blue}{Blue}

\section{Deuteranopia (Green-blind)}
\cvdtype{deuteranopia}
\cvdseverity{1.0}
\textcolor{red}{Red} \textcolor{green}{Green} \textcolor{blue}{Blue}

\section{Tritanopia (Blue-blind)}
\cvdtype{tritanopia}
\cvdseverity{1.0}
\textcolor{red}{Red} \textcolor{green}{Green} \textcolor{blue}{Blue}

\end{document}
```

## Scientific Papers and Charts

### Color-Coded Data

When presenting color-coded data, check that your color scheme is accessible:

```latex
\documentclass{article}
\usepackage{pgfplots}
\usepackage[deuteranopia]{cvd}
\pgfplotsset{compat=1.18}

\begin{document}

\begin{tikzpicture}
\begin{axis}[xlabel=X, ylabel=Y]
  \addplot[red, mark=*] coordinates {(0,0) (1,1) (2,2)};
  \addplot[green, mark=square*] coordinates {(0,1) (1,0) (2,1)};
  \addplot[blue, mark=triangle*] coordinates {(0,2) (1,1) (2,0)};
\end{axis}
\end{tikzpicture}

\end{document}
```

If the colors become hard to distinguish, consider changing them until they can also be distinguished under the CVD simulation.

### Multiple Charts with Different CVD Types

```latex
\documentclass{article}
\usepackage{pgfplots}
\usepackage{cvd}
\pgfplotsset{compat=1.18}

\begin{document}

% Define CVD-transformed colors for each type
\cvddefinecolor[type=protanopia]{red}{red-p}
\cvddefinecolor[type=protanopia]{green}{green-p}
\cvddefinecolor[type=protanopia]{blue}{blue-p}

\cvddefinecolor[type=deuteranopia]{red}{red-d}
\cvddefinecolor[type=deuteranopia]{green}{green-d}
\cvddefinecolor[type=deuteranopia]{blue}{blue-d}

\begin{tikzpicture}
\begin{axis}[xlabel=X, ylabel=Y, title=Protanopia]
  \addplot[red-p, mark=*] coordinates {(0,0) (1,1) (2,2)};
  \addplot[green-p, mark=square*] coordinates {(0,1) (1,0) (2,1)};
\end{axis}
\end{tikzpicture}

\begin{tikzpicture}
\begin{axis}[xlabel=X, ylabel=Y, title=Deuteranopia]
  \addplot[red-d, mark=*] coordinates {(0,0) (1,1) (2,2)};
  \addplot[green-d, mark=square*] coordinates {(0,1) (1,0) (2,1)};
\end{axis}
\end{tikzpicture}

\end{document}
```

## Maps and Color-Coded Regions

### Simple Color-Coded Map

```latex
\documentclass{article}
\usepackage{tikz}
\usepackage[deuteranomaly]{cvd}

\begin{document}

\begin{tikzpicture}
  % Draw a simple map with color-coded regions
  \fill[red!30] (0,0) rectangle (2,2);
  \fill[green!30] (2,0) rectangle (4,2);
  \fill[blue!30] (4,0) rectangle (6,2);
  
  \node at (1,1) {Region A};
  \node at (3,1) {Region B};
  \node at (5,1) {Region C};
\end{tikzpicture}

\end{document}
```

## Shadings and Gradients

### Basic Gradient with CVD

```latex
\documentclass{article}
\usepackage{tikz}
\usepackage[deuteranopia]{cvd}

\begin{document}

\begin{tikzpicture}
  % This gradient will be transformed with deuteranopia
  \shade[left color=red, right color=blue] (0,0) rectangle (6,2);
  \node at (3,1) {Deuteranopia Gradient};
\end{tikzpicture}

\end{document}
```

### Multiple Gradients with Different CVD Types

See @sec-shadings for detailed examples on handling shadings with different CVD types, including the caching workaround.

## Raster Images

### Transforming a Photo

```latex
\documentclass{article}
\usepackage[graphics convert=true]{cvd}
\cvdtype{protanopia}

\begin{document}

% Requires --shell-escape and ImageMagick
\includegraphics[width=\textwidth]{my-photo.jpg}

\end{document}
```

Compile with:
```bash
lualatex --shell-escape mydocument.tex
```

### Transforming Specific Images Only

```latex
\documentclass{article}
\usepackage[protanopia, graphics convert=false]{cvd}
% CVD simulation is disabled globally

\begin{document}

% This image is NOT transformed
\includegraphics[width=0.5\textwidth]{normal-image.png}

% This specific image IS transformed using \cvdincludegraphics
\cvdincludegraphics[width=0.5\textwidth]{cvd-image.png}

\end{document}
```
