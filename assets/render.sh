#!/usr/bin/env bash
# Regenerate the profile banner PNGs from banner.html.
# Renders at the full 2560x600 canvas; the README displays them at 1280 CSS px
# so they stay crisp on retina displays.
set -euo pipefail

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

render() { # $1 = query string, $2 = output filename
  "$CHROME" --headless --disable-gpu --hide-scrollbars \
    --force-device-scale-factor=1 \
    --window-size=2560,600 \
    --screenshot="$DIR/$2" \
    "file://$DIR/banner.html$1"
}

render ""             banner-dark.png
render "?theme=light" banner-light.png

echo "rendered:"
for f in banner-dark.png banner-light.png; do
  echo "  $f  $(file -b "$DIR/$f" | sed 's/.*, \([0-9]* x [0-9]*\).*/\1/')"
done
