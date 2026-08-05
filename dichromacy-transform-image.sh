#!/bin/bash
# dichromacy-transform-image.sh
# Transform images for color vision deficiency simulation
# Usage: dichromacy-transform-image.sh <type> <severity> <input> <output>

set -e

CVD_TYPE="$1"
SEVERITY="$2"
INPUT="$3"
OUTPUT="$4"

if [ -z "$INPUT" ] || [ -z "$OUTPUT" ] || [ -z "$CVD_TYPE" ] || [ -z "$SEVERITY" ]; then
    echo "Usage: $0 <type> <severity> <input> <output>"
    echo "  type: protanopia, deuteranopia, or tritanopia"
    echo "  severity: 0.0 to 1.0 (1.0 = full simulation)"
    echo "Example: $0 protanopia 1.0 photo.png photo-dichromacy.png"
    exit 1
fi

# Check if texlua is available
if ! command -v texlua &> /dev/null; then
    echo "Error: texlua not found. Please install TeX Live or MiKTeX."
    exit 1
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Compute interpolated Machado matrix using texlua
# Create a temporary Lua script
TEMP_LUA=$(mktemp /tmp/dichromacy-matrix.XXXXXX.lua)
trap "rm -f $TEMP_LUA" EXIT

cat > "$TEMP_LUA" << EOF
package.path = package.path .. ";$SCRIPT_DIR/src/?.lua"
local dichromacy = require('dichromacy')
local matrix_str = dichromacy.get_machado_matrix_for_imagemagick('$CVD_TYPE', $SEVERITY)
if matrix_str then
    print(matrix_str)
else
    io.stderr:write('Error: Unknown CVD type "$CVD_TYPE"\\n')
    os.exit(1)
end
EOF

MATRIX=$(texlua "$TEMP_LUA" 2>&1)

# Check if matrix computation was successful
if [ $? -ne 0 ] || [ -z "$MATRIX" ]; then
    echo "Error: Failed to compute transformation matrix"
    echo "$MATRIX"
    echo "Valid types: protanopia, deuteranopia, tritanopia"
    exit 1
fi

# Check if ImageMagick is available
if ! command -v convert &> /dev/null && ! command -v magick &> /dev/null; then
    echo "Error: ImageMagick not found. Please install it:"
    echo "  Ubuntu/Debian: apt install imagemagick"
    echo "  macOS: brew install imagemagick"
    echo "  Fedora: dnf install ImageMagick"
    exit 1
fi

# Use 'magick' command if available (IMv7), otherwise 'convert' (IMv6)
if command -v magick &> /dev/null; then
    CMD="magick"
else
    CMD="convert"
fi

# Transform the image
echo "Transforming $INPUT -> $OUTPUT (${CVD_TYPE}, severity=${SEVERITY})"
$CMD "$INPUT" -color-matrix "$MATRIX" "$OUTPUT"

echo "Done!"
