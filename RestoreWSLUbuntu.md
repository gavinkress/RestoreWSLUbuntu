____________________________________________________________________
--------------------------------------------------------------------
# Fully Configurable Backup and Restore Script for WSL Distributions
_____________________________________________________________________
---------------------------------------------------------------------

- Name: WSLVersionControl
- Homepage: https://github.com/gavinkress/RestoreWSLUbuntu
- Author: Gavin Kress
- email: gavinkress@gmail.com
- Date: 9/30/2024
- version: 1.0.0
- readme: WSLVersionControl.md
- Programming Language(s): Python, Bash, Powershelll
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
- [Install Docker for Windows](https://docs.docker.com/docker-for-windows/install/)

## TO DO
---------

- [ ] verify install and integrate gpu
- [ ] backackup for wsl
- [ ] kali linux

### Fresh Install Ubuntu
-------------------------
```powershell

wsl --unregister Ubuntu-Preview
wsl --unregister Ubuntu
wsl --unregister
wsl --uninstall Ubuntu-Preview
wsl --uninstall Ubuntu
wsl --uninstall
wsl --install --pre-release

exit
wsl --set-default Ubuntu
wsl --update
$UBUNTU_HOME= "//wsl$/Ubuntu/home/gavin/"
wsl --shutdown


```
### Update WSL .config
-----------------------
```powershell

$filetext = @"
[wsl2]
guiApplications=true
memory=64GB # Limits VM memory to 64GB

dnsProxy=false
debugConsole=false
"@
Remove-Item $env:USERPROFILE/.wslconfig
echo $filetext >>$env:USERPROFILE/.wslconfig
wsl --shutdown
```

------------------------------------------------
## Configure bash rc - *see end of workflow*
------------------------------------------------
### At minimum add the following to your .bashrc or run

### Custom functions
```bash
wsl
cd ~/
function Complete_Upgrade() {
    sudo apt --fix-broken install
    sudo apt full-upgrade -y
    sudo apt update -y
    sudo apt upgrade -y
    sudo apt upgrade python3
    sudo apt --fix-broken install
    
}
export -f Complete_Upgrade

PATH=${PATH}:/home/gavin/miniconda3/bin/
export PATH

```

### Install Ubuntu libraries
-----------------------------
```powershell
cd ~/
wsl
```
#### UBUNTU_PRO - Ensure your ubuntu pro token is set to UBUNTU_ONE_TOKEN if you want pro features
UBUNTU_ONE_TOKEN="C13o6aFJfCL54oX52LyreGkaFXGsWx"
export UBUNTU_ONE_TOKEN
```bash
sudo pro attach $UBUNTU_ONE_TOKEN
sudo pro enable cc-eal --assume-yes
sudo pro enable esm-apps --assume-yes
sudo pro enable esm-infra --assume-yes
sudo pro enable livepatch --assume-yes
sudo pro enable usg --assume-yes
```


#### Basic Libraries
```bash
Complete_Upgrade
sudo apt install dc curl python3 libquadmath0 libgtk2.0-0 smartmontools wget ca-certificates gnome-text-editor x11-apps nautilus libgomp1 gimp vlc pulseaudio mesa-utils libblas3 libomp5 liblapack3
```


#### Enable GPU Accelleration (Run one line at a time, read output, may need to manually perform tasks within Docker)
```bash
Complete_Upgrade
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo sed -i -e '/experimental/ s/^#//g' /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
docker run --rm -it --gpus=all nvcr.io/nvidia/k8s/cuda-sample:nbody nbody -gpu -benchmark
```

#### Install Miniconda
```bash
Complete_Upgrade
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
conda create --name directml python=3.7 -y
conoda init


conda activate directml
pip install tensorflow-directml
pip install pytorch-directml

conda activate tfdml_plugin
pip install tensorflow-cpu==2.10
pip install tensorflow-directml-plugin
```


#### Install Microsoft Edge
```bash
Complete_Upgrade
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge-beta.list'
sudo rm microsoft.gpg
sudo apt update
sudo apt install microsoft-edge-beta 
```

#### Ensure Libraries are installed
```bash
Complete_Upgrade
sudo apt install dc curl python3 libquadmath0 libgtk2.0-0 smartmontools wget ca-certificates gnome-text-editor x11-apps nautilus libgomp1 gimp vlc pulseaudio mesa-utils libblas3 libomp5 liblapack3
Complete_Upgrade
exit 
```


```powershell
wsl --shutdown
```

### Cusoom Workflows - *manually Modify based on your needs*
-----------------------------------------------------------------------

#### Download most recent version of fslinstaller and install fsl
------------------------------------------------------------------
```bash
cd ~/

sudo rm -rf ~/fsl
sudo rm -rf /usr/local/fsl
sudo rm ~/fslinstaller.py
wget https://fsl.fmrib.ox.ac.uk/fsldownloads/fslconda/releases/fslinstaller.py -O ~/fslinstaller.py
sudo python3 fslinstaller.py  -d ~/fsl

```

#### Validate Installation with tests (ensure relevant additions to .bashrc)
----------------------------------------------------------------------------
```bash
echo $FSLDIR
fslmaths
imcp
fsl &
fsleyes -std &
exit
```

#### RCyPy Assistant from W11 package
---------------------------------------
```powershell
setx $FSLDIR= "//wsl$/Ubuntu-$version_n/home/gavin/fsl/"
cd ~/
$RCyPyVenv_dir = "~/OneDrive/Centralized Programming Heirarchy/.env/.virtualenvs/RCyPyVenv"
if (Test-Path -Path $RCyPyVenv_dir) {
    cd $RCyPyVenv_dir
    ./scripts/activate
    pip install fsl_mrs
    fsl_mrs_verify
}
```

### Troubleshooting: Verify Image Health - *only run if needed*
---------------------------------------------------------------
```bash
wsl
arr1=($(df -Th | awk '{print $1}' | sort -u))
for loc in "${arr1[@]}" # ignore
do 
    #sudo e2fsck $loc -p
    #sudo e2fsck $loc -y
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
```

## Kali Linux
--------------
```powershell
wsl --install Kali-Linux
sudo apt install python2

```
## Add Complete_Upgrade to .bashrc with python2
```bash
Complete_Upgrade
sudo apt install kali-linux-everything
```

## Example BASH RC File - *Yours will likely be different*
----------------------------------------------------------------------------------

```bash
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
#shopt -s globstar

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
#force_color_prompt=yes

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
FSLDIR=~/fsl
PATH=${PATH}:${FSLDIR}/share/fsl/bin
export FSLDIR PATH
. ${FSLDIR}/etc/fslconf/fsl.sh
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

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/gavin/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/gavin/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/gavin/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/gavin/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<



```

