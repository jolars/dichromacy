# Commands {#sec-commands}

The `cvd` package provides several commands to control the CVD simulation at any point in your document. These commands allow you to enable, disable, and configure the simulation dynamically.

## Simulation Control

### Enable/Disable Simulation

| Command | Description |
|---------|-------------|
| `\cvdenable` | Enable color vision deficiency simulation |
| `\cvddisable` | Disable color vision deficiency simulation |

When you disable the simulation using `\cvddisable`, the type and severity settings are stored in the background. A subsequent `\cvdenable` restores the original CVD simulation behavior.

```latex
\cvdenable   % Turn on CVD simulation
...          % Content with CVD applied
\cvddisable  % Turn off CVD simulation
...          % Content without CVD
\cvdenable   % Turn on CVD simulation again (restores previous settings)
```

## Configuration Commands

### Set CVD Type

```latex
\cvdtype{<type>}
```

Sets the type of color-vision deficiency. Possible values are:
- `protanopia` — red-blind
- `deuteranopia` — green-blind
- `tritanopia` — blue-blind

Example:
```latex
\cvdtype{deuteranopia}
```

### Set Severity

```latex
\cvdseverity{<value>}
```

Sets the severity level on a scale from 0 to 1.
- `1` means maximum severity (full colorblindness of the given type)
- `0` means completely normal vision

Example:
```latex
\cvdseverity{0.5}  % 50% severity
```

### Set Multiple Options

```latex
\cvdset{<options>}
```

Set one or more CVD options at once using key-value syntax. All options available at package load time can be used here.

Example:
```latex
\cvdset{type=protanopia, severity=0.8, graphics hook=true}
```

## Image Commands

### Include Raster Image with CVD

```latex
\cvdincludegraphics[<options>]{<path>}
```

Include a raster image (PNG/JPG) with CVD transformation applied.

This macro behaves identically to `\includegraphics` when CVD simulation is enabled. However, when CVD simulation is disabled, this macro can be used to apply the CVD transformation to a single raster image.

**Note:** This macro has no effect for PDF images; PDF images are transformed according to the current state of the CVD simulation via the `graphics hook` option.

Example:
```latex
\cvdincludegraphics[width=0.5\textwidth]{example.png}
```

## Color Commands

### Define CVD Color

```latex
\cvddefinecolor[<options>]{<source color>}{<target color>}
```

Define a new color named `<target color>` by applying the current CVD transformation to the existing color `<source color>`.

The optional `<options>` argument can be used to override the current CVD settings (e.g., `type`, `severity`) for this specific color definition, using the same syntax as `\cvdset`.

This is particularly useful for creating pre-computed CVD colors that can be used consistently throughout your document, especially with shadings and gradients (see @sec-shadings).

Example:
```latex
% Define a color that appears as blue would to someone with protanopia
\cvddefinecolor[protanopia, severity=0.5]{blue}{blue-cvd}

% Use the pre-computed color
\textcolor{blue-cvd}{This text uses the CVD-transformed blue color}
```

Example with multiple CVD variants:
```latex
\cvddefinecolor[protanopia]{red}{red-p}
\cvddefinecolor[deuteranopia]{red}{red-d}
\cvddefinecolor[tritanopia]{red}{red-t}
```

## Complete Example

```latex
\documentclass{article}
\usepackage{xcolor}
\usepackage{cvd}

\begin{document}

% Start with normal vision
\cvddisable
Normal vision: \textcolor{red}{Red text} \textcolor{green}{Green text}

% Enable deuteranopia simulation
\cvdenable
\cvdtype{deuteranopia}
\cvdseverity{1.0}
\bigskip

Deuteranopia (severity 1.0): \textcolor{red}{Red text} \textcolor{green}{Green text}

% Try a different type
\cvdtype{protanopia}
\cvdseverity{0.5}
\bigskip

Protanopia (severity 0.5): \textcolor{red}{Red text} \textcolor{green}{Green text}

% Define and use pre-computed colors
\cvddisable
\cvddefinecolor[protanopia]{red}{red-p}
\cvddefinecolor[protanopia]{green}{green-p}
\bigskip

Pre-computed protanopia colors: \textcolor{red-p}{Red (as protanope)} \textcolor{green-p}{Green (as protanope)}

\end{document}
```
