#!/usr/bin/env bash
# End-to-end test: CVD must transform the colour operators inside an *embedded
# PDF image*, exercising the process_pdf_image_content regex on bytes a real
# pgf/TikZ figure produces (rather than synthetic strings). It builds the figure,
# embeds it under protanopia with PDF compression disabled, then inspects the
# output PDF directly -- no qpdf/mutool required, only lualatex and grep.
#
# Regression guard for the bug where an adjacent fill+stroke pair
# ("c c c rg c c c RG", as pgf emits) left the stroke colour untransformed.
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../.." && pwd)

sty="$root/build/unpacked/dichromacy.sty"
lua="$root/build/unpacked/dichromacy.lua"
if [[ ! -f $sty || ! -f $lua ]]; then
	echo "error: build/unpacked/dichromacy.{sty,lua} missing; run 'l3build unpack' first" >&2
	exit 1
fi

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cp "$sty" "$lua" "$here/figure.tex" "$here/document.tex" "$work/"
cd "$work"

lualatex -interaction=nonstopmode -halt-on-error figure.tex >figure.log 2>&1
lualatex -interaction=nonstopmode -halt-on-error document.tex >document.log 2>&1

pdf=document.pdf
status=0
i=0
pass() {
	i=$((i + 1))
	echo "ok $i - $1"
}
fail() {
	i=$((i + 1))
	echo "not ok $i - $1"
	status=1
}

# The original, untransformed stroke operators must be gone from the embedded
# stream (this is exactly what the adjacency bug left behind).
for orig in "1 0 0 RG" "0 1 0 RG" "0 1 0 0.3 K"; do
	if grep -aqF " $orig" "$pdf"; then
		fail "untransformed stroke operator still present: '$orig'"
	else
		pass "stroke operator transformed: '$orig'"
	fi
done

# The expected protanopia-transformed stroke operators must be present. Values
# are deterministic (fixed Machado matrices) and match the Lua unit tests.
for want in "0.1274 0.203 0 RG" "0.5594 0.8669 0.0073 RG" "0.2827 0.1313 0.0728 0.3 K"; do
	if grep -aqF "$want" "$pdf"; then
		pass "transformed stroke operator present: '$want'"
	else
		fail "expected transformed stroke operator missing: '$want'"
	fi
done

echo "1..$i"

if [[ $status -ne 0 ]]; then
	echo "---- colour operators found in $pdf ----" >&2
	grep -aE ' (rg|RG|k|K)$' "$pdf" | sort -u >&2 || true
fi
exit $status
