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
confirm && mv -f ~/.bashrc ~/backup_rc; ln -s ~/smkleinrc/bash/bashrc ~/.bashrc

echo "About to delete .vimrc and replace it with symlink."
confirm && mv -f ~/.vimrc ~/backup_rc; ln -s ~/smkleinrc/vim/vimrc ~/.vimrc

mkdir -p .vim
echo "Replacing .vim/bundle with symlink."
confirm && mv -f ~/.vim/bundle ~/backup_rc; ln -s ~/smkleinrc/.vim/bundle ~/.vim/bundle

echo "Replacing .vim/syntax with symlink."
confirm && mv -f ~/.vim/syntax ~/backup_rc; ln -s ~/smkleinrc/.vim/syntax ~/.vim/syntax

