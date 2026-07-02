# Shadings (gradients) {#sec-shadings}

`cvd` transforms TikZ/pgf shadings---both axial (linear) and radial gradients
emitted by `\shade`, `\shadedraw`, and friends. The transformation is applied to
the RGB or CMYK color stops at the moment pgf emits the shading's PDF object.
For CMYK, the K component is left unchanged.

## Basic usage

Set the cvd type once before `\begin{document}` and any shading you draw will
come out simulated:

```latex
\documentclass{article}
\usepackage{tikz}
\usepackage{cvd}

\cvdtype{deuteranopia}
\cvdseverity{1.0}
\cvdenable

\begin{document}
\begin{tikzpicture}
  \shade[left color=red, right color=blue] (0,0) rectangle (4,1);
\end{tikzpicture}
\end{document}
```

## Comparing several cvd types in one document

Toggling `\cvdtype` between two `\shade` calls that use the **same** input
colors does **not** produce two different gradients. pgf caches each shading by
its input color stops (see `\pgfuseshading` in `pgfcoreshade.code.tex`); the
second call hits the cache and reuses the PDF object emitted by the first, so
the cvd state at the time of the second call has no effect.

The workaround is to pre-compute simulated colors with `\cvddefinecolor` and
shade with those, leaving cvd disabled at draw time:

```latex
\cvddefinecolor[type=deuteranopia]{red}{red-d}
\cvddefinecolor[type=deuteranopia]{blue}{blue-d}
\cvddefinecolor[type=protanopia]{red}{red-p}
\cvddefinecolor[type=protanopia]{blue}{blue-p}

\begin{tikzpicture}
  \shade[left color=red,   right color=blue]   (0,0) rectangle (4,0.8);
  \shade[left color=red-d, right color=blue-d] (5,0) rectangle (9,0.8);
  \shade[left color=red-p, right color=blue-p] (0,-1.5) rectangle (4,-0.7);
\end{tikzpicture}
```

Each row uses different color names, so pgf's cache key differs and each shading
gets its own PDF object.

## Known limitations

- **Functional shadings (`\pgfdeclarefunctionalshading`, `ShadingType 1`)**
  embed their colors inside a PostScript Type 4 function. cvd does not parse or
  rewrite that function, so functional shadings pass through unchanged.

- **Cached duplicate shadings** -- as described above, two `\shade` calls with
  identical input colors share one PDF object. Use `\cvddefinecolor` to
  side-step the cache.
