# shellcheck shell=bash
# shellcheck disable=SC2034 # Shared manifest consumed by the installer and checker.
# Shared Debian 13 package manifest. Sourced by Bash only.
DEBIAN_CORE=(
  hyprland quickshell qt6-shader-baker qt6-base-dev-tools
  qml6-module-qtquick qml6-module-qtquick-controls qml6-module-qtquick-layouts
  qml6-module-qtquick-effects qml6-module-qtquick-shapes qml6-module-qtqml-models
  qml6-module-qtqml-workerscript qml6-module-qt-labs-folderlistmodel qml6-module-qtmultimedia
  libqt6multimedia6 qt6-image-formats-plugins qt6-svg-plugins qt6-wayland
  dbus dbus-user-session polkitd libegl1 libgl1-mesa-dri
  pipewire pipewire-pulse wireplumber pulseaudio-utils network-manager bluez upower power-profiles-daemon
  libnotify-bin wl-clipboard jq curl ca-certificates git xdg-utils xdg-user-dirs fontconfig
  python3 python3-numpy bash coreutils procps
)
DEBIAN_DESKTOP=(
  xwayland xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
  gvfs adwaita-icon-theme fonts-noto-core fonts-noto-cjk fonts-noto-color-emoji
  gnome-keyring libsecret-tools pipewire-alsa qt6ct
)
DEBIAN_FEATURES=(
  cava easyeffects grim slurp cliphist wtype hyprpicker hyprsunset hypridle
  imagemagick tesseract-ocr tesseract-ocr-eng swappy wf-recorder ffmpeg
  brightnessctl ddcutil zenity kitty network-manager-gnome blueman
  dconf-cli libglib2.0-bin x11-xserver-utils sound-theme-freedesktop playerctl
)
DEBIAN_OPTIONAL=(python3-aubio songrec mpvpaper nwg-displays nodejs)
