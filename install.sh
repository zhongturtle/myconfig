#!/bin/bash

# install necessary packages
if [ "$(uname -s)" = "Linux" ]; then
    echo $(uname -s)
    sudo apt-get update
    sudo apt-get --yes --force-yes -f -m install zsh mosh vim tmux bc
    sudo apt-get --yes --force-yes -f -m install git wget python3-dev python3-pip
elif [ "$(uname -s)" = "Darwin" ]; then # mac
    echo $(uname -s)
    # check if brew exists. If not, install it
    hash brew 2>/dev/null || /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew install wget zsh mosh tmux
    brew install git python3-dev python3-pip
else
    echo $(uname -s)
    echo "This OS is not supported yet!"
    exit 0
fi

# git clone every thing
CLONE_PATH=$HOME/myconfig
git clone https://github.com/toosyou/myconfig $CLONE_PATH

# install thefuck if not exists
hash thefuck 2>/dev/null || pip3 install --user thefuck

# link tmux configure
if [ $( echo "$(tmux -V| cut -d" " -f 2| tr -d $'\n'| tr -d $'\r') <= 2.3 " | bc -l ) -eq 1 ];then
    ln -sf $CLONE_PATH/tmux19.conf ~/.tmux.conf
else
    # install tmux-package-manager(TPM)
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm || git -C ~/.tmux/plugins/tpm pull
    ln -sf $CLONE_PATH/tmux.conf ~/.tmux.conf
    # install packages
    ~/.tmux/plugins/tpm/scripts/install_plugins.sh
fi

# get awsome vim configure
git clone https://github.com/amix/vimrc.git ~/.vim_runtime
sh ~/.vim_runtime/install_awesome_vimrc.sh

# install vundle and append vimrc
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
ln -sf $CLONE_PATH/vundle.vim ~/.vundle.vim
sed -i '1isource ~/.vundle.vim\n' ~/.vimrc
vim +PluginInstall +qall # install plugins

# install oh-my-zsh, font, autosuggesion and zsh-syntax-highlighting
ZSH_CUSTOM=~/.oh-my-zsh/custom
# oh-my-zsh
sh -c "`wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O - | sed 's/chsh -s/# chsh -s/g' | sed 's/env zsh/# env zsh/g'`"
wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/templates/zshrc.zsh-template -O ~/.zshrc
# font
mkdir -p $ZSH_CUSTOM/themes
wget -O $ZSH_CUSTOM/themes/bullet-train.zsh-theme https://raw.githubusercontent.com/caiogondim/bullet-train.zsh/master/bullet-train.zsh-theme
sed -i 's/ZSH_THEME=/ZSH_THEME="bullet-train" # /g' ~/.zshrc
# autosuggesion
git clone git://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
sed -i 's/plugins=(/plugins=(zsh-autosuggestions /g' ~/.zshrc
# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
sed -i 's/plugins=(/plugins=(zsh-syntax-highlighting /g' ~/.zshrc
# append .zshrc
echo "source $CLONE_PATH/zshrc" >> ~/.zshrc

# chsh and switch to zsh
USERNAME=`whoami`
printf "Time to change your default shell to zsh!\n"
sudo usermod -s $(grep /zsh$ /etc/shells | tail -1) $USERNAME
env zsh
