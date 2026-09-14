#!/usr/bin/env bash
# Installs PDF tooling on Debian/Ubuntu: pandoc, a LaTeX engine (for pandoc --pdf-engine),
# and a headless browser (for HTML->PDF via chromium --headless --print-to-pdf).
# Usage: sudo ./install-pdf-tools.sh
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "Please run as root, e.g.: sudo $0" >&2
  exit 1
fi

if ! command -v apt-get >/dev/null 2>&1; then
  echo "apt-get not found; this script only supports Debian/Ubuntu." >&2
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

echo "==> Updating package lists"
apt-get update

# Required: pandoc + a LaTeX engine with German language/hyphenation and Unicode font support.
REQUIRED_PKGS=(
  pandoc
  texlive-xetex
  texlive-latex-recommended
  texlive-fonts-recommended
  texlive-lang-german
  lmodern
)

echo "==> Installing pandoc + LaTeX (xelatex): ${REQUIRED_PKGS[*]}"
apt-get install -y "${REQUIRED_PKGS[@]}"

# Optional: a headless browser for HTML -> PDF (chromium --headless --print-to-pdf).
# Package name/availability varies by distro release, so try a few and don't fail the script.
echo "==> Installing a headless browser (optional)"
BROWSER_INSTALLED=0
for pkg in chromium chromium-browser; do
  if apt-cache show "$pkg" >/dev/null 2>&1; then
    if apt-get install -y "$pkg"; then
      BROWSER_INSTALLED=1
      break
    fi
  fi
done
if [ "$BROWSER_INSTALLED" -eq 0 ]; then
  echo "    (no apt chromium package available/installable here; skipping - pandoc/LaTeX are enough for PDF generation)"
fi

# Optional: wkhtmltopdf, a lighter HTML -> PDF converter (not always packaged on newer releases).
echo "==> Installing wkhtmltopdf (optional)"
if apt-cache show wkhtmltopdf >/dev/null 2>&1; then
  apt-get install -y wkhtmltopdf || echo "    (wkhtmltopdf install failed; skipping)"
else
  echo "    (wkhtmltopdf not available in apt repos; skipping)"
fi

echo "==> Done. Installed versions:"
command -v pandoc >/dev/null && pandoc --version | head -1
command -v xelatex >/dev/null && xelatex --version | head -1
command -v chromium >/dev/null && chromium --version || command -v chromium-browser >/dev/null && chromium-browser --version || true
command -v wkhtmltopdf >/dev/null && wkhtmltopdf --version || true
