# Images and Graphics

The `cvd` package handles both vector (PDF) and raster (PNG/JPG) images, transforming colors according to the configured CVD simulation. The transformation behavior depends on the image type and the package options.

## Image Types

### PDF Vector Images

PDF images are transformed automatically when the `graphics hook` option is enabled (default: `true`). The package uses LuaTeX's `process_pdf_image_content` callback to intercept and transform color operators in the PDF content streams.

**Supported color operators:**
- `rg` / `RG` — RGB color (device-color)
- `k` / `K` — CMYK color (device-color)

**Not supported:**
- `scn` / `SCN` — Spot/separation colors, ICCBased colors, and pattern colors

Example:
```latex
\usepackage[graphics hook=true]{cvd}
\cvdtype{deuteranopia}

\begin{document}
% This PDF image will have its colors transformed
\includegraphics{vector-image.pdf}
\end{document}
```

### Raster Images (PNG/JPG)

Raster images require the `graphics convert` option to be enabled and additional system dependencies:

**Requirements:**
- Compile with `--shell-escape` flag
- ImageMagick must be installed on the system

When these requirements are met, raster images are converted on-the-fly with the CVD transformation applied.

Example:
```latex
\usepackage[graphics convert=true]{cvd}
\cvdtype{protanopia}

\begin{document}
% This PNG image will be converted with CVD transformation
\includegraphics{photo.png}
\end{document}
```

Compile with:
```bash
lualatex --shell-escape mydocument.tex
```

## Graphics Options

| Option | Default | Description |
|--------|---------|-------------|
| `graphics hook` | `true` | Enable transformation for PDF vector images |
| `graphics convert` | `false` | Enable ImageMagick conversion for raster images |

## The CVD Cache

To store the transformed raster images when using `graphics convert=true`. This directory is created automatically in the output directory.

The cache stores:
- Transformed versions of raster images
- Metadata about the CVD settings used for each transformation in the filename

This also means that subsequent compilations are faster, as images only need to be transformed once per CVD settings.

## Alternative: `\cvdincludegraphics`

The `\cvdincludegraphics` command provides explicit control over CVD transformation for raster images:

```latex
\cvdincludegraphics[<options>]{<path>}
```

This command:
- Applies CVD transformation to raster images even when `graphics convert=false`
- Behaves identically to `\includegraphics` when CVD simulation is enabled
- Has **no effect** on PDF images (use `graphics hook` for PDFs)

Example:
```latex
% Transform a single raster image, even with CVD disabled globally
\cvddisable
\cvdincludegraphics[width=0.5\textwidth]{chart.png}
```

## Limitations and Workarounds

### Raster Image Requirements

If ImageMagick is not installed or you don't compile with `--shell-escape`, raster images will pass through untransformed. In this case:
- PDF vector images can still be transformed (if `graphics hook=true`)
- Consider using vector formats (PDF, SVG) instead of raster formats

### Large PDF Files

When transforming PDF content streams, significant growth may cause truncation or rendering issues in some PDF viewers. This can happen with complex PDFs containing many color operations.

**Mitigation:**
- Use raster formats for complex PDFs
- Split complex documents into multiple files
- A warning is issued when significant stream growth is detected

## Best Practices

1. **Use vector formats when possible** — PDF images are transformed more reliably and don't require external dependencies

2. **Enable both options for full coverage:**
   ```latex
   \usepackage[graphics hook=true, graphics convert=true]{cvd}
   ```

3. **Always compile with --shell-escape** when using raster images:
   ```bash
   lualatex --shell-escape mydocument.tex
   ```

4. **Use `\cvdincludegraphics` for specific images** when you want to apply CVD transformation to select raster images without enabling global raster conversion

5. **Pre-compute colors for complex graphics** — When working with shadings and gradients, use `\cvddefinecolor` to create pre-computed colors (see @sec-shadings)
