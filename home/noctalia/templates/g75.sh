#!/bin/sh

hue={{colors.source_color.default.hue}}
saturation=100
lightness=62

# Hue corrections in degrees at anchor hues, interpolated in between. The
# keyboard's green diodes read teal and its blue diodes drown out red, so greens
# move toward yellow and blues far toward magenta.
hue_offsets="0:0 60:0 102:-22 180:0 260:59 300:30 360:0"

# Converts the corrected HSL colour to a bare RRGGBB hex string.
color=$(awk -v h="$hue" -v offsets="$hue_offsets" -v s="$saturation" -v l="$lightness" '
function abs(v) { return v < 0 ? -v : v }
BEGIN {
  n = split(offsets, anchors, " ")
  for (i = 1; i < n; i++) {
    split(anchors[i], lo, ":"); split(anchors[i + 1], hi, ":")
    if (h >= lo[1] && h <= hi[1]) { h += lo[2] + (hi[2] - lo[2]) * (h - lo[1]) / (hi[1] - lo[1]); break }
  }
  h = ((h % 360) + 360) % 360 / 60; s /= 100; l /= 100
  c = (1 - abs(2 * l - 1)) * s
  x = c * (1 - abs(h % 2 - 1))
  m = l - c / 2
  if (h < 1) { r = c; g = x; b = 0 } else if (h < 2) { r = x; g = c; b = 0 }
  else if (h < 3) { r = 0; g = c; b = x } else if (h < 4) { r = 0; g = x; b = c }
  else if (h < 5) { r = x; g = 0; b = c } else { r = c; g = 0; b = x }
  printf "%02x%02x%02x", (r + m) * 255 + 0.5, (g + m) * 255 + 0.5, (b + m) * 255 + 0.5
}')

exec g75-cli color "$color"
