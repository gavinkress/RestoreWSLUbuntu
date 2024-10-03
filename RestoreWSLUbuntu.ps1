'''
____________________________________________________________________
--------------------------------------------------------------------
# Fully Configurable Bsckup snd Restore Script for WSL Distributions
_____________________________________________________________________
---------------------------------------------------------------------

- Name: WSLVersionControl
- Homepage: https://github.com/gavinkress/WSLVersionControl
- Author: Gavin Kress
- email: gavinkress@gmail.com
- Date: 9/30/2024
- version: 1.0.0
- readme: WSLVersionControl.md
- Programming Language(s): Python, C++, R, Bash, Powershelll
- License: MIT License
- Operating System: OS Independent

----------------------------------------------------------------
## Follow Instructions, do not blindly run code
----------------------------------------------------------------

This workflow will ensure your WSL Distrubution configurations will
carry over as much as possible when the need to create a new 
image arises. 

For most use cases you simply specify your parameters and run
others will need more detailed modifications.


## Dependencies: *Manually Install the following*
--------------------------------------------------------------------------------
- [Install WSL for VSCode](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl)
'''


### Fresh Install Ubuntu
### ---------------------
wsl --unregister Ubuntu
wsl --uninstall
wsl --install --pre-release
exit
$UBUNTU_HOME= "//wsl$/Ubuntu/home/gavin/"
wsl --shutdown



### Update WSL .config
### ------------------
$filetext = @"
[wsl2]
guiApplications=true
memory=64GB # Limits VM memory to 64GB
"@
Remove-Item $env:USERPROFILE/.wslconfig
echo $filetext >>$env:USERPROFILE/.wslconfig
wsl --shutdown

# ------------------------------------------------
# CONFIGURE BASHRC HERE - SEE END OF SCRIPT
# ----------------------------------------------
### At minimum add the following to your .bashrc or run

# Custom functions
function Complete_Upgrade() {
    sudo apt --fix-broken install
    sudo apt full-upgrade -y
    sudo apt update -y
    sudo apt upgrade -y
    sudo apt upgrade python3
    sudo apt --fix-broken install
    
}
export -f Complete_Upgrade


### install Ubuntu libraries
### -------------------------
cd ~/
wsl


cd ~/

#### ensure your ubuntu pro token is set to UBUNTU_ONE_TOKEN if you want pro features
sudo pro attatch $UBUNTU_ONE_TOKEN
sudo pro enable cc-eal --assume-yes
sudo pro enable esm-apps --assume-yes
sudo pro enable esm-infra --assume-yes
sudo pro enable livepatch --assume-yes
sudo pro enable usg --assume-yes


Complete_Upgrade
sudo apt install dc python3 mesa-utils vlc gimp gedit libquadmath0 libgtk2.0-0 firefox libgomp1 smartmontools wget ca-certificates gnome-text-editor gedit x11-apps nautilus pulseaudio libquadmath0 libgomp1 firefox 
sudo snap install vlc gimp gedit pulseaudio mesa-utils
Complete_Upgrade
sudo apt install dc python3 mesa-utils libquadmath0 libgtk2.0-0 firefox libgomp1 smartmontools wget ca-certificates gnome-text-editor gedit x11-apps nautilus pulseaudio libquadmath0 libgomp1 vlc gimp gedit pulseaudio firefox
Complete_Upgrade
mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm ~/miniconda3/miniconda.sh
Complete_Upgrade

exit 
wsl --shutdown


### Verify Image Health *ONLY RUN IF NEEDED*
### ----------------------------------------

arr1=($(df -Th | awk '{print $1}' | sort -u))
for loc in "${arr1[@]}" # ignore
do 
    sudo e2fsck $loc -p
    sudo e2fsck $loc -y
    #### optional
    #sudo umount /$loc
    #sudo e2fsck $loc -p
    #sudo e2fsck $loc -y
    #sudo mount /$loc
    #sudo mount -o remount,rw /$loc
    #sudo chown -R %USERPROFILE% /$loc
    #sudo chmod -R u+w /$loc
    #sudo chattr -i /$loc
done

sudo df
clear
sudo dmesg | sort -u
sudo journalctl -xe | sort -u

### CUSTOM INSTALLATION WORKFLOWS *Manually Modify based on your needs*
### -------------------------------------------------------------------

#### Download most recent version of fslinstaller and install fsl
#### ------------------------------------------------------------

cd ~/
wget https://fsl.fmrib.ox.ac.uk/fsldownloads/fslconda/releases/fslinstaller.py -O ~/fslinstaller.py
sudo rm -rf ~/fsl
sudo python3 fslinstaller.py --extra truenet

#### Validate Installation with tests
#### ----------------------------------
echo $FSLDIR
fslmaths
imcp
fsl &
fsleyes -std &
exit


#### RCyPy Assistant from W11 package
#### ----------------------------------
setx $FSLDIR= "//wsl$/Ubuntu-$version_n/home/gavin/fsl/"
cd ~/
$RCyPyVenv_dir = "~/OneDrive/Centralized Programming Heirarchy/.env/.virtualenvs/RCyPyVenv"
if (Test-Path -Path $RCyPyVenv_dir) {
    cd $RCyPyVenv_dir
    ./scripts/activate
    pip install fsl_mrs
    fsl_mrs_verify
}


# Create and build BASH RC File *YOU MUST MODIFY THIS AND ADD TO BASHRC MANUALLY
## ----------------------------------------------------------------------------------------

bashrctext = @"



# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Custom functions
function Complete_Upgrade() {
    sudo apt --fix-broken install
    sudo apt full-upgrade -y
    sudo apt update -y
    sudo apt upgrade -y
    sudo apt upgrade python3
    sudo apt --fix-broken install
    
}
export -f Complete_Upgrade

# FSL Setup
#FSLDIR=~/fsl
#PATH=${PATH}:${FSLDIR}/share/fsl/bin
#export FSLDIR PATH
#. ${FSLDIR}/etc/fslconf/fsl.sh
#setting port to connect to third parter graphics server such as vcxsrv or xming launched by xlaunch
#this is no longer needed due to native wsl graphics integration "wslg"
#export DISPLAY=$(route.exe print | grep 0.0.0.0 | head -1 | awk '{print $4}'):0.0
#export LIBGL_ALWAYS_INDIRECT=1

#Freesurfer Setup
#FS_LICENSE=/home/gavin/license.txt
#XDG_RUNTIME_DIR=/home/gavin/.xdg
#FREESURFER_HOME=/usr/local/freesurfer/7.4.1
#PATH=${PATH}:${FREESURFER_HOME}/share/bin
#export FS_LICENSE FREESURFER_HOME XDG_RUNTIME_DIR PATH


"@
