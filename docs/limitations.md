# Current Limitations

While the `cvd` package provides powerful CVD simulation capabilities, there are some technical limitations to be aware of. This page documents all known limitations and their workarounds.

## Engine Requirements

Only LuaLaTeX is currently supported. Support for other engines is under development.

## Raster Image Requirements

Raster image (PNG/JPG) transformation requires compiling with `-shell-escape` and ImageMagick to be installed on the system. Without these, raster images pass through untransformed.

## PDF/Vector Graphics Limitations

- Functional shadings (`\pgfdeclarefunctionalshading`, ShadingType 1) pass through unchanged as their colors are embedded in PostScript Type 4 functions.
- pgf caches shadings, so changing CVD settings between identical `\shade` calls has no effect.
  Workaround: use `\cvddefinecolor` to create unique color names for each CVD variant you need.
- Spot/separation colors, ICCBased colors, and pattern colors are not transformed. Only device-color operators `rg/RG` (RGB) and `k/K` (CMYK) are supported.
- When transforming PDF content streams, significant growth may cause truncation or rendering issues in some PDF viewers.
  Mitigation: use raster formats for complex PDFs, or split them into multiple documents. When a significiant growth of te PDF stream is detected, a warning for this is issued.

## Feature Requests

If you encounter limitations that affect your use case, consider:

1. Checking the [GitHub repository](https://github.com/jolars/cvd) for open issues
2. Opening a new issue with a minimal working example
3. Contributing a pull request with improvements

The package is actively developed, and many limitations may be addressed in future versions.
