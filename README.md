# ARSnova Vagrant

*Note: This project is work in progress.*

This Vagrant configuration will provision a Debian development box with all tools required by ARSnova.

## Goal

Developers should not need to install any tools in order to get ARSnova up and running. Ideally, the only thing they will need is an IDE. All other tools as well as the required workflows shall be handled by the Vagrant box.

## Current State

This box is based on Debian Wheezy and Puppet 3. Currently, ARSnova is checked out, built via Maven, and is ready run with Jetty.

Get started with the following commands:

	$ vagrant init fadenb/debian-wheezy-puppet3
	$ vagrant up

This will create a completely configured VM. However, the first start will take quite some time to finish. Once the machine is up and running, you can connect with `vagrant ssh`.

To be continued...