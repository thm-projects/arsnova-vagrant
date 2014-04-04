# ARSnova Vagrant

*Note: This project is work in progress.*

This Vagrant configuration will provision a Debian development box with all tools required for ARSnova.

## Goal

Developers should not need to install any tools in order to get ARSnova up and running. Ideally, the only thing they will need is an IDE. All other tools as well as the required workflows shall be handled by the Vagrant box.

## Getting Started

This repository comes with several Git submodules. These can be automatically checked out while cloning by providing the `--recursive` flag:

	git clone --recursive git://scm.thm.de/commana/arsnova-vagrant.git

Alternatively, initialize and update the submodules after cloning:

	git submodule update --init --recursive

## Usage

Start the machine with the following command:

	$ vagrant up

This will create a completely configured VM. Running this the first time will download and install all required packages.  Depending on your internet connection this operation will take some time. Once the machine is up and running, you can connect with:

	$ vagrant ssh

Then, in order to start ARSnova, type:

	% ./start.sh

This will build and start ARSnova. You can now visit http://localhost:8080/index.html in your browser.

Finally, if you want to stop ARSnova, use this command:

	% ./stop.sh

## Is it any good?

Yes.

## Todo

- [ ] Write "Contributing" section
- [ ] Add a license
- [ ] Fix tty error
- [ ] Prepare for publishing
