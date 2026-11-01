#!/bin/sh
# used when there's no hide-bar.sh / restore-bar.sh next to the game. usage: bar-auto.sh hide|restore
# finds whatever bar is running and hides it, then brings it back:
#   quickshell  -> tries its ipc ("bar close/open") on the running config, else the restart method
#   waybar      -> SIGUSR1 (toggles it)
#   polybar     -> polybar-msg hide/show
#   kde plasma  -> panels set to autohide, then put back
#   anything else (eww, ags, yambar, lemonbar, tint2, swaybar...) -> stopped, then started again with the same command
S="${XDG_RUNTIME_DIR:-/tmp}/vsr-bar-state"; mkdir -p "$S"
BARS="waybar polybar eww ags yambar lemonbar tint2 swaybar i3bar i3status-rs nwg-panel sfwbar hyprpanel"

case "$1" in
hide)
  [ -e "$S/active" ] && exit 0
  : > "$S/active"
  # quickshell: the config name comes from its own command line (-c name / --config name)
  for pid in $(pgrep -x -u "$(id -u)" 'qs|quickshell'); do
    cfg=$(tr '\0' '\n' < /proc/$pid/cmdline | awk '$0=="-c"||$0=="--config"{getline; print; exit}')
    [ -n "$cfg" ] && c="-c $cfg" || c=""
    if qs $c ipc call bar close >/dev/null 2>&1; then echo "$c" >> "$S/qs"; continue; fi
    tr '\0' '\n' < /proc/$pid/cmdline | tr '\n' '\0' > "$S/restart.$pid"; kill $pid
  done
  pgrep -x -u "$(id -u)" polybar >/dev/null && { polybar-msg cmd hide >/dev/null 2>&1; : > "$S/polybar"; }
  pgrep -x -u "$(id -u)" waybar >/dev/null && { pkill -x -u "$(id -u)" -SIGUSR1 waybar; : > "$S/waybar"; }
  if pgrep -x -u "$(id -u)" plasmashell >/dev/null; then
    q=$(command -v qdbus6 || command -v qdbus-qt6 || command -v qdbus)
    if [ -n "$q" ]; then
      $q org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript 'print(panels().map(function(p){return p.hiding}).join(","))' > "$S/plasma" 2>/dev/null
      $q org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript 'panels().forEach(function(p){p.hiding="autohide"})' >/dev/null 2>&1
    fi
  fi
  for b in $BARS; do
    for pid in $(pgrep -x -u "$(id -u)" "$b"); do
      case "$b" in polybar|waybar) continue ;; esac
      cp /proc/$pid/cmdline "$S/restart.$pid" 2>/dev/null && kill $pid
    done
  done ;;
restore)
  [ -e "$S/active" ] || exit 0
  [ -f "$S/qs" ] && while read -r c; do qs $c ipc call bar open >/dev/null 2>&1; done < "$S/qs"
  [ -e "$S/polybar" ] && polybar-msg cmd show >/dev/null 2>&1
  [ -e "$S/waybar" ] && pkill -x -u "$(id -u)" -SIGUSR1 waybar
  if [ -s "$S/plasma" ]; then
    q=$(command -v qdbus6 || command -v qdbus-qt6 || command -v qdbus)
    i=0; js=""
    for h in $(tr ',' ' ' < "$S/plasma"); do js="$js"'panels()['$i'].hiding="'$h'";'; i=$((i+1)); done
    [ -n "$q" ] && $q org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$js" >/dev/null 2>&1
  fi
  # restarted bars: don't leak the game's x11/preload settings into them
  for f in "$S"/restart.*; do
    [ -f "$f" ] || continue
    ( cd "$HOME" && env -u LD_PRELOAD -u SDL_VIDEODRIVER setsid xargs -0 -a "$f" env >/dev/null 2>&1 & )
  done
  sleep 1; rm -rf "$S" ;;
esac
