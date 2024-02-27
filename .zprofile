#!/bin/zsh

# profile file. Runs on login. Environmental variables are set here.
#.config/shell/profile

# If you don't plan on reverting to bash, you can remove the link in ~/.profile
# to clean up.


export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl"
export PATH="/home/janico/.local/bin:$PATH"
# Adds `~/.local/bin` to $PATH
#export PATH="$PATH:${$(find ~/.local/bin -type d -printf %p:)%%:}"


# Default programs:
export EDITOR="nvim"
export TERMINAL="kitty"
export TERMINAL_PROG="kitty"
export BROWSER="firefox"
export FILE_MANAGER="thunar"

# ~/ Clean-up:
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XINITRC="$XDG_CONFIG_HOME/x11/xinitrc"
export HISTFILE="$XDG_CACHE_HOME/bash/history"
export HISTSIZE=1000
export SAVEHIST=1000
# export GIT_CONFIG="$XDG_CONFIG_HOME/git/config"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc-2.0"
export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"
export INPUTRC="$XDG_CONFIG_HOME/shell/inputrc"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export WINEPREFIX="$XDG_DATA_HOME/wineprefixes/default"
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc"
export SQLITE_HISTORY="$XDG_DATA_HOME/sqlite_history"
export ANDROID_SDK_HOME="$XDG_CONFIG_HOME/android"

# Nvidia
# export _JAVA_AWT_WM_NOREPARENTING=1
# export XDG_SESSION_TYPE=wayland
# export XDG_CURRENT_DESKTOP=Hyprland
# export XDG_SESSION_DESKTOP=Hyprland
export __GLX_VENDOR_LIBRARY_NAME="nvidia"
export GBM_BACKEND="nvidia-drm"

# Bun
export BUN_INSTALL="$HOME/.bun" 
export PATH="$BUN_INSTALL/bin:$PATH"

# IntelliJ
export _JAVA_AWT_WM_NONREPARENTING=1

# Execute startup programs
exec pipewire &
exec dwmblocks &
exec setwallpaper &
exec picom &
exec nm-applet &
exec blueman-applet &
exec pasystray & 
exec flameshot &
# exec keepass-backup
# exec sclayout-monitor-only &

xinput --set-prop 11 'libinput Accel Profile Enabled' 0, 1
xinput --set-prop 11 'libinput Accel Speed' 1
sleep 1 
setxkbmap -option caps:backspace

# Start graphical server on user's current tty if not already running.
# [ "$(tty)" = "/dev/tty1" ] && ! pidof -s Xorg >/dev/null 2>&1 && exec startx "$XINITRC"
