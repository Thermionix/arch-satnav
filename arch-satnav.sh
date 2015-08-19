#!/bin/bash

set -e

if [ $(id -u) = 0 ]; then
	echo "Don't run as root!"
	exit 1
fi

sudo pacman -Sy --noconfirm haveged
sudo systemctl enable haveged
sudo systemctl start haveged

if ! command -v pacaur ; then
	echo "## Installing pacaur AUR Helper"

	sudo pacman -Sy --noconfirm --needed wget base-devel

	if ! grep -q "EDITOR" ~/.bashrc ; then 
		echo "export EDITOR=\"nano\"" >> ~/.bashrc
	fi

	#sed -i -e "/^#keyserver-options auto-key-retrieve/s/#//" ~/.gnupg/gpg.conf
	curl https://aur.archlinux.org/cgit/aur.git/snapshot/cower.tar.gz | tar -zx
	pushd cower
	makepkg -s PKGBUILD --install --noconfirm --ignorearch --skippgpcheck
	popd
	rm -rf cower

	curl https://aur.archlinux.org/cgit/aur.git/snapshot/pacaur.tar.gz | tar -zx
	pushd pacaur
	makepkg -s PKGBUILD --install --noconfirm
	popd
	rm -rf pacaur
fi

echo "Defaults passwd_timeout=0" | sudo tee /etc/sudoers.d/timeout
echo 'Defaults editor=/usr/bin/nano, !env_editor' | sudo tee /etc/sudoers.d/nano

sudo pacman -S --noconfirm xorg-server xorg-server-utils xorg-xinit mesa

echo "## installing video driver fbdev"
sudo pacman -S --noconfirm xf86-video-fbdev

echo "## Installing Fonts"
sudo pacman -S --noconfirm ttf-droid ttf-liberation ttf-dejavu


username=`whoami`
echo "## enabling autologin for user: $username"
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
echo -e "[Service]\nExecStart=\nExecStart=-/usr/bin/agetty --autologin $username --noclear %I 38400 linux" \
	| sudo tee /etc/systemd/system/getty@tty1.service.d/autologin.conf



echo "## enabling X Autostart"
if ! grep -q "exec startx" ~/.bash_profile ; then 
	test -f /home/$username/.bash_profile || cp /etc/skel/.bash_profile ~/.bash_profile
	echo "[[ -z \$DISPLAY && \$XDG_VTNR -eq 1 ]] && exec startx" >> ~/.bash_profile
fi



cat <<-'EOF' | sudo tee /etc/systemd/system/paccache-clean.timer
[Unit]
Description=Clean pacman cache weekly

[Timer]
OnBootSec=10min
OnCalendar=weekly
Persistent=true     
 
[Install]
WantedBy=timers.target
EOF

cat <<-'EOF' | sudo tee /etc/systemd/system/paccache-clean.service
[Unit]
Description=Clean pacman cache

[Service]
Type=oneshot
ExecStart=/usr/bin/paccache -rk2
ExecStart=/usr/bin/paccache -ruk0
EOF

sudo systemctl enable paccache-clean.timer



sudo pacman -S --noconfirm enlightenment xterm
echo "exec enlightenment_start" > ~/.xinitrc



sudo pacman -S --noconfirm gpsd

#sudo pacman -S gpsdrive
pacaur -S navit
#pacaur -S roadnav
#pacaur -S qmapshack
#pacaur -S foxtrotgps
#pacaur -S modRana

