#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
VENDOR_DIR="$ROOT_DIR/html/vendor"

# Pinned remote assets used by xslt/indices.xsl.
readonly DT_CSS_URL="https://cdn.datatables.net/v/bs5/jszip-2.5.0/dt-1.13.1/b-2.3.3/b-colvis-2.3.3/b-html5-2.3.3/fc-4.2.1/fh-3.3.1/r-2.4.0/sp-2.1.0/sl-1.5.0/datatables.min.css"
readonly DT_JS_URL="https://cdn.datatables.net/v/bs5/jszip-2.5.0/dt-1.13.1/b-2.3.3/b-colvis-2.3.3/b-html5-2.3.3/fc-4.2.1/fh-3.3.1/r-2.4.0/sp-2.1.0/sl-1.5.0/datatables.min.js"
readonly PDFMAKE_JS_URL="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.36/pdfmake.min.js"
readonly PDFMAKE_FONTS_URL="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.36/vfs_fonts.js"
readonly DE_EDITOR_URL="https://unpkg.com/de-micro-editor@0.3.1/dist/de-editor.min.js"

force="false"
if [[ "${1:-}" == "--force" ]]; then
  force="true"
fi

download() {
  local url="$1"
  local destination="$2"

  mkdir -p "$(dirname "$destination")"

  if [[ "$force" != "true" && -s "$destination" ]]; then
    echo "Keeping existing file: $destination"
    return
  fi

  echo "Downloading $url -> $destination"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" -o "$destination"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$destination" "$url"
  else
    echo "Error: neither curl nor wget is available." >&2
    exit 1
  fi
}

download "$DT_CSS_URL" "$VENDOR_DIR/datatables/indices/datatables.min.css"
download "$DT_JS_URL" "$VENDOR_DIR/datatables/indices/datatables.min.js"
download "$PDFMAKE_JS_URL" "$VENDOR_DIR/pdfmake/pdfmake.min.js"
download "$PDFMAKE_FONTS_URL" "$VENDOR_DIR/pdfmake/vfs_fonts.js"
download "$DE_EDITOR_URL" "$VENDOR_DIR/de-micro-editor/dist/de-editor.min.js"
echo "Vendor fetch complete."
