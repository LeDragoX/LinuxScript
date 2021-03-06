#!/bin/bash

function initVariables {

    # Initialize Global variables

    clear
    app_num=0
    total_apps=10

    default_browser="microsoft-edge"
    config_folder="PKGSConfig"
    script_folder=$(pwd)
    wait_time=7

    echo "
    app_num         = $app_num
    total_apps      = $total_apps

    default_browser = $default_browser
    config_folder   = $config_folder
    script_folder   = $script_folder
    wait_time       = $wait_time
    "

    echo ""
    read -t $wait_time -p "Waiting $wait_time seconds only ..."
    echo ""

}

function superEcho {
    echo ""
    echo "<==================== $1 ====================>"
    echo ""
}

function installCounter {
    superEcho "( $((app_num+=1))/$total_apps ) Installing: [$1]"
}

function setUpEnv {

    clear
    # 1 - Preparing the files location

    mkdir ~/$config_folder
    cd ~/$config_folder
    
    # Making folders for Custom Themes
    mkdir ~/.icons

    timedatectl set-local-rtc 1 # Using Local time (Dualboot with Windows)
    #sudo timedatectl set-timezone UTC # Using UTC

    # 2 - Fix currently installed Packages

    printf "[Adapted] Ubuntu fix broken packages (best solution)\n"
    sudo apt update -y --fix-missing
    sudo dpkg --configure -a            # Attempts to fix problems with broken dependencies between program packages.
    sudo apt-get --fix-broken install

}

function setUpGit {
    # 3 - Set Up Git Commits Signature (Verified)

    # Install Git first
    sudo apt install -fy git
    
    pushd ~/.gnupg
        # Import GPG keys
        gpg --import *.asc
        # Get the exact key ID from the system
        # Code adapted from: https://stackoverflow.com/a/66242583        # My key name
        keyID=$(gpg --list-signatures --with-colons | grep 'sig' | grep 'plinio' | head -n 1 | cut -d':' -f5)
        git config --global user.signingkey $keyID
        # Always commit with GPG signature
        git config --global commit.gpgsign true
    popd
}

function installPackages {

    # 4 - Install Apt Packages

    sudo dpkg --add-architecture i386                                               # Enable 32-bits Architecture
    sudo DEBIAN_FRONTEND=noninteractive apt install -fy ubuntu-restricted-extras    # Remove interactivity | Useful proprietary stuff

    declare -a apt_pkgs=(

        # Initial Libs that i use

        "adb"           # Android Debugging
        "curl"          # Terminal Download Manager
        "fastboot"      # Android Debugging
        "gdebi"         # CLI/GUI .deb Installer
        "gdebi-core"    # CLI/GUI .deb Installer
        "htop"          # Terminal System Monitor
        "neofetch"      # Neofetch Command
        "vim"           # Terminal Text Editor
        "wget"          # Terminal Download Manager

        # Programming languages for devlopment

        "python3-pip"   # Python 3 pip
    )

    printf "\nInstalling via Advanced Package Tool (apt)...\n"
    for App in ${apt_pkgs[@]}; do
        printf "\nInstalling: $App \n"
        sudo apt install -y $App
    done

    # Check Python version
    python3 --version
    pip3 --version

    # Ruby and Rails via RVM
    gpg --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
    \curl -sSL https://get.rvm.io | bash -s stable --ruby
    source ~/.rvm/scripts/rvm
    \curl -sSL https://get.rvm.io | bash -s stable --rails
    rvm -v # Check RVM version
    ruby -v # Check RUBY version

    rvm install 3.0.0
    rvm use 3.0.0 --default
    rvm requirements

    # NodeJS & NPM
    curl -sL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
    node -v
    npm -v
    # Yarn for NodeJS
    sudo npm install --global yarn
    yarn --version

}

function installZsh {

    # 5 - Install Zsh

    printf "Zsh install\n"
    sudo apt install -fy zsh
    printf "Make Zsh the default shell\n"
    chsh -s $(which zsh)
    $SHELL --version

    printf "Needs to log out and log in to make the changes\n"
    echo $SHELL

    printf "Oh My Zsh\n"
    sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"

}

function updateAll {

    # 6 - Update System

    sudo apt update -y
    sudo apt dist-upgrade -fy
    sudo apt autoclean -y       # limpa seu repositório local de todos os pacotes que o APT baixou.
    sudo apt autoremove -y      # remove dependências que não são mais necessárias ao seu Sistema.

}

initVariables
setUpEnv

setUpGit
installPackages
installZsh
updateAll