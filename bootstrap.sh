#!/bin/sh
##########################################################################
# Title      :  repair - Remote Pairing and bootstrap
# Author     :  Jon Allured     <jon@jonallured.com>
#            :  Stuart Gerstein <stu@rubyprogrammer.net>
# Date       :  2013-04-25
# Requires   :  Debian on AWS
# Category   :  File Utilities
##########################################################################
# Description
#    o  "repair" simply bootstraps a debian box 
#	for Ruby on Rails hacking and pair programming
#    o  NOTES: This script is for study only at this time
#	DO NOT RUN THIS AT ALL IT WILL SUCK YOUR BRAIN OUT AND PASS IT
#	PAST /etc ONLY TO BE BLUGENDED AND DISCARDED TO /dev/null
# Examples:
#	There are no examples at this time as the script is vapor
#	Hopefully my contribution won't be stillbourne =P
#
##########################################################################

RUSER=dev # THIS NEEDS TO BE SET TO THE REMOTE USER NAME

#set your stacks dependencies and extentions:
db=postgresql:postgresql-client
sc=git-core
m=tmux:zsh
rb=ruby-full

### Remote Pairing Machine bootstrap
RHOME=/home/${RUSER}
TMP=/tmp
PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# Create user accounts
cuser() {
	useradd $RUSER -m -s /bin/bash -G sudo,adm,dialout,cdrom,floppy,audio,dip,video,plugdev,admin,wheel,operator # post postgres compile mod /etc/group 

	kg="ssh-keygen -f ${RHOME}.ssh/id_rsa -t rsa -C 'dev@pairingmachine' -P \"\"\"\"\"" # ooh fun with quoting =) 
	su -m $RUSER -c $kg
}

# Add multiverse repositories (for EC2 tools)
sl=/etc/apt/sources.list
sed 's/[Uu]niverse/& multiverse/g' < $sl > ${TMP}/sl.tmp
mv ${TMP}/sl.tmp $sl

debootstap() {
	p=`tr ':' ' ' <<EOF
	${db}:${sc}:${m}:${rb}
	EOF`
	i=`which apt-get`
	$i update && $i install -y $p
}
`debootstrap`

gstrap() { #Rubygem Bootstrap

	d=/usr/bin
	g=$d/gem
	dl=`which wget`' -O ' # set this to full path to avoid hash conflicts

	f='rubygems-1.5.2.tgz'
	rg="http://production.cf.rubygems.org/rubygems/${f}"

	if [ ! -x $g];
	then
		$dl $rg > ${TMP}/${f}
		# you probably want to set up a checksum check here
		tar -xzf ${TMP}/${f} -C $TMP
		f=${TMP}/`basename -s '.'$(basename -- 'tgz' $f) $f`
		ruby $f/setup.rb
	        ln -s $d/gem1.8 $d/gem
	fi
}

# RVM hmm. This should be a separate user script
# the rest is commented out for future refactor fun!
# 
# if ! [ -e ~pair/.rvm ]; then
#     (
#         cd /tmp
#         curl -L https://get.rvm.io | sudo -i -u dev bash -s stable
#     )
# fi
# 
# # .bashrc for the "dev" user
# cat <<'EOF' > /tmp/new_bashrc
# 
# # Local executables
# PATH=$PATH:~/bin
# 
# # Ruby Version Manager (RVM)
# [[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
# EOF
# 
# # Login message
# cat <<'EOF' > /tmp/motd
# 
#     OMG, hi there!!1!
# 
#     This machine should be all set for a great pairing session.
# 
#     Don't forget to terminate this instance when you're done.
# 
#     Have fun! <3 <3 <3
# 
# EOF
# 
# sudo mv /tmp/motd /etc/
# 
# # Enable password-less `sudo` for the users in the "sudo" group:
# cat <<'EOF' > /tmp/new_sudoers
# 
# # Enable password-less sudo for all users in the "sudo" group
# %sudo ALL=NOPASSWD: ALL
# 
# EOF
# sudo sh -c 'cat /tmp/new_sudoers >> /etc/sudoers'
