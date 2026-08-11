#!/usr/bin/env bash
# Regenerate the profile banner PNGs from banner.html.
# Renders at the full 2560x600 canvas; the README displays them at 1280 CSS px
# so they stay crisp on retina displays.
set -euo pipefail

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

render() { # $1 = source html, $2 = WxH, $3 = query string, $4 = output filename
  "$CHROME" --headless --disable-gpu --hide-scrollbars \
    --force-device-scale-factor=1 \
    --window-size="$2" \
    --screenshot="$DIR/$4" \
    "file://$DIR/$1$3"
}

render banner.html 2560,600 ""             banner-dark.png
render banner.html 2560,600 "?theme=light" banner-light.png
render stats.html  2400,880 ""             stats-dark.png
render stats.html  2400,880 "?theme=light" stats-light.png

echo "rendered:"
for f in banner-dark.png banner-light.png stats-dark.png stats-light.png; do
  echo "  $f  $(file -b "$DIR/$f" | sed 's/.*, \([0-9]* x [0-9]*\).*/\1/')"
done
