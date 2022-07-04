#!/bin/bash
# Copyright 2019 VMware, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-2
# Modified by Dominik Zorgnotti for TCE appliance


# Shell enhancements

set -euo pipefail

echo -e "\e[92mInstalling Shell Environment ..." > /dev/console

# Install ZSH
tdnf install -y zsh

# Unattended oh-my-zsh installation
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install Powerlin Fonts
git clone https://github.com/powerline/fonts.git --depth=1
cd fonts
./install.sh
cd ..
rm -rf fonts

# Install Powerlevel9k ZSH appearance
git clone --depth=1 https://github.com/romkatv/powerlevel10k ~/.oh-my-zsh/custom/themes/powerlevel10k

# Add Powerlevel9k Theme as well as some appearance optimizations to .zshrc
sed -i '12i ZSH_THEME="powerlevel10k/powerlevel10k"' ~/.zshrc

# Setting aliases in .zshrc
sed -i -e '$aalias k=kubectl' ~/.zshrc
sed -i -e '$aalias c=clear' ~/.zshrc
sed -i -e '$aalias w="watch -n1"' ~/.zshrc

# Add Syntax Highlighting to ZSH
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
sed -i -e 's/^plugins=.*/plugins=(git zsh-syntax-highlighting)/' ~/.zshrc

# ZSH Autocompletion for kubectl
sed -i -e '$aif [ /usr/bin/kubectl ]; then source <(kubectl completion zsh); fi' ~/.zshrc

# Custom Powerline10K config
sed -i -e '$asource ~/.p10k.zsh' ~/.zshrc

# Changing the default shell from bash to zsh
chsh -s $(which zsh)
