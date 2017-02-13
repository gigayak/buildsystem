# Installation

* Find a machine you don't care about.
* Install Ubuntu 14.04 LTS.
* Log in as root (yeah, it doesn't build as anything but root...).
* Install optional development tools: `apt-get install tmux vim`
* Install required tools: `apt-get install git lxc bridge-utils`
* `git config --global user.email 'john@jgilik.com'`
* `git config --global user.name 'John Gilik'`
* `git clone "https://github.com/gigayak/linux"`
* `cd linux`
* `./bootstrap.sh --domain="test.example.com" --architecture=x86_64`

