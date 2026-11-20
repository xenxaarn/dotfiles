#!/usr/bin/env bash

set -euo pipefail

[[ "${1:-}" == "--system" ]] || {
  echo "usage: [DESTDIR=dir] $0 --system" >&2
  exit 2
}

OMB_REPO=https://github.com/ohmybash/oh-my-bash.git
OMB_REF=${OMB_REF:-94c2977eda06f230aafa9628fcd869123f01896b}
TELA_REPO=https://github.com/vinceliuice/Tela-circle-icon-theme.git
TELA_REF=${TELA_REF:-ee3cf47bcb05c3d99a0860b54254d2ff3d1d2c69}
THEME=TokyoNight
ICONS=Tela-circle-blue-dark

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
T="$SRC/Tokyo-Night"
D="${DESTDIR:-}"
USR="$D/usr" ETC="$D/etc" SKEL="$D/etc/skel"
log() { printf '==> %s\n' "$*"; }

log "GTK2/GTK3/xfwm4 theme"
install -d "$USR/share/themes/$THEME"
cp -a "$T/.themes/$THEME/"{gtk-2.0,gtk-3.0,xfwm4} "$USR/share/themes/$THEME/"
cat >"$USR/share/themes/$THEME/index.theme" <<EOT
[Desktop Entry]
Type=X-GNOME-Metatheme
Name=$THEME
Comment=Tokyo Night GTK/xfwm4 theme
Encoding=UTF-8

[X-GNOME-Metatheme]
GtkTheme=$THEME
MetacityTheme=$THEME
IconTheme=$ICONS
CursorTheme=Adwaita
EOT

log "icons (Tela-circle-blue + -dark from upstream @ ${TELA_REF:0:7}; the dark variant symlinks into the base)"
install -d "$USR/share/icons"
tela="$(mktemp -d)"
git -C "$tela" init -q
git -C "$tela" fetch -q --depth 1 "$TELA_REPO" "$TELA_REF"
git -C "$tela" checkout -q FETCH_HEAD
bash "$tela/install.sh" -d "$USR/share/icons" blue
rm -rf "$tela" "$USR/share/icons/Tela-circle-blue-light"

log "wallpaper, plank theme, first-login helper"
install -Dm644 "$SRC/wallpaper/forest.png" "$USR/share/backgrounds/ella/forest.png"
install -Dm644 "$T/.themes/$THEME/plank/dock.theme" "$USR/share/plank/themes/$THEME/dock.theme"
install -Dm755 "$T/libexec/set-wallpaper" "$USR/libexec/ella/set-wallpaper"
install -Dm644 "$T/.config/fastfetch/logo.txt" "$USR/share/ella/fastfetch-logo.txt"
install -Dm644 /dev/stdin "$ETC/xdg/autostart/ella-wallpaper.desktop" <<'EOT'
[Desktop Entry]
Type=Application
Name=Ella wallpaper
Exec=/usr/libexec/ella/set-wallpaper
OnlyShowIn=XFCE;
EOT
install -Dm644 /dev/stdin "$ETC/xdg/autostart/plank.desktop" <<'EOT'
[Desktop Entry]
Type=Application
Name=Plank
Exec=plank
OnlyShowIn=XFCE;
EOT

log "xfconf defaults (xsettings, xfwm4, panel)"
for f in "$T"/.config/xfce4/xfconf/xfce-perchannel-xml/*.xml; do
  install -Dm644 "$f" "$ETC/xdg/xfce4/xfconf/xfce-perchannel-xml/$(basename "$f")"
done

log "plank dconf defaults"
install -Dm644 "$T/dconf/10-plank" "$ETC/dconf/db/local.d/10-plank"
prof="$ETC/dconf/profile/user"
if [[ ! -e $prof ]]; then
  install -d "$(dirname "$prof")"
  printf 'user-db:user\nsystem-db:local\n' >"$prof"
elif ! grep -qx 'system-db:local' "$prof"; then
  printf 'system-db:local\n' >>"$prof"
fi
if [[ -z "$D" ]]; then dconf update || echo "warn: dconf update failed" >&2; fi

log "skel defaults (new users): terminal, fastfetch, gtk css, bash prompt, dock launchers"
install -Dm644 "$T/.config/xfce4/terminal/terminalrc" "$SKEL/.config/xfce4/terminal/terminalrc"
install -Dm644 "$T/.config/fastfetch/config.jsonc" "$SKEL/.config/fastfetch/config.jsonc"
install -Dm644 "$T/.config/gtk-3.0/gtk.css" "$SKEL/.config/gtk-3.0/gtk.css"
install -Dm644 "$T/.bashrc.d/50-oh-my-bash.sh" "$SKEL/.bashrc.d/50-oh-my-bash.sh"

L="$SKEL/.config/plank/dock1/launchers"
install -d "$L"
mk_item() {
  local name=$1 id
  shift
  for id in "$@"; do
    if [[ -e "$USR/share/applications/$id.desktop" ]]; then
      printf '[PlankDockItemPreferences]\nLauncher=file:///usr/share/applications/%s.desktop\n' "$id" >"$L/$name.dockitem"
      return
    fi
  done
  echo "warn: no desktop file for $name (tried: $*)" >&2
}
mk_item browser firefox org.mozilla.firefox
mk_item files thunar org.xfce.Thunar org.xfce.thunar
mk_item software org.gnome.Software
mk_item terminal xfce4-terminal org.xfce.terminal org.xfce.Terminal
mk_item settings xfce-settings-manager org.xfce.settings.manager

log "oh-my-bash @ ${OMB_REF:0:7}"
omb="$USR/share/oh-my-bash"
rm -rf "$omb"
install -d "$omb"
git -C "$omb" init -q
git -C "$omb" fetch -q --depth 1 "$OMB_REPO" "$OMB_REF"
git -C "$omb" checkout -q FETCH_HEAD
rm -rf "$omb/.git"

log "done"
