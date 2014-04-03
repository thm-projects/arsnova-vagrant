# ARSnova Vagrant

*Note: This project is work in progress.*

This Vagrant configuration will provision a Debian development box with all tools required for ARSnova.

## Goal

Developers should not need to install any tools in order to get ARSnova up and running. Ideally, the only thing they will need is an IDE. All other tools as well as the required workflows shall be handled by the Vagrant box.

## Current State

This box is based on Debian Wheezy and Puppet 3. Currently, ARSnova is checked out, built via Maven, and is ready run with Jetty.

Get started with the following command:

	$ vagrant up

This will create a completely configured VM. Running this the first time will download and install all required packages.  Depending on your internet connection this operation will take some time. Once the machine is up and running, you can connect with:

	$ vagrant ssh

Then, in order to start ARSnova, type:

	% ./start.sh

This will build and start ARSnova. You can now visit http://localhost:8080/index.html in your browser.

To be continued...

### TODO:

- [x] Add a `stop.sh` script
- [x] Enable port forwarding for Web Sockets
- [ ] Add a motd with a short description of the important commands
