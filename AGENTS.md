# Agent Instructions for `dichromacy`

dichromacy is a LuaTeX package for color vision deficiency simulation and correction.

## Build, test, and lint commands

- Run the default local verification path used in CI/pre-commit:
  - `devenv test`
- Run the full package regression suite:
  - `l3build-wrapped check -q -H --show-log-on-error`
- Run a single regression test:
  - `l3build-wrapped check --first simple --last simple -q -H --show-log-on-error`
  - (Swap `simple` for another test name like `pdf-transform`.)
- Build package documentation (PDF from `src/dichromacy.dtx`):
  - `l3build-wrapped doc`
- Build CTAN archive locally:
  - `l3build-wrapped ctan -q -H --show-log-on-error`
- Build docs site:
  - `task docs`
  - or `cd docs && quarto render`

## High-level architecture

- Core package source is literate LaTeX in `src/dichromacy.dtx` (expl3 + user macros).
  `src/dichromacy.ins` extracts `dichromacy.sty` from the `package` docstrip guard.
- Runtime color math and PDF/image transformation logic live in `src/dichromacy.lua`.
- At load time, the TeX layer (`dichromacy.dtx`) calls Lua (`require("dichromacy")`) and wires
  hooks:
  - Patches `xcolor` flow (`\XC@bcolor`) to transform current colors.
  - Installs LuaTeX `process_pdf_image_content` callback to transform content
    streams with color operators (`rg`, `RG`, `scn`, `SCN`, `k`) in embedded PDF
    streams.
- Raster images are handled separately via `\cvdincludegraphics` /
  `graphics convert`:
  - `dichromacy.lua` optionally shells out to ImageMagick and caches outputs in
    `.dichromacy-cache` (under `-output-directory` when set).
- Tests use `l3build` regression files in `testfiles/*.lvt` with expected
  outputs in `.tlg`.
- Docs pipeline:
  - `scripts/extract-dtx-docs.lua` extracts narrative/code from `src/*.dtx` into
    `docs/implementation/*.md`.
  - Quarto (`docs/_quarto.yml`) builds website and manual.

## Key repository conventions

- Treat `src/dichromacy.dtx` as the source of truth for TeX package code; do not
  hand-edit generated `dichromacy.sty` in build output directories.
- Project is LuaTeX-first.
- Package option/command behavior is implemented through `l3keys` (`dichromacy` key
  family), including presets (`protanopia`, `deuteranopia`, etc.) and toggles
  (`graphics hook`, `graphics convert`).
- Regression tests are selected by basename (`simple`, `pdf-transform`) via
  `l3build --first/--last`.
- Commit/release flow expects Conventional Commits and semantic-release updates
  package version metadata (`build.lua`, `src/dichromacy.dtx`).
- Formatting/linting is driven by `devenv` + `treefmt` (not ad-hoc formatting
  commands): `stylua` and `nixfmt` are configured there.
