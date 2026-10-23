#!/usr/bin/env bash
# Called only for the Debian desktop layer. Do not start a greeter over the installer.
set -euo pipefail
DRY=${1:-0}
if [[ -s /etc/X11/default-display-manager ]]; then
    manager=$(cat /etc/X11/default-display-manager)
    if [[ $manager != /usr/sbin/lightdm ]]; then
        echo "Keeping existing display manager: $manager"
        exit 0
    fi
elif [[ -e /etc/systemd/system/display-manager.service ]]; then
    echo 'Keeping existing display-manager.service'
    exit 0
fi
if [[ $DRY == 1 ]]; then
    echo 'would configure LightDM and graphical.target for next boot'
    exit 0
fi
[[ -f /usr/share/wayland-sessions/hyprland.desktop ]] || { echo 'Hyprland login session missing' >&2; exit 1; }
sudo mkdir -p /etc/lightdm/lightdm.conf.d
printf '[Seat:*]\ngreeter-session=lightdm-gtk-greeter\nuser-session=hyprland\n' | sudo tee /etc/lightdm/lightdm.conf.d/50-sekaipop.conf >/dev/null
printf '/usr/sbin/lightdm\n' | sudo tee /etc/X11/default-display-manager >/dev/null
sudo systemctl enable lightdm.service
sudo systemctl set-default graphical.target
[[ -L /etc/systemd/system/display-manager.service ]] || { echo 'Display manager was not enabled' >&2; exit 1; }
echo 'LightDM enabled for next boot. Reboot and select Hyprland.'
[[ -d /run/systemd/system ]] || echo 'No running systemd: boot links configured; graphical login was not tested.'
