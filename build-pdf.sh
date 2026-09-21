#!/usr/bin/env bash
# Builds Pigovsky-Lebenslauf.pdf from Pigovsky-Lebenslauf.tex with xelatex
# (the document uses fontspec/polyglossia, so it needs XeLaTeX or LuaLaTeX).
# Install the toolchain first with: sudo ./install-pdf-tools.sh
# Usage: ./build-pdf.sh
set -euo pipefail

cd "$(dirname "$0")"

NAME=Pigovsky-Lebenslauf

if ! command -v xelatex >/dev/null 2>&1; then
  echo "xelatex not found; run: sudo ./install-pdf-tools.sh" >&2
  exit 1
fi

# Two passes so hyperref/layout references settle.
for pass in 1 2; do
  echo "==> xelatex pass $pass"
  xelatex -interaction=nonstopmode -halt-on-error "$NAME.tex" >/dev/null \
    || { echo "Build failed; see $NAME.log" >&2; exit 1; }
done

echo "==> Built $NAME.pdf"
