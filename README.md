EC2 Remote Pairing Machine Bootstrap
====================================

The goal is to bootstrap an EC2 instance that's setup nicely for a remote
pairing session.

Inspired by a few other projects:
https://github.com/stuartsierra/pairhost
https://syme.herokuapp.com/

What you do
-----------

You're going to be the one to setup the EC2 instance, so you'll first need to
signup for Amazon AWS and get that all going. Then you'll want to launch a
Ubuntu instance and grab both the .pem file and the hostname.

From there you'll want to scp the bootstrap script over to the new instance.

Next ssh into the new instance and run the bootstrap.

You should now be able to ssh back into the machine as a user named dev.

What your pair does
-------------------

All your pair should have to do is ssh as that same user (dev) and then join
your tmux session.

Port forwarding
---------------

Need to figure out how to forward ports from the EC2 machine to local so that
you can see the Rails app locally.
