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

mkdir -p backup_rc

echo "About to delete .bashrc and replace it with symlink."
confirm && mv -f ~/.bashrc backup_rc && ln -s ~/smkleinrc/bash/bashrc

echo "About to delete .vimrc and replace it with symlink."
confirm && mv -f ~/.vimrc backup_rc && ln -s ~/smkleinrc/vim/vimrc

mkdir -p .vim
echo "Replacing .vim/bundle with symlink."
confirm && rm -rf ~/.vim/bundle && ln -s ~/smkleinrc/.vim/bundle

echo "Replacing .vim/syntax with symlink."
confirm && rm -rf ~/.vim/syntax && ln -s ~/smkleinrc/.vim/syntax

