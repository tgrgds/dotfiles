#!/bin/bash

## Set theme and update package manager

echo "Moving and setting themes"
cp -r .themes ~/.themes
xfconf-query -c xsettings -p /Net/ThemeName -s "Fluent-round-Dark-compact"
xfconf-query -c xsettings -p /Net/IconThemeName -s "elementary Xfce dark"

echo "Updating apt..."
sudo apt update

## PURGE SOME UN-WANTED PACKAGES

PURGE_LIST=(
  gnome-mines
  gnome-sudoku
  mate-calc
  parole
  pidgin
  sgt-puzzles
  xfce4-verve-plugin/focal
  xfce4-screensaver
  xfce4-taskmanager
)
DELETED=()
for package_name in ${PURGE_LIST[@]}; do
  if sudo apt list --installed | grep -q "^\<$package_name\>"; then
    echo "removing $package_name..."
    sleep .5
    sudo apt-get purge --auto-remove "$package_name" -y
    echo "Removed $package_name and its dependencies"
    DELETED+=($package_name)
  else
    echo "$package_name was not removed, as it is not installed."
  fi
done

## INSTALL WANTED PACKAGES

PACKAGE_LIST=(
  ranger
  htop
  neofetch
  tree
  picom
  python3
  i3
  curl
  code
  git-all
  libssl-dev
  pkg-config
  build-essential
)

NEW=()
EXIST=()

for package_name in ${PACKAGE_LIST[@]}; do
  if ! sudo apt list --installed | grep -q "^\<$package_name\>"; then
    echo "installing $package_name..."
    sleep .5
    sudo apt-get install "$package_name" -y
    echo "$package_name installed"
    NEW+=($package_name)
  else
    echo "$package_name already installed"
    EXIST+=($package_name)
  fi
done

## INSTALL PACKGES FROM SOURCE
if ! nvm; then
  echo "Installing NVM"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
else
  echo "Node Version Manager (nvm) is already installed"
  NPMV=$(nvm -v)
  echo "$NPMV"
fi

## PRINT FOR USE WHAT HAS HAPPENED

echo -en "\nNew packages installed:\n"
for value in "${NEW[@]}"
do
  echo $value"\n"
done  

echo -en "\nPackages That Already Existed:\n"
for value in "${EXIST[@]}"
do
  echo $value"\n"
done  

echo -en "\nDeleted packages:\n"
for value in "${DELETED[@]}"
do
  echo $value "\n"
done  


## MOVE CONFIG FILES
echo "Moving config files..."
mv picom.conf ~/.config/picom.conf
#mv terminalrc ~/.config/xfce4/terminal/terminalrc
mv .bashrc ~
mv .bash_aliases ~
mv .vscode/settings.json ~/.config/Code/User/settings.json
cp -r i3 ~/.config/
cp -r xfce4 ~/.config/

mkdir ~/Icons
mv hal.png ~/Icons

# Symlink configs back to here
# so we can commit whatever we change later
# TODO
echo "Creating symlinks..."
ln ~/.config/picom.conf picom.conf
ln ~/.config/xfce4/terminal/terminalrc terminalrc
ln ~/.bashrc .bashrc
ln ~/.bash_aliases .bash_aliases
ln ~/.config/Code/User/settings.json .vscode/settings.json

echo "Done :)"
