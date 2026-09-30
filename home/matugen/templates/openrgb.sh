#!/bin/sh

hue={{colors.primary.dark.hue}}
saturation=60
lightness=50
max_luminance=8

# Hue corrections in degrees at anchor hues, interpolated in between. LED green
# diodes read teal and blue diodes overpower red, so greens move toward yellow
# and blues toward magenta to match what the screen shows.
hue_offsets="0:0 60:0 120:-30 180:-20 250:25 300:0 360:0"

# Converts the corrected HSL colour to a bare RRGGBB hex string. Any colour whose
# luminance exceeds max_luminance percent is dimmed in linear light to that level
# so greens do not glow brighter than everything else.
color=$(awk -v h="$hue" -v offsets="$hue_offsets" -v s="$saturation" -v l="$lightness" -v ymax="$max_luminance" '
function abs(v) { return v < 0 ? -v : v }
function linear(v) { return v <= 0.04045 ? v / 12.92 : ((v + 0.055) / 1.055) ^ 2.4 }
function encode(v) { return v <= 0.0031308 ? v * 12.92 : 1.055 * v ^ (1 / 2.4) - 0.055 }
BEGIN {
  n = split(offsets, anchors, " ")
  for (i = 1; i < n; i++) {
    split(anchors[i], lo, ":"); split(anchors[i + 1], hi, ":")
    if (h >= lo[1] && h <= hi[1]) { h += lo[2] + (hi[2] - lo[2]) * (h - lo[1]) / (hi[1] - lo[1]); break }
  }
  h = ((h % 360) + 360) % 360 / 60; s /= 100; l /= 100; ymax /= 100
  c = (1 - abs(2 * l - 1)) * s
  x = c * (1 - abs(h % 2 - 1))
  m = l - c / 2
  if (h < 1) { r = c; g = x; b = 0 } else if (h < 2) { r = x; g = c; b = 0 }
  else if (h < 3) { r = 0; g = c; b = x } else if (h < 4) { r = 0; g = x; b = c }
  else if (h < 5) { r = x; g = 0; b = c } else { r = c; g = 0; b = x }
  r = linear(r + m); g = linear(g + m); b = linear(b + m)
  y = 0.2126 * r + 0.7152 * g + 0.0722 * b
  k = y > ymax ? ymax / y : 1
  printf "%02x%02x%02x", encode(r * k) * 255 + 0.5, encode(g * k) * 255 + 0.5, encode(b * k) * 255 + 0.5
}')

exec openrgb --nodetect \
  --device "Sapphire" --mode static --color "$color" \
  --device "B650M" --mode direct --color "$color"
