#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	cargo             \
	libxcursor        \
	libxi             \
	libxkbcommon      \
	libxkbcommon-x11

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-opengl --prefer-nano

# Comment this out if you need an AUR package
make-aur-package zenity-rs-bin

# If the application needs to be manually built that has to be done down here
echo "Building photocraft..."
echo "---------------------------------------------------------------"
git clone https://github.com/storytold/photocraft.git ./photocraft && (
	cd ./photocraft

	TAG=$(git tag --sort=-v:refname | grep -vi 'rc\|alpha\|beta' | head -1)
	git checkout "$TAG"
	echo "${TAG#v}" > ~/version

	export CARGO_PROFILE_RELEASE_LTO=thin
	export CARGO_PROFILE_RELEASE_PANIC=abort
	cargo build --locked --release -p photocraft -p photocraft-cli

	cp -v ./target/release/photocraft ./target/release/photocraft-cli /usr/bin
	chmod +x /usr/bin/photocraft /usr/bin/photocraft-cli
	cp -v ./packaging/linux/ai.storyteller.photocraft.desktop /usr/share/applications
	mkdir -p /usr/share/icons
	cp -rv ./assets/app-icon/hicolor /usr/share/icons
)
