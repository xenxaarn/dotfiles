# [Tokyo Night](https://github.com/rejarevaldy/dotfiles/tree/master/Tokyo-Night) for XFCE

Fork of rejarevaldy's Tokyo Night dotfiles, adapted for XFCE and for baking into an immutable image
([Ella](https://github.com/xenxaarn/ella)).

<p align="center">
        <img src="/screenshot/SST1.png" />
</p>

## Install (system-wide, build time)

```sh
sudo ./install.sh --system            # /usr + /etc
DESTDIR=/tmp/root ./install.sh --system   # staging
```

Installs the TokyoNight GTK2/GTK3/xfwm4 theme, Tela-circle-blue(-dark) icons (built from upstream), Plank theme + dock defaults,
wallpaper, xfconf defaults (`/etc/xdg/xfce4/...`), oh-my-bash (pinned) and per-user defaults in `/etc/skel`.
Existing users: `cp -rn /etc/skel/. ~/` and remove `~/.config/xfce4/xfconf/xfce-perchannel-xml/{xsettings,xfwm4,xfce4-panel}.xml` first.

Re-capture the panel/dock after tweaking them on a live session: `./capture.sh`.

Requires: `plank dconf gtk-update-icon-cache git`, fonts Inter, JetBrains Mono, Inconsolata.
GTK theme is GPL (see `Tokyo-Night/.themes/TokyoNight/COPYING`); Tela icons are GPL-3.0 (fetched from vinceliuice/Tela-circle-icon-theme at build time).
