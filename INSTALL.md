# Installation

* Find a machine you don't care about.
* Install Ubuntu 14.04 LTS.
* Log in as root (yeah, it doesn't build as anything but root...).
* Install optional development tools: `apt-get install tmux vim`
* Install required tools: `apt-get install git lxc bridge-utils`
* `git clone "https://github.com/gigayak/linux"`
* `cd linux`
* `./bootstrap.sh --domain="test.example.com" --architecture=x86_64`
* Use `dd` to copy the resulting image from `/var/www/html/tgzrepo/stage3.raw`
  to a victim drive of your choice - or boot that image in a VM, and use
  `install-gigayak <target device>` to install a minimal installation on the
  specified drive.
