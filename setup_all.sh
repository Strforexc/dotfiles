#!/usr/bin/env zsh

set -e          # Exit on error
set -o pipefail # Exit on pipe error
set -x          # Enable verbosity


# Dont link DS_Store files
find . -name ".DS_Store" -exec rm {} \;

PROGRAMS=( bash env git python scripts  tmux  zsh vim gui)
# PROGRAMS=(alias aspell bash env git latex python scripts stow tmux vim zsh mac terminal)
OLD_DOTFILES="dotfile_bk_$(date -u +"%Y%m%d%H%M%S")"
mkdir $OLD_DOTFILES

function backup_if_exists() {
    if [ -f $1 ];
    then
      mv $1 $OLD_DOTFILES
    fi
    if [ -d $1 ];
    then
      mv $1 $OLD_DOTFILES
    fi
}

function rm_if_exists() {
    if [ -f $1 ];
    then
      rm $1
    fi
}

# Clean common conflicts
backup_if_exists ~/.bash_profile
backup_if_exists ~/.bashrc
backup_if_exists ~/.zshrc
backup_if_exists ~/.gitconfig
backup_if_exists ~/.tmux.conf
backup_if_exists ~/.profile
backup_if_exists ~/.zshenv

mkdir -p ~/.vim/undodir

for f in ~/.zprezto/runcoms/z*
do
    mv "$f" $OLD_DOTFILES
done

for program in ${PROGRAMS[@]}; do
  stow -v --target=$HOME $program
  echo "Configuring $program"
done

setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/[a-z]*; do
    rm_if_exists "${ZDOTDIR:-$HOME}/.${rcfile:t}"
    ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done

echo "Done!"
