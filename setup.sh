#!/bin/bash

confirm () {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case $response in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}

echo "This script will delete your local *.rc files and replace them with my own."

mkdir -p ~/backup_rc

echo "About to delete .bashrc and replace it with symlink."
confirm && mv -f ~/.bashrc ~/backup_rc; rm -f ~/.bashrc; ln -s ~/smkleinrc/bash/bashrc ~/.bashrc

echo "About to delete .vimrc and replace it with symlink."
confirm && mv -f ~/.vimrc ~/backup_rc; rm -f ~/.vimrc; ln -s ~/smkleinrc/vim/vimrc ~/.vimrc

echo "About to delete .tmux and replace it with symlink."
confirm && mv -f ~/.tmux.conf ~/backup_rc; rm -f ~/.tmux.conf; ln -s ~/smkleinrc/tmux/tmux.conf ~/.tmux.conf

mkdir -p ~/.vim
echo "Pulling sources into .vim/bundle."
confirm && rm -rf ~/.vim/bundle
mkdir -p ~/.vim/bundle
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

echo "Installing plugins"
vim +PluginInstall +qall

echo "Replacing .vim/syntax with symlink."
confirm && rm -rf ~/.vim/syntax; ln -s ~/smkleinrc/.vim/syntax ~/.vim/syntax

