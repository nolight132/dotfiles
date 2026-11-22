# Turns the key=#rrggbb palette Noctalia renders into an FL Studio .flstheme.
#
# FL Studio themes do not set the colour of its panels directly. They shift the hue, saturation and
# lightness of its built-in slate skin, whose reference grey is #2f373c, so the chrome colour is turned
# into those three shifts. The curves were measured from FL Studio 2026 screenshots. Hue moves by the
# negated amount in degrees, saturation scales by 1 + x/255, and lightness blends towards black below
# zero and towards white above it.
#
# Noctalia's surfaces are nearly grey, so the chrome keeps their lightness but takes the hue of the tint
# colour at the strongest saturation FL Studio allows, which is twice that of its skin.

function hex(s) { return strtonum("0x" substr(s, 2)) }

function rgb_hsl(c, out,    r, g, b, mx, mn, d) {
  r = int(c / 65536) / 255; g = int(c / 256) % 256 / 255; b = c % 256 / 255
  mx = r > g ? (r > b ? r : b) : (g > b ? g : b)
  mn = r < g ? (r < b ? r : b) : (g < b ? g : b)
  d = mx - mn
  out["l"] = (mx + mn) / 2
  out["s"] = d == 0 ? 0 : d / (1 - (2 * out["l"] - 1 < 0 ? 1 - 2 * out["l"] : 2 * out["l"] - 1))
  if (d == 0) out["h"] = 0
  else if (mx == r) out["h"] = 60 * (((g - b) / d) % 6)
  else if (mx == g) out["h"] = 60 * ((b - r) / d + 2)
  else out["h"] = 60 * ((r - g) / d + 4)
  if (out["h"] < 0) out["h"] += 360
}

# Hex colour for a hue in degrees and a saturation and lightness between 0 and 1.
function hsl_hex(h, s, l,    c, x, m, r, g, b, k) {
  c = (1 - (2 * l - 1 < 0 ? 1 - 2 * l : 2 * l - 1)) * s
  k = (h / 60) % 2 - 1
  x = c * (1 - (k < 0 ? -k : k))
  m = l - c / 2
  if (h < 60) { r = c; g = x; b = 0 }
  else if (h < 120) { r = x; g = c; b = 0 }
  else if (h < 180) { r = 0; g = c; b = x }
  else if (h < 240) { r = 0; g = x; b = c }
  else if (h < 300) { r = x; g = 0; b = c }
  else { r = c; g = 0; b = x }
  return sprintf("#%02x%02x%02x", (r + m) * 255 + 0.5, (g + m) * 255 + 0.5, (b + m) * 255 + 0.5)
}

# The palette colour called name with the tint's hue and saturation s, keeping its own lightness.
function tinted(name, s,    col) {
  rgb_hsl(hex(c[name]), col)
  return hsl_hex(tint["h"], s, col["l"])
}

function clamp(x) { return x < -255 ? -255 : (x > 255 ? 255 : x) }

# Opaque colour as the signed 32-bit integer FL Studio stores. Most fields hold it as a Delphi TColor with
# blue in the high byte, but the selection and text colours keep red there.
function argb(s) { return hex(s) - 16777216 }
function abgr(s,    v) { v = hex(s); return (v % 256) * 65536 + int(v / 256) % 256 * 256 + int(v / 65536) - 16777216 }

BEGIN { FS = "=" }
NF == 2 { c[$1] = $2 }

END {
  rgb_hsl(hex("#2f373c"), base)
  rgb_hsl(hex("tint" in c ? c["tint"] : c["chrome"]), tint)
  rgb_hsl(hex(c["chrome"]), want)
  want["h"] = tint["h"]
  want["s"] = 2 * base["s"]

  hue = base["h"] - want["h"]
  if (hue > 180) hue -= 360
  if (hue < -180) hue += 360
  sat = base["s"] > 0 ? 255 * (want["s"] / base["s"] - 1) : 0
  if (want["l"] < base["l"]) light = -255 * (1 - want["l"] / base["l"])
  else light = 255 * (want["l"] - base["l"]) / (1 - base["l"])

  printf "\xef\xbb\xbf"
  printf "Hue=%d\r\nSaturation=%d\r\nLightness=%d\r\nContrast=0\r\nText=0\r\n", hue, clamp(sat), clamp(light)
  printf "Selected=%d\r\nHighlight=%d\r\nMute=%d\r\nOption=%d\r\n", argb(c["selection"]), abgr(c["highlight"]), abgr(c["mute"]), abgr(c["option"])
  printf "StepEven=%d\r\nStepOdd=%d\r\n", abgr(tinted("step_even", 0.3)), abgr(c["step_odd"])
  printf "Lightmode=0\r\nOverrideClips=0\r\nTextColor=%d\r\n", argb(c["text"])
}
