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
- Filled selector gaps for GNOME Shell 40–47 (authentication list, screen recording/sharing indicators, calendar events, Looking Glass, message actions, etc.).
- Added the missing libadwaita 1.4+ color definitions (`sidebar_*`, `secondary_sidebar_*`, `thumbnail_*`).

## Installation

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

### Fix for Xfce Whiskermenu black background

Open Whiskermenu setting and set the background opacity to 0