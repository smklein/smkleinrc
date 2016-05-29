#!/bin/bash
set -u
set -e

# It is important that this is set correctly...
export SMKLEINRC_PATH="/home/smklein/smkleinrc"

# Configure git stuff
git config --global user.email seanmarionklein@gmail.com
git config --global user.name "Sean Klein"
git config --global credential.helper 'cache --timeout=36000'

unamestr=`uname`
if [[ "$unamestr" == "Linux" ]]; then
    echo "Running LINUX, eh?"
    sudo apt-get install cmake vim-gnome python2.7-dev direnv clang llvm tmux
elif [[ "$unamestr" == "Darwin" ]]; then
    echo "Running MAC OS, eh?"
    echo "TODO -- brew install some fun stuff"
else
    echo "Unknown OS"
    exit 1
fi

confirm () {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [yY/nN/Control c to quit]} " response
    case $response in
        [yY])
            true
            ;;
        *)
            false
            ;;
    esac
}

backup () {
    if [ -z "$1" ]; then
        echo "Backing up a file requires an input..."
        exit 1
    fi
    if [ -f "$1" ]; then
      mv -f "$1" ${HOME}/backup_rc || true
    fi
}

echo "   ~~~ SETTING UP ~~~   "
echo "I think the smkleinrc is >>> [$SMKLEINRC_PATH] <<< "
if [ -d "${SMKLEINRC_PATH}" ]; then
  echo "It seems to be a directory, do you want to use it as the source of truth?";
  confirm
  if [ ! $? ]; then
    exit 1
  fi
else
  echo "Not a valid directory";
  exit 1
fi

function install_rc_files () {
  echo "   ~~~ INSTALLING *.RC FILES ~~~   "
  echo "This script will delete your local *.rc files and replace them with my own."

  rm -rf ~/backup_rc
  mkdir -p ~/backup_rc

  echo "About to delete .bashrc and replace it with symlink."
  backup ~/.bashrc; rm -f ~/.bashrc; ln -s ${SMKLEINRC_PATH}/bash/bashrc ~/.bashrc

  echo "About to delete .vimrc and replace it with symlink."
  backup ~/.vimrc; rm -f ~/.vimrc; ln -s ${SMKLEINRC_PATH}/vim/vimrc ~/.vimrc
  echo "About to delete .ycm_extra_conf.py and replace it with symlink."
  backup ~/.ycm_extra_conf.py; rm -f ~/.ycm_extra_conf.py; ln -s ${SMKLEINRC_PATH}/vim/ycm_extra_conf.py ~/.ycm_extra_conf.py

  echo "About to delete .tmux and replace it with symlink."
  backup ~/.tmux.conf; rm -f ~/.tmux.conf; ln -s ${SMKLEINRC_PATH}/tmux/tmux.conf ~/.tmux.conf
  # I'm not going to bother confirming for the weirder tmux files we might want...
  rm -f ~/.tmux_pre_2.1.conf; ln -s ${SMKLEINRC_PATH}/tmux/tmux_pre_2.1.conf ~/.tmux_pre_2.1.conf
  rm -f ~/.tmux_post_2.1.conf; ln -s ${SMKLEINRC_PATH}/tmux/tmux_post_2.1.conf ~/.tmux_post_2.1.conf
  rm -f ~/.load_tmux_conf.sh; ln -s ${SMKLEINRC_PATH}/tmux/load_tmux_conf.sh ~/.load_tmux_conf.sh

  mkdir -p ~/.vim

  if [ -d ~/.vim/bundle/Vundle.vim ]; then
    echo "You already have Vundle, no need to clone it."
  else
    echo "Pulling sources into .vim/bundle."
    confirm && rm -rf ~/.vim/bundle
    mkdir -p ~/.vim/bundle
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  fi

  echo "Install Vundle plugins"
  confirm && vim +PluginInstall +qall

  echo "Install YCM"
  cd .  # Yeah, this is weird, but we want OLDPWD to be set for the 'cd -' later.
  confirm && cd ~/.vim/bundle/YouCompleteMe && ./install.py --clang-completer
  cd -

  echo "Replacing .vim/syntax with symlink."
  rm -rf ~/.vim/syntax; ln -s ${SMKLEINRC_PATH}/.vim/syntax ~/.vim/syntax
}

echo "Want me to re-install rc files?"
confirm && install_rc_files

function install_git_repos () {
  echo "   ~~~ INSTALLING GITHUB REPOS ~~~   "
  if [ -z "${GITHUB_PATH:-}" ]; then
    export GITHUB_PATH="${HOME}/repos"
  fi
  echo "I think the github dump is >>> [$GITHUB_PATH] <<< "
  echo "Do you want to use it as a git dumping ground?"
  mkdir -p ${GITHUB_PATH}
  confirm
  if [ ! $? ]; then
    exit 1
  fi

  function install_one_git_repo() {
    if [ -d ${GITHUB_PATH}/$1 ]; then
      echo "   Already installed: $1"
    else
      git clone $2 ${GITHUB_PATH}/$1
    fi

  }
  install_one_git_repo private https://github.com/smklein/private.git
  install_one_git_repo blog https://github.com/smklein/smklein.github.io.git
}

echo "Want me to re-install git repos?"
confirm && install_git_repos
