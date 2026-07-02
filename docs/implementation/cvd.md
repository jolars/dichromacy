---
title: "Main"
---

::: {.callout-note}

**Source file:** [`src/cvd.dtx`](https://github.com/jolars/cvd/blob/main/src/cvd.dtx)

:::

## Package Dependencies

Load required packages.

``` latex
\RequirePackage{iftex}
\RequirePackage{xcolor}
\RequirePackage{graphicx}
```

## Engine Check

Currently only LuaTeX is fully supported.

``` latex
\sys_if_engine_luatex:F
{
  \msg_error:nn { cvd } { luatex-required }
}
\msg_new:nnn { cvd } { luatex-required }
{
  LuaTeX~required.\\
  This~package~currently~only~works~with~LuaLaTeX.\\
  pdfLaTeX~support~is~under~development.
}
```

## Load Lua Module

Load the Lua module that implements the CVD transformations. The
`install_pdf_image_hook` function registers a callback that transforms
colors in embedded PDF pages (vector graphics only). We also load the
Lua File System module for file timestamp checking.

``` latex
\directlua{lfs = require("lfs"); cvd = require("cvd"); cvd.install_pdf_image_hook()}
```

## Hook into xcolor

Use `xcolor`'s hook to transform RGB values before display. This handles
text colors, color boxes, and other `xcolor`-based content.

``` latex
\cs_set:Npn \XC@bcolor
{
  \directlua
  {
    token.set_macro("current@color",~
    cvd.transform_current_color("\luaescapestring{\current@color}"),~
    "global")
  }
}
```

## Hook into pgf Shadings

TikZ/pgf shadings (linear and radial gradients) store their colors in
PDF `Shading` dictionaries whose `Function` carries `/C0` and `/C1`
color arrays. These objects sit in the page resources rather than in any
content stream, so none of 's other transform paths reach them and they
need a dedicated hook.

Patch pgf's leaf tuple emitters so the RGB or CMYK tuple is filtered
through `cvd.transform` first. From one transform each emitter sets both
the space-separated macro (/) that ends up in `/C0` and `/C1` for the
pdf/luatex driver, and the brace-grouped system-layer record (/) used by
the dvisvgm driver, so the two never disagree. Guarded with so loading
without or is a no-op. `ShadingType 1` (functional) shadings and
`DeviceGray` shadings are intentionally not handled.

``` latex
\def \__cvd_patch_pgf_shadings:
  {
    \@ifundefined { pgf@getrgb@@ } { } {
      \def \pgf@getrgb@@ ##1,##2,##3!
        {
          \directlua { cvd.set_pgf_rgb("##1",~"##2",~"##3") }
        }
    }
    \@ifundefined { pgf@getcmyk@@ } { } {
      \def \pgf@getcmyk@@ ##1,##2,##3,##4!
        {
          \directlua { cvd.set_pgf_cmyk("##1",~"##2",~"##3",~"##4") }
        }
    }
  }
\__cvd_patch_pgf_shadings:
\AtBeginDocument { \__cvd_patch_pgf_shadings: }
```

## User Commands

### `\cvdtype`

Set the type of color vision deficiency to simulate.

``` latex
\NewDocumentCommand \cvdtype { m }
{
  \directlua { cvd.set_type("#1") }
}
```

### `\cvdseverity`

Set the severity of the simulation (0.0 to 1.0).

``` latex
\NewDocumentCommand \cvdseverity { m }
  {
    \directlua { cvd.set_severity(#1) }
  }
```

### `\cvdenable`

Enable CVD simulation.

``` latex
\NewDocumentCommand \cvdenable { }
{
  \directlua { cvd.enable() }
}
```

### `\cvddisable`

Disable CVD simulation.

``` latex
\NewDocumentCommand \cvddisable { }
{
  \directlua { cvd.disable() }
}
```

### `\cvdincludegraphics`

Include a graphics file with CVD transformation applied to raster
images.

``` latex
\tl_new:N \l__cvd_imgpath_tl
\NewDocumentCommand \cvdincludegraphics { O{} m }
{
  \tl_set:Nx \l__cvd_imgpath_tl
  {
    \directlua
    { tex.sprint(cvd.get_image_path("\luaescapestring{#2}")) }
  }
  \__cvd_orig_includegraphics[#1]{\tl_use:N \l__cvd_imgpath_tl}
}
```

### `\cvddefinecolor`

Define a new color by applying CVD transformation to an existing color.
Usage:

``` latex
\tl_new:N \l__cvd_model_tl
\tl_new:N \l__cvd_values_tl

\NewDocumentCommand \cvddefinecolor { O{} m m }
{
  % Extract the original color
  \extractcolorspecs{#2}{\l__cvd_model_tl}{\l__cvd_values_tl}
  
  % Apply CVD transformation with specified settings
  \keys_set:nn { cvd } { #1 }
  \cvdenable
  
  % Transform the RGB values directly via Lua
  \directlua{
    local~values~=~"\luaescapestring{\l__cvd_values_tl}"
    local~r,~g,~b~=~values:match("([^,]+),([^,]+),([^,]+)")
    r,~g,~b~=~tonumber(r),~tonumber(g),~tonumber(b)
    r,~g,~b~=~cvd.transform("rgb",~r,~g,~b)
    token.set_macro("l__cvd_values_tl",~string.format("\csstring\%.6f,\csstring\%.6f,\csstring\%.6f",~r,~g,~b))
  }
  
  % Define the color with transformed values
  \use:x { \definecolor {#3} { \exp_not:V \l__cvd_model_tl } { \exp_not:V \l__cvd_values_tl } }
  
  \cvddisable
}
```

## Package Configuration

Define keys for package configuration using . Keys are available both as
package load-time options and via the command.

``` latex
\bool_new:N \l__cvd_graphics_hook_bool
\bool_new:N \l__cvd_graphics_convert_bool
\cs_new_eq:NN \__cvd_orig_includegraphics \includegraphics

\keys_define:nn { cvd }
  {
    type          .code:n = { \cvdtype{#1} } ,
    severity      .code:n = { \cvdseverity{#1} } ,
    graphics~hook .bool_set:N = \l__cvd_graphics_hook_bool ,
    graphics~hook .initial:n = true ,
    graphics~hook .default:n = true ,
    graphics~hook / true .code:n = { \directlua { cvd.enable_graphics_hook() } } ,
    graphics~hook / false .code:n = { \directlua { cvd.disable_graphics_hook() } } ,
    graphics~convert .bool_set:N = \l__cvd_graphics_convert_bool ,
    graphics~convert .initial:n = false ,
    graphics~convert .default:n = true ,
    graphics~convert / true .code:n = { \__cvd_patch_includegraphics: } ,
    graphics~convert / false .code:n = { \__cvd_unpatch_includegraphics: } ,
    protanopia    .code:n = { \cvdtype{protanopia} \cvdseverity{1.0} } ,
    deuteranopia  .code:n = { \cvdtype{deuteranopia} \cvdseverity{1.0} } ,
    tritanopia    .code:n = { \cvdtype{tritanopia} \cvdseverity{1.0} } ,
    protanomaly   .code:n = { \cvdtype{protanopia} \cvdseverity{0.5} } ,
    deuteranomaly .code:n = { \cvdtype{deuteranopia} \cvdseverity{0.5} } ,
    tritanomaly   .code:n = { \cvdtype{tritanopia} \cvdseverity{0.5} } ,
    unknown       .code:n = 
      { \msg_warning:nnx { cvd } { unknown-option } { \l_keys_key_str } }
  }
\msg_new:nnn { cvd } { unknown-option }
  { Unknown~option~'#1'. }

\cs_new:Npn \__cvd_patch_includegraphics:
{
  \RenewDocumentCommand \includegraphics { O{} m }
  {
    \cvdincludegraphics[##1]{##2}
  }
  \directlua { cvd.enable_graphics_convert() }
}

\cs_new:Npn \__cvd_unpatch_includegraphics:
{
  \cs_set_eq:NN \includegraphics \__cvd_orig_includegraphics
  \directlua { cvd.disable_graphics_convert() }
}

\NewDocumentCommand \cvdset { m }
{
  \keys_set:nn { cvd } { #1 }
}
\ProcessKeyOptions [ cvd ]
```
