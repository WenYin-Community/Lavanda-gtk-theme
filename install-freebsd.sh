#!/bin/sh
#
# Lavanda GTK theme installer for FreeBSD.
#
# Standalone POSIX sh script (FreeBSD /bin/sh + BSD sed). It does not call
# build.sh or install.sh. Themes are installed per-user by default:
#   $XDG_DATA_HOME/themes, else ~/.themes, else ~/.local/share/themes.
# GNOME Shell styles are skipped when gnome-shell is not installed.

REPO_DIR=$(CDPATH= cd -P "$(dirname "$0")" && pwd)
SRC_DIR="${REPO_DIR}/src"

SASSC_OPT="-M -t expanded"

THEME_NAME=Lavanda
THEME_VARIANTS="standard sea"
COLOR_VARIANTS="standard light dark"
SIZE_VARIANTS="standard compact"

icon=default
uninstall=
libadwaita=
_name=
dest=
compact_flag=
themes=
colors=
lcolors=
sizes=
has_gnome_shell=false
gs_version=

# Destination directory: per-user install by default.
resolve_home() {
  if [ "$(id -u)" -eq 0 ] && [ -n "${SUDO_USER:-}" ]; then
    if command -v getent >/dev/null 2>&1; then
      getent passwd "$SUDO_USER" | cut -d: -f6
    else
      eval "printf '%s' ~${SUDO_USER}"
    fi
  else
    printf '%s' "$HOME"
  fi
}

USER_HOME=$(resolve_home)

if [ -n "${XDG_DATA_HOME:-}" ]; then
  DEST_DIR="${XDG_DATA_HOME}/themes"
elif [ -d "${USER_HOME}/.themes" ]; then
  DEST_DIR="${USER_HOME}/.themes"
elif [ -d "${USER_HOME}/.local/share/themes" ]; then
  DEST_DIR="${USER_HOME}/.local/share/themes"
else
  DEST_DIR="${USER_HOME}/.themes"
fi

if [ "$(id -u)" -eq 0 ] && [ -z "${SUDO_USER:-}" ]; then
  printf 'WARNING: running as root, themes will be installed to %s.\n' "$DEST_DIR" >&2
  printf 'Run as a normal user for a per-user install, or use -d DIR.\n' >&2
fi

usage() {
  cat <<EOF
Usage: $0 [OPTION]...

Lavanda GTK theme installer for FreeBSD (per-user by default).

OPTIONS:
  -d, --dest DIR          Specify destination directory (Default: $DEST_DIR)

  -n, --name NAME         Specify theme name (Default: $THEME_NAME)

  -t, --theme VARIANT     Specify theme variant [standard|sea] (Default: all variants)

  -c, --color VARIANT     Specify color variant(s) [standard|light|dark] (Default: all variants)

  -s, --size VARIANT      Specify size variant [standard|compact] (Default: standard variant)

  -i, --icon VARIANT      Specify logo icon on nautilus [default|apple|manjaro|ubuntu|fedora|debian|arch|gnome|budgie|popos|gentoo|void|zorin|mxlinux|opensuse|tux] (Default: default icon)

  -l, --libadwaita        Link installed gtk-4.0 theme to config folder for all libadwaita app use this theme

  -r, --remove,
  -u, --uninstall         Uninstall/Remove installed themes or links

  -h, --help              Show help
EOF
}

theme_suffix() {
  case "$1" in
    sea) printf '%s' '-Sea' ;;
    *) printf '%s' '' ;;
  esac
}

color_suffix() {
  case "$1" in
    light) printf '%s' '-Light' ;;
    dark) printf '%s' '-Dark' ;;
    *) printf '%s' '' ;;
  esac
}

size_suffix() {
  case "$1" in
    compact) printf '%s' '-Compact' ;;
    *) printf '%s' '' ;;
  esac
}

options_temp() {
  cp -f "${SRC_DIR}/sass/_options.scss" "${SRC_DIR}/sass/_options-temp.scss"
  cp -f "${SRC_DIR}/sass/gnome-shell/_options.scss" "${SRC_DIR}/sass/gnome-shell/_options-temp.scss"
}

compact_size() {
  sed -i '' '/\$compact:/s/false/true/' "${SRC_DIR}/sass/_options-temp.scss"
  sed -i '' '/\$compact:/s/false/true/' "${SRC_DIR}/sass/gnome-shell/_options-temp.scss"
}

theme_options() {
  options_temp
  if [ "$compact_flag" = true ]; then
    compact_size
  fi
}

gnome_shell_version() {
  cp -f "${SRC_DIR}/sass/gnome-shell/_common.scss" "${SRC_DIR}/sass/gnome-shell/_common-temp.scss"
  sed -i '' "/widgets/s/40-0/${gs_version}/" "${SRC_DIR}/sass/gnome-shell/_common-temp.scss"
  case "$gs_version" in
    3-28)
      sed -i '' '/extensions/s/40-0/3-28/' "${SRC_DIR}/sass/gnome-shell/_common-temp.scss"
      ;;
    46-0|48-0|51-0)
      sed -i '' '/extensions/s/40-0/46-0/' "${SRC_DIR}/sass/gnome-shell/_common-temp.scss"
      ;;
  esac
}

install_one() {
  local dest_dir=$1
  local name=$2
  local theme=$3
  local color=$4
  local size=$5
  local icon_name=$6
  local else_light=
  local else_dark=

  [ "$color" = '-Light' ] && else_light=$color
  [ "$color" = '-Dark' ] && else_dark=$color

  local theme_dir="${dest_dir}/${name}${theme}${color}${size}"

  [ -d "$theme_dir" ] && rm -rf "$theme_dir"

  printf "Installing '%s'...\n" "$theme_dir"

  theme_options

  mkdir -p "$theme_dir"

  cat > "${theme_dir}/index.theme" <<EOF
[Desktop Entry]
Type=X-GNOME-Metatheme
Name=${name}${theme}${color}${size}
Comment=An Clean Gtk+ theme based on Elegant Design
Encoding=UTF-8

[X-GNOME-Metatheme]
GtkTheme=${name}${theme}${color}${size}
MetacityTheme=${name}${theme}${color}${size}
IconTheme=Tela-circle${else_dark}
CursorTheme=${name}-cursors
ButtonLayout=close,minimize,maximize:menu
EOF

  if [ "$has_gnome_shell" = true ]; then
    mkdir -p "${theme_dir}/gnome-shell"
    cp -r "${SRC_DIR}/main/gnome-shell/pad-osd.css" "${theme_dir}/gnome-shell"
    sassc $SASSC_OPT "${SRC_DIR}/main/gnome-shell/gnome-shell${theme}${color}.scss" "${theme_dir}/gnome-shell/gnome-shell.css" || return 1

    cp -r "${SRC_DIR}/assets/gnome-shell/common-assets" "${theme_dir}/gnome-shell/assets"
    cp -r "${SRC_DIR}/assets/gnome-shell/assets${else_dark}/"*.svg "${theme_dir}/gnome-shell/assets"
    cp -r "${SRC_DIR}/assets/gnome-shell/theme-assets${theme}/"*.svg "${theme_dir}/gnome-shell/assets"

    if [ -f "${SRC_DIR}/assets/gnome-shell/activities${else_dark}/activities-${icon_name}.svg" ]; then
      cp -r "${SRC_DIR}/assets/gnome-shell/activities${else_dark}/activities-${icon_name}.svg" "${theme_dir}/gnome-shell/assets/activities.svg"
      cp -r "${SRC_DIR}/assets/gnome-shell/activities-Dark/activities-${icon_name}.svg" "${theme_dir}/gnome-shell/assets/activities-white.svg"
    else
      printf '%s icon not supported, default icon will install...\n' "$icon_name"
      cp -r "${SRC_DIR}/assets/gnome-shell/activities${else_dark}/activities-default.svg" "${theme_dir}/gnome-shell/assets/activities.svg"
    fi

    (
      cd "${theme_dir}/gnome-shell" || exit 1
      ln -s assets/no-events.svg no-events.svg
      ln -s assets/process-working.svg process-working.svg
      ln -s assets/no-notifications.svg no-notifications.svg
    )
  fi

  mkdir -p "${theme_dir}/gtk-2.0"
  cp -r "${SRC_DIR}/main/gtk-2.0/gtkrc${else_dark}" "${theme_dir}/gtk-2.0/gtkrc"
  cp -r "${SRC_DIR}/main/gtk-2.0/common/"*.rc "${theme_dir}/gtk-2.0"
  cp -r "${SRC_DIR}/assets/gtk-2.0/assets-common${else_dark}" "${theme_dir}/gtk-2.0/assets"
  cp -r "${SRC_DIR}/assets/gtk-2.0/assets${theme}/"*png "${theme_dir}/gtk-2.0/assets"

  mkdir -p "${theme_dir}/gtk-3.0"
  cp -r "${SRC_DIR}/assets/gtk/assets${theme}" "${theme_dir}/gtk-3.0/assets"
  cp -r "${SRC_DIR}/assets/gtk/scalable" "${theme_dir}/gtk-3.0/assets"
  cp -r "${SRC_DIR}/assets/gtk/thumbnails/thumbnail${theme}${else_dark}.png" "${theme_dir}/gtk-3.0/thumbnail.png"
  sassc $SASSC_OPT "${SRC_DIR}/main/gtk-3.0/gtk${theme}${color}.scss" "${theme_dir}/gtk-3.0/gtk.css" || return 1
  sassc $SASSC_OPT "${SRC_DIR}/main/gtk-3.0/gtk${theme}-Dark.scss" "${theme_dir}/gtk-3.0/gtk-dark.css" || return 1

  mkdir -p "${theme_dir}/gtk-4.0"
  cp -r "${SRC_DIR}/assets/gtk/assets${theme}" "${theme_dir}/gtk-4.0/assets"
  cp -r "${SRC_DIR}/assets/gtk/scalable" "${theme_dir}/gtk-4.0/assets"
  cp -r "${SRC_DIR}/assets/gtk/thumbnails/thumbnail${theme}${else_dark}.png" "${theme_dir}/gtk-4.0/thumbnail.png"
  sassc $SASSC_OPT "${SRC_DIR}/main/gtk-4.0/gtk${theme}${color}.scss" "${theme_dir}/gtk-4.0/gtk.css" || return 1
  sassc $SASSC_OPT "${SRC_DIR}/main/gtk-4.0/gtk${theme}-Dark.scss" "${theme_dir}/gtk-4.0/gtk-dark.css" || return 1

  mkdir -p "${theme_dir}/cinnamon"
  cp -r "${SRC_DIR}/assets/cinnamon/common-assets" "${theme_dir}/cinnamon/assets"
  cp -r "${SRC_DIR}/assets/cinnamon/assets${else_dark}/"*.svg "${theme_dir}/cinnamon/assets"
  cp -r "${SRC_DIR}/assets/cinnamon/theme-assets${theme}/"*.svg "${theme_dir}/cinnamon/assets"
  sassc $SASSC_OPT "${SRC_DIR}/main/cinnamon/cinnamon${theme}${color}.scss" "${theme_dir}/cinnamon/cinnamon.css" || return 1
  cp -r "${SRC_DIR}/assets/cinnamon/thumbnails/thumbnail${theme}${color}.png" "${theme_dir}/cinnamon/thumbnail.png"

  mkdir -p "${theme_dir}/metacity-1"
  cp -r "${SRC_DIR}/main/metacity-1/metacity-theme-3.xml" "${theme_dir}/metacity-1/metacity-theme-3.xml"
  cp -r "${SRC_DIR}/assets/metacity-1/assets" "${theme_dir}/metacity-1/assets"
  cp -r "${SRC_DIR}/assets/metacity-1/thumbnail${else_dark}.png" "${theme_dir}/metacity-1/thumbnail.png"
  (
    cd "${theme_dir}/metacity-1" || exit 1
    ln -s metacity-theme-3.xml metacity-theme-1.xml
    ln -s metacity-theme-3.xml metacity-theme-2.xml
  )

  mkdir -p "${theme_dir}/xfwm4"
  cp -r "${SRC_DIR}/assets/xfwm4/assets${theme}${else_light}/"*.png "${theme_dir}/xfwm4"
  cp -r "${SRC_DIR}/main/xfwm4/themerc${else_light}" "${theme_dir}/xfwm4/themerc"
  mkdir -p "${theme_dir}-hdpi/xfwm4"
  cp -r "${SRC_DIR}/assets/xfwm4/assets${theme}${else_light}-hdpi/"*.png "${theme_dir}-hdpi/xfwm4"
  cp -r "${SRC_DIR}/main/xfwm4/themerc${else_light}" "${theme_dir}-hdpi/xfwm4/themerc"
  sed -i '' 's/button_offset=6/button_offset=9/' "${theme_dir}-hdpi/xfwm4/themerc"
  mkdir -p "${theme_dir}-xhdpi/xfwm4"
  cp -r "${SRC_DIR}/assets/xfwm4/assets${theme}${else_light}-xhdpi/"*.png "${theme_dir}-xhdpi/xfwm4"
  cp -r "${SRC_DIR}/main/xfwm4/themerc${else_light}" "${theme_dir}-xhdpi/xfwm4/themerc"
  sed -i '' 's/button_offset=6/button_offset=12/' "${theme_dir}-xhdpi/xfwm4/themerc"

  mkdir -p "${theme_dir}/plank"
  if [ "$color" = '-Light' ]; then
    cp -r "${SRC_DIR}/main/plank/theme-Light/"* "${theme_dir}/plank"
  else
    cp -r "${SRC_DIR}/main/plank/theme-Dark/"* "${theme_dir}/plank"
  fi
}

uninstall_link() {
  rm -rf "${USER_HOME}/.config/gtk-4.0/assets" \
         "${USER_HOME}/.config/gtk-4.0/gtk.css" \
         "${USER_HOME}/.config/gtk-4.0/gtk-dark.css"
}

link_libadwaita() {
  local dest_dir=$1
  local name=$2
  local theme=$3
  local color=$4
  local size=$5
  local theme_dir="${dest_dir}/${name}${theme}${color}${size}"

  printf "\nLink '%s/gtk-4.0' to '%s/.config/gtk-4.0' for libadwaita...\n" "$theme_dir" "$USER_HOME"

  mkdir -p "${USER_HOME}/.config/gtk-4.0"
  ln -sf "${theme_dir}/gtk-4.0/assets" "${USER_HOME}/.config/gtk-4.0/assets"
  ln -sf "${theme_dir}/gtk-4.0/gtk.css" "${USER_HOME}/.config/gtk-4.0/gtk.css"
  ln -sf "${theme_dir}/gtk-4.0/gtk-dark.css" "${USER_HOME}/.config/gtk-4.0/gtk-dark.css"
}

link_theme() {
  set -- $themes
  local t=$1
  local ts=$(theme_suffix "$t")

  for c in $lcolors; do
    local cs=$(color_suffix "$c")
    for s in $sizes; do
      local ss=$(size_suffix "$s")
      link_libadwaita "${dest:-$DEST_DIR}" "${_name:-$THEME_NAME}" "$ts" "$cs" "$ss"
    done
  done
}

install_theme() {
  for t in $themes; do
    local ts=$(theme_suffix "$t")
    for c in $colors; do
      local cs=$(color_suffix "$c")
      for s in $sizes; do
        local ss=$(size_suffix "$s")
        install_one "${dest:-$DEST_DIR}" "${_name:-$THEME_NAME}" "$ts" "$cs" "$ss" "$icon" || exit 1
      done
    done
  done
}

uninstall_one() {
  local dest_dir=$1
  local name=$2
  local theme=$3
  local color=$4
  local size=$5
  local theme_dir="${dest_dir}/${name}${theme}${color}${size}"

  if [ -d "$theme_dir" ]; then
    printf 'Uninstall %s...\n' "$theme_dir"
    rm -rf "$theme_dir" "${theme_dir}-hdpi" "${theme_dir}-xhdpi"
  fi
}

uninstall_theme() {
  for t in $THEME_VARIANTS; do
    local ts=$(theme_suffix "$t")
    for c in $COLOR_VARIANTS; do
      local cs=$(color_suffix "$c")
      for s in $SIZE_VARIANTS; do
        local ss=$(size_suffix "$s")
        uninstall_one "${dest:-$DEST_DIR}" "${_name:-$THEME_NAME}" "$ts" "$cs" "$ss"
      done
    done
  done
}

clean_theme() {
  local data_home="${XDG_DATA_HOME:-${USER_HOME}/.local/share}"

  for t in $THEME_VARIANTS; do
    local ts=$(theme_suffix "$t")
    for c in $COLOR_VARIANTS; do
      local cs=$(color_suffix "$c")
      for s in $SIZE_VARIANTS; do
        local ss=$(size_suffix "$s")
        uninstall_one "${data_home}/themes" "${_name:-$THEME_NAME}" "$ts" "$cs" "$ss"
      done
    done
  done
}

xfce4_fix() {
  if command -v xfce4-popup-whiskermenu >/dev/null 2>&1; then
    for rc in "${USER_HOME}"/.config/xfce4/panel/whiskermenu*.rc; do
      [ -f "$rc" ] || continue
      sed -i '' 's|.*menu-opacity=.*|menu-opacity=0|' "$rc"
    done
  fi

  if command -v pgrep >/dev/null 2>&1 && pgrep xfce4-session >/dev/null 2>&1; then
    if command -v xfce4-panel >/dev/null 2>&1; then
      xfce4-panel -r >/dev/null 2>&1 || true
    fi
  fi
}

while [ $# -gt 0 ]; do
  case "$1" in
    -d|--dest)
      [ $# -ge 2 ] || { printf "ERROR: %s requires an argument.\n" "$1" >&2; exit 1; }
      dest=$2
      if [ ! -d "$dest" ]; then
        printf "Destination directory does not exist. Let's make a new one...\n"
        mkdir -p "$dest" || exit 1
      fi
      shift 2
      ;;
    -n|--name)
      [ $# -ge 2 ] || { printf "ERROR: %s requires an argument.\n" "$1" >&2; exit 1; }
      _name=$2
      shift 2
      ;;
    -i|--icon)
      [ $# -ge 2 ] || { printf "ERROR: %s requires an argument.\n" "$1" >&2; exit 1; }
      icon=$2
      printf 'Installing %s icon on panel...\n' "$icon"
      shift 2
      ;;
    -r|--remove|-u|--uninstall)
      uninstall=true
      shift
      ;;
    -l|--libadwaita)
      libadwaita=true
      shift
      ;;
    -t|--theme)
      shift
      while [ $# -gt 0 ]; do
        case "$1" in
          standard|sea)
            themes="${themes}${themes:+ }$1"
            shift
            ;;
          -*) break ;;
          *)
            printf "ERROR: Unrecognized theme variant '%s'.\n" "$1" >&2
            printf "Try '%s --help' for more information.\n" "$0" >&2
            exit 1
            ;;
        esac
      done
      ;;
    -c|--color)
      shift
      while [ $# -gt 0 ]; do
        case "$1" in
          standard|light|dark)
            colors="${colors}${colors:+ }$1"
            lcolors="${lcolors}${lcolors:+ }$1"
            shift
            ;;
          -*) break ;;
          *)
            printf "ERROR: Unrecognized color variant '%s'.\n" "$1" >&2
            printf "Try '%s --help' for more information.\n" "$0" >&2
            exit 1
            ;;
        esac
      done
      ;;
    -s|--size)
      shift
      while [ $# -gt 0 ]; do
        case "$1" in
          standard|compact)
            sizes="${sizes}${sizes:+ }$1"
            [ "$1" = compact ] && compact_flag=true
            shift
            ;;
          -*) break ;;
          *)
            printf "ERROR: Unrecognized size variant '%s'.\n" "$1" >&2
            printf "Try '%s --help' for more information.\n" "$0" >&2
            exit 1
            ;;
        esac
      done
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf "ERROR: Unrecognized installation option '%s'.\n" "$1" >&2
      printf "Try '%s --help' for more information.\n" "$0" >&2
      exit 1
      ;;
  esac
done

[ -n "$themes" ] || themes=$THEME_VARIANTS
[ -n "$colors" ] || colors=$COLOR_VARIANTS
[ -n "$lcolors" ] || lcolors=light
[ -n "$sizes" ] || sizes=standard

if [ "$uninstall" != true ]; then
  if ! command -v sassc >/dev/null 2>&1; then
    printf 'ERROR: sassc is required to generate the CSS.\n' >&2
    printf 'Install it with:\n\n  sudo pkg install sassc\n\n' >&2
    exit 1
  fi
fi

if [ "$uninstall" = true ]; then
  if [ "$libadwaita" = true ]; then
    printf '\nUninstall %s/.config/gtk-4.0 links ...\n' "$USER_HOME"
    uninstall_link
  else
    printf '\n'
    uninstall_theme
    uninstall_link
  fi
else
  # GNOME Shell is optional: only install its theme when the shell exists.
  if command -v gnome-shell >/dev/null 2>&1; then
    has_gnome_shell=true
    shell_version=$(gnome-shell --version 2>/dev/null | cut -d ' ' -f 3 | cut -d . -f 1)
    case "$shell_version" in
      ''|*[!0-9]*) shell_version=51 ;;
    esac
    if [ "$shell_version" -ge 51 ]; then
      gs_version=51-0
    elif [ "$shell_version" -ge 48 ]; then
      gs_version=48-0
    elif [ "$shell_version" -ge 47 ]; then
      gs_version=47-0
    elif [ "$shell_version" -ge 46 ]; then
      gs_version=46-0
    elif [ "$shell_version" -ge 44 ]; then
      gs_version=44-0
    elif [ "$shell_version" -ge 42 ]; then
      gs_version=42-0
    elif [ "$shell_version" -ge 40 ]; then
      gs_version=40-0
    else
      gs_version=3-28
    fi
  else
    printf "'gnome-shell' not found, skipping GNOME Shell theme.\n"
  fi

  if [ "$has_gnome_shell" = true ]; then
    gnome_shell_version
  fi
  clean_theme
  install_theme
  xfce4_fix
  if [ "$libadwaita" = true ]; then
    uninstall_link
    link_theme
  fi
fi

printf '\nDone.\n'
