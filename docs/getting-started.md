# Getting Started

The `cvd` package helps you create colorblind-safe LaTeX documents by simulating various types of color vision deficiency (CVD). This allows you to check whether your color choices are accessible to readers with different kinds and severities of CVDs without needing to consult someone affected by color blindness.

## Quick Start

To quickly check your document for deuteranopia (the most common form of color blindness), simply load the package like this:

```latex
\usepackage[deuteranopia]{cvd}
```

All colors in your document will then be transformed to appear as they would to someone with deuteranopia.

## What is CVD Simulation?

Color vision deficiency simulation transforms colors according to scientific models of how different types of color blindness affect color perception. By applying these transformations to your document, you can verify that information conveyed through color remains distinguishable even for colorblind readers.

## When to Use This Package

CVD simulation is useful for a wide range of documents, including:

- Scientific papers with color-coded data, charts, or graphs
- Educational materials that use color to convey information
- Presentations and slides
- Maps with color-coded regions

Essentially, it is useful for any document where color plays a role in conveying information.

## Basic Usage

The package provides several preset options for common CVD types:

- `protanopia` — red-blind (complete)
- `deuteranopia` — green-blind (complete)
- `tritanopia` — blue-blind (complete)
- `protanomaly` — red-weak (partial, severity 0.5)
- `deuteranomaly` — green-weak (partial, severity 0.5)
- `tritanomaly` — blue-weak (partial, severity 0.5)

Example usage:

```latex
\usepackage[protanopia]{cvd}      % Red-blind simulation
\usepackage[tritanomaly]{cvd}     % Blue-weak simulation
```

You can also customize the severity (0 to 1, where 1 is maximum):

```latex
\usepackage[type=deuteranopia, severity=0.5]{cvd}
```

and even set change the type and severity halfway through your document:

```latex
\cvdset{type=tritanopia, severity=0.2}
```
