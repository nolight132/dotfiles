#!/bin/sh
set -eu

accent='{{colors.primary.dark.hex}}'
accent_container='{{colors.primary_container.dark.hex}}'
on_accent_container='{{colors.on_primary_container.dark.hex}}'
fg='{{colors.on_surface.dark.hex}}'
fg_variant='{{colors.on_surface_variant.dark.hex}}'
inactive='{{colors.outline.dark.hex}}'
link='{{colors.primary.dark.hex}}'
visited='{{colors.tertiary.dark.hex}}'
negative='{{colors.error.dark.hex}}'
neutral='{{colors.tertiary.dark.hex}}'
positive='{{colors.secondary.dark.hex}}'

set_color_group() {
  group="$1"
  kwriteconfig6 --notify --file kdeglobals --group "$group" --key BackgroundAlternate '#000000'
  kwriteconfig6 --notify --file kdeglobals --group "$group" --key BackgroundNormal '#000000'
  kwriteconfig6 --notify --file kdeglobals --group "$group" --key DecorationFocus "$accent"
  kwriteconfig6 --notify --file kdeglobals --group "$group" --key DecorationHover "$accent"
  kwriteconfig6 --notify --file kdeglobals --group "$group" --key ForegroundActive "$accent"
  kwriteconfig6 --notify --file kdeglobals --group "$group" --key ForegroundInactive "$inactive"
  kwriteconfig6 --notify --file kdeglobals --group "$group" --key ForegroundLink "$link"
  kwriteconfig6 --notify --file kdeglobals --group "$group" --key ForegroundNegative "$negative"
  kwriteconfig6 --notify --file kdeglobals --group "$group" --key ForegroundNeutral "$neutral"
  kwriteconfig6 --notify --file kdeglobals --group "$group" --key ForegroundNormal "$fg"
  kwriteconfig6 --notify --file kdeglobals --group "$group" --key ForegroundPositive "$positive"
  kwriteconfig6 --notify --file kdeglobals --group "$group" --key ForegroundVisited "$visited"
}

for group in 'Colors:Button' 'Colors:Complementary' 'Colors:Header' 'Colors:Tooltip' 'Colors:View' 'Colors:Window'; do
  set_color_group "$group"
done

kwriteconfig6 --file kdeglobals --group 'Colors:Header' --group Inactive --key BackgroundAlternate '#000000'
kwriteconfig6 --file kdeglobals --group 'Colors:Header' --group Inactive --key BackgroundNormal '#000000'
kwriteconfig6 --file kdeglobals --group 'Colors:Header' --group Inactive --key DecorationFocus "$accent"
kwriteconfig6 --file kdeglobals --group 'Colors:Header' --group Inactive --key DecorationHover "$accent"
kwriteconfig6 --file kdeglobals --group 'Colors:Header' --group Inactive --key ForegroundActive "$accent"
kwriteconfig6 --file kdeglobals --group 'Colors:Header' --group Inactive --key ForegroundInactive "$inactive"
kwriteconfig6 --file kdeglobals --group 'Colors:Header' --group Inactive --key ForegroundLink "$link"
kwriteconfig6 --file kdeglobals --group 'Colors:Header' --group Inactive --key ForegroundNegative "$negative"
kwriteconfig6 --file kdeglobals --group 'Colors:Header' --group Inactive --key ForegroundNeutral "$neutral"
kwriteconfig6 --file kdeglobals --group 'Colors:Header' --group Inactive --key ForegroundNormal "$fg_variant"
kwriteconfig6 --file kdeglobals --group 'Colors:Header' --group Inactive --key ForegroundPositive "$positive"
kwriteconfig6 --file kdeglobals --group 'Colors:Header' --group Inactive --key ForegroundVisited "$visited"

kwriteconfig6 --file kdeglobals --group 'Colors:Selection' --key BackgroundAlternate "$accent_container"
kwriteconfig6 --file kdeglobals --group 'Colors:Selection' --key BackgroundNormal "$accent_container"
kwriteconfig6 --file kdeglobals --group 'Colors:Selection' --key DecorationFocus "$accent"
kwriteconfig6 --file kdeglobals --group 'Colors:Selection' --key DecorationHover "$accent"
kwriteconfig6 --file kdeglobals --group 'Colors:Selection' --key ForegroundActive "$accent"
kwriteconfig6 --file kdeglobals --group 'Colors:Selection' --key ForegroundInactive "$on_accent_container"
kwriteconfig6 --file kdeglobals --group 'Colors:Selection' --key ForegroundLink "$link"
kwriteconfig6 --file kdeglobals --group 'Colors:Selection' --key ForegroundNegative "$negative"
kwriteconfig6 --file kdeglobals --group 'Colors:Selection' --key ForegroundNeutral "$neutral"
kwriteconfig6 --file kdeglobals --group 'Colors:Selection' --key ForegroundNormal "$on_accent_container"
kwriteconfig6 --file kdeglobals --group 'Colors:Selection' --key ForegroundPositive "$positive"
kwriteconfig6 --file kdeglobals --group 'Colors:Selection' --key ForegroundVisited "$visited"

kwriteconfig6 --file kdeglobals --group General --key AccentColor "$accent"
kwriteconfig6 --file kdeglobals --group General --key ColorScheme 'MaterialYouDark'
kwriteconfig6 --file kdeglobals --group General --key accentColorFromWallpaper true

kwriteconfig6 --file kdeglobals --group WM --key activeBackground '0,0,0'
kwriteconfig6 --file kdeglobals --group WM --key inactiveBackground '0,0,0'
kwriteconfig6 --file kdeglobals --group WM --key activeForeground "$fg"
kwriteconfig6 --file kdeglobals --group WM --key inactiveForeground "$fg_variant"

# Keep transparent/blur-friendly KDE elements available without forcing opacity.
kwriteconfig6 --file kwinrc --group Plugins --key blurEnabled true
kwriteconfig6 --file kwinrc --group Plugins --key better-blur-dxEnabled true
kwriteconfig6 --file kwinrc --group Plugins --key better_blur_dxEnabled true
window_classes=$(printf '/ghostty/\n/zed/\n/plasmashell/')
kwriteconfig6 --file kwinrc --group Effect-better-blur-dx --key WindowClasses "$window_classes"

qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' >/dev/null 2>&1 || true
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' >/dev/null 2>&1 || true
gsettings set org.gnome.desktop.interface accent-color 'purple' >/dev/null 2>&1 || true
kbuildsycoca6 >/dev/null 2>&1 || true
