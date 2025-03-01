#!/bin/zsh
env >/tmp/sketchybar_env.txt
source $HOME/.zshrc
cpout 1

sketchybar --animate sin 7 --set clipboard icon.color.alpha=0.5 icon.color.alpha=1.0
