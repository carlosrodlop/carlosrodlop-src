#!/bin/sh
# https://dev.to/arctic_hen7/setting-up-zsh-in-docker-263f

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Source Antigen
source ~/.antigen/antigen.zsh
autoload -U colors && colors
setopt promptsubst
# Set up oh-my-zsh
antigen use oh-my-zsh
# Set up plugins
antigen bundle git
antigen bundle docker
antigen bundle asdf
# Set up our preferred theme
antigen theme cloud
# Run all that config
antigen apply

# Set up Ctrl + Backspace and Ctrl + Del so you can move around and backspace faster (try it!)
#bindkey '^H' backward-kill-word
#bindkey -M emacs '^[[3;5~' kill-word

# Set up aliases
alias cl="clear"
alias x="exit"
alias k="kubectl"
alias t="terraform"
