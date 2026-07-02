# Package Options

The behavior of the CVD simulation is configured through package options. These options apply to the entire document or until they are changed later using the commands described in @sec-commands.

## CVD Type Options

### Type Presets

The package provides convenient preset options for common color vision deficiencies:

| Option | Description | Equivalent to |
|--------|-------------|---------------|
| `protanopia` | Red-blind (complete red-green color blindness) | `type=protanopia, severity=1.0` |
| `deuteranopia` | Green-blind (complete red-green color blindness) | `type=deuteranopia, severity=1.0` |
| `tritanopia` | Blue-blind (complete blue-yellow color blindness) | `type=tritanopia, severity=1.0` |
| `protanomaly` | Red-weak (partial red-green color blindness) | `type=protanopia, severity=0.5` |
| `deuteranomaly` | Green-weak (partial red-green color blindness) | `type=deuteranopia, severity=0.5` |
| `tritanomaly` | Blue-weak (partial blue-yellow color blindness) | `type=tritanopia, severity=0.5` |

### Custom Type and Severity

For more control, you can specify the type and severity explicitly:

| Option | Values | Default | Description |
|--------|--------|---------|-------------|
| `type` | `protanopia`, `deuteranopia`, `tritanopia` | none | Sets the type of color-vision deficiency |
| `severity` | 0.0 to 1.0 | none | Severity level, where 1.0 means maximum severity (full colorblindness) and 0 means normal vision |

## Graphics Options

| Option | Values | Default | Description |
|--------|--------|---------|-------------|
| `graphics hook` | `true`, `false` | `true` | Enable or disable the simulation for included PDF images |
| `graphics convert` | `true`, `false` | `false` | Enable or disable ImageMagick conversion for raster images (PNG/JPG) |

## Complete Examples

```latex
% Most common use case: check for deuteranopia
\usepackage[deuteranopia]{cvd}

% Full customization
\usepackage[
  type=protanopia,
  severity=0.7,
  graphics hook=true,
  graphics convert=true
]{cvd}
```

## Option Interaction

- Preset options (`protanopia`, `deuteranopia`, etc.) override individual `type` and `severity` settings
- If both a preset and individual options are specified, the preset takes precedence
- Graphics options are independent of CVD type and severity settings
- Options can be changed mid-document using the commands in @sec-commands
