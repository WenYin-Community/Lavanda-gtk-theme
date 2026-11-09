#! /usr/bin/env bash

# Check command availability
function has_command() {
  command -v $1 > /dev/null
}

if [ ! "$(which sassc 2> /dev/null)" ]; then
  echo sassc needs to be installed to generate the css.
  if has_command zypper; then
    sudo zypper in sassc
  elif has_command apt; then
    sudo apt install sassc
  elif has_command dnf; then
    sudo dnf install -y sassc
  elif has_command yum; then
    sudo yum install sassc
  elif has_command pacman; then
    sudo pacman -S --noconfirm sassc
  fi
fi

SASSC_OPT="-M -t expanded"

_COLOR_VARIANTS=('' '-Light' '-Dark')
if [ ! -z "${COLOR_VARIANTS:-}" ]; then
  IFS=', ' read -r -a _COLOR_VARIANTS <<< "${COLOR_VARIANTS:-}"
fi

# Pick the GNOME Shell style branch matching the installed shell
if [ "$(command -v gnome-shell)" ]; then
  SHELL_VERSION="$(gnome-shell --version | cut -d ' ' -f 3 | cut -d . -f -1)"
  case "${SHELL_VERSION:-}" in
    ''|*[!0-9]*) SHELL_VERSION=51 ;;
  esac
  if [ "${SHELL_VERSION}" -ge "51" ]; then
    GS_VERSION="51-0"
  elif [ "${SHELL_VERSION}" -ge "48" ]; then
    GS_VERSION="48-0"
  elif [ "${SHELL_VERSION}" -ge "47" ]; then
    GS_VERSION="47-0"
  elif [ "${SHELL_VERSION}" -ge "46" ]; then
    GS_VERSION="46-0"
  elif [ "${SHELL_VERSION}" -ge "44" ]; then
    GS_VERSION="44-0"
  elif [ "${SHELL_VERSION}" -ge "42" ]; then
    GS_VERSION="42-0"
  elif [ "${SHELL_VERSION}" -ge "40" ]; then
    GS_VERSION="40-0"
  else
    GS_VERSION="3-28"
  fi
else
  echo "'gnome-shell' not found, using styles for last gnome-shell version available."
  GS_VERSION="51-0"
fi

cp -rf src/sass/_options.scss src/sass/_options-temp.scss
cp -rf src/sass/gnome-shell/_options.scss src/sass/gnome-shell/_options-temp.scss
cp -rf src/sass/gnome-shell/_common.scss src/sass/gnome-shell/_common-temp.scss
sed -i "/\widgets/s/40-0/${GS_VERSION}/" src/sass/gnome-shell/_common-temp.scss
if [ "${GS_VERSION}" = '3-28' ]; then
  sed -i "/\extensions/s/40-0/3-28/" src/sass/gnome-shell/_common-temp.scss
elif [[ "${GS_VERSION}" -ge '46-0' ]]; then
  sed -i "/\extensions/s/40-0/46-0/" src/sass/gnome-shell/_common-temp.scss
fi

for color in "${_COLOR_VARIANTS[@]}"; do
  sassc $SASSC_OPT src/main/gtk-3.0/gtk${color}.{scss,css}
  echo "==> Generating the 3.0 gtk${color}.css..."
  sassc $SASSC_OPT src/main/gtk-4.0/gtk${color}.{scss,css}
  echo "==> Generating the 4.0 gtk${color}.css..."
  sassc $SASSC_OPT src/main/gnome-shell/gnome-shell${color}.{scss,css}
  echo "==> Generating the gnome-shell${color}.css..."
  sassc $SASSC_OPT src/main/cinnamon/cinnamon${color}.{scss,css}
  echo "==> Generating the cinnamon${color}.css..."
done
