#!/usr/bin/env bash

### Remote Pairing Machine bootstrap

set -ev

PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# Create user accounts
sudo useradd dev -m -s /bin/bash -G sudo,adm,dialout,cdrom,floppy,audio,dip,video,plugdev,admin

sudo -i -u dev ssh-keygen -f /home/dev/.ssh/id_rsa -t rsa -C "dev@pairingmachine" -P \"\"\"\"\"

# Add multiverse repositories (for EC2 tools)
sudo perl -p -i -e 's/universe/universe multiverse/go' /etc/apt/sources.list

# Update packages
sudo apt-get update

# Databases
sudo apt-get install -y postgresql postgresql-client

# source control
sudo apt-get install -y git-core

# Misc development tools and native libraries
sudo apt-get install -y tmux zsh

# Ruby
sudo apt-get install -y ruby-full

# Rubygems
if ! [ -e /usr/bin/gem ]; then
    (
        cd /tmp
        wget http://production.cf.rubygems.org/rubygems/rubygems-1.5.2.tgz
        tar xzf rubygems-1.5.2.tgz
        cd rubygems-1.5.2
        sudo ruby setup.rb
        cd /usr/bin
        sudo ln -s gem1.8 gem
    )
fi

# RVM
if ! [ -e ~pair/.rvm ]; then
    (
        cd /tmp
        curl -L https://get.rvm.io | sudo -i -u dev bash -s stable
    )
fi

# .bashrc for the "dev" user
cat <<'EOF' > /tmp/new_bashrc

# Local executables
PATH=$PATH:~/bin

# Ruby Version Manager (RVM)
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
EOF

# Login message
cat <<'EOF' > /tmp/motd

    OMG, hi there!!1!

    This machine should be all set for a great pairing session.

    Don't forget to terminate this instance when you're done.

    Have fun! <3 <3 <3

EOF

sudo mv /tmp/motd /etc/

# Enable password-less `sudo` for the users in the "sudo" group:
cat <<'EOF' > /tmp/new_sudoers

# Enable password-less sudo for all users in the "sudo" group
%sudo ALL=NOPASSWD: ALL

EOF
sudo sh -c 'cat /tmp/new_sudoers >> /etc/sudoers'