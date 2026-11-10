## Lavanda gtk theme

![Lavanda](screenshot-01.png?raw=true)
![Lavanda-sea](screenshot-02.png?raw=true)

## Requirements

- GTK `>=3.20`
- `gnome-themes-extra` (or `gnome-themes-standard`)
- Murrine engine — The package name depends on the distro.
  - `gtk-engine-murrine` on Arch Linux
  - `gtk-murrine-engine` on Fedora
  - `gtk2-engine-murrine` on openSUSE
  - `gtk2-engines-murrine` on Debian, Ubuntu, etc.
- `sassc` — build dependency

- `Icon theme` [Colloid](https://github.com/vinceliuice/Colloid-icon-theme)

- `Wallpaper` [Download here](wallpaper)

## Compatibility

- GNOME Shell 3.28–51
  - 48–50: `widgets-48-0` styles
  - 51+: `widgets-51-0` styles, including the redesigned login/lock screen, authentication method menu and Web login (QR code)
- GTK 2, GTK 3.20+, GTK 4
- libadwaita 1.4+ color variables (sidebars, secondary sidebars, thumbnails)

### Recent compatibility work

- Added GNOME Shell 48–51 support; 48–50 share the `48-0` branch, 51+ uses the new `51-0` branch.
- GNOME Shell 51: new login/lock screen layout, authentication method menu, Web login view and QR code.
- 1.1.0: added `install-freebsd.sh`, a standalone POSIX `sh` installer for FreeBSD with per-user installs and automatic GNOME Shell detection.
- 1.0.3: fixed GNOME Shell 51 lock-screen media notifications (`.message`), login prompt layout, panel status indicator spacing and the light panel border.
- `build.sh` now selects the GNOME Shell style branch automatically, matching `install.sh`.
- Filled selector gaps for GNOME Shell 40–47 (authentication list, screen recording/sharing indicators, calendar events, Looking Glass, message actions, etc.).
- Added the missing libadwaita 1.4+ color definitions (`sidebar_*`, `secondary_sidebar_*`, `thumbnail_*`).

## Installation

### Copr (Fedora / EPEL)

The theme is packaged and built on Copr in the `ruojiner/lavanda-kde-theme` project:

```sh
sudo dnf copr enable ruojiner/lavanda-kde-theme
sudo dnf install lavanda-gtk-theme
```

The RPM runs `install.sh` after installation, compiling and installing all
variants for the GNOME Shell version present on the system. `sassc` is pulled
in automatically as a dependency. Available for Fedora 44, Fedora 45 and
EPEL 10 (x86_64).

To remove it:

```sh
sudo dnf remove lavanda-gtk-theme
```

### Manual Installation

Run the following commands in the terminal:

```sh
./install.sh
```

> Tip: `./install.sh` allows the following options:

```
-d, --dest DIR          Specify destination directory (Default: $HOME/.themes)
-n, --name NAME         Specify theme name (Default: Lavanda)
-t, --theme VARIANT     Specify theme variant [standard|sea] (Default: all variants)
-c, --color VARIANT     Specify color variant(s) [standard|light|dark] (Default: All variants)
-s, --size VARIANT      Specify size variant [standard|compact] (Default: standard variant)
-i, --icon VARIANT      Specify logo icon on nautilus [default|apple|manjaro|ubuntu|fedora|debian|arch|gnome|budgie|popos|gentoo|void|zorin|mxlinux|opensuse|tux] (Default: dot icon)

-l, --libadwaita        Link installed gtk-4.0 theme to config folder for all libadwaita app use this theme

-r, --remove,
-u, --uninstall         Uninstall/Remove installed themes or links

-h, --help              Show help
```

> For more information, run: `./install.sh --help`

### FreeBSD

`install-freebsd.sh` is a standalone POSIX `sh` installer for FreeBSD (no bash
required, does not call `build.sh`/`install.sh`):

```sh
sudo pkg install sassc
./install-freebsd.sh
```

It installs per-user into `$XDG_DATA_HOME/themes` or `~/.themes`, accepts the
same options as `install.sh`, and skips the GNOME Shell theme when
`gnome-shell` is not installed. For example:

```sh
./install-freebsd.sh -t sea -c dark -s compact
./install-freebsd.sh -u
```

### GDM login screen

`./install.sh` installs into `~/.themes` (or `/usr/share/themes` when run as
root), which themes the user session and its lock screen. The GDM greeter runs
in its own session and does not read user themes, so the login screen is not
themed automatically. To theme it, install as root and configure GDM to use the
theme (the exact mechanism is distribution-specific), or copy the generated
`gnome-shell/gnome-shell.css` into the greeter's shell theme directory.

### Fix for Xfce Whiskermenu black background

Open Whiskermenu setting and set the background opacity to 0