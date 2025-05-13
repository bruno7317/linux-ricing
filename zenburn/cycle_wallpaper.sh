#!/usr/bin/env bash
set -Eeuo pipefail
export PATH="$HOME/.local/bin:$PATH"
LOG="${XDG_CACHE_HOME:-$HOME/.cache}/wal/cycle_wallpaper.log"
mkdir -p "$(dirname "$LOG")"
exec >>"$LOG" 2>&1
echo -e "\n=== $(date) ==="
set -x

WALL_DIR="$HOME/.config/awesome/zenburn/wallpapers"
WALLPAPER=$(find "$WALL_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' \) | shuf -n 1)

[[ -z $WALLPAPER ]] && { notify-send "Cycle Wallpaper" "No wallpapers found" ; exit 1; }

# 1️⃣  run Pywal and show the version it prints
wal -i "$WALLPAPER" -n --saturate 0.7

# 2️⃣  confirm Pywal produced the theme file we need
test -f "$HOME/.cache/wal/colors-alacritty.toml"

# 3️⃣  make sure Awesome sees the same image
cp "$WALLPAPER" "$HOME/.cache/wal/wall.png"

# 4️⃣  give Alacritty a nudge

alacritty msg config -r 2>/dev/null || touch "$HOME/.config/alacritty/alacritty.toml"

# 5️⃣  tell Awesome to repaint
awesome-client "awesome.emit_signal('theme::reload')"