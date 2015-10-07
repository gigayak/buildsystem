# Gigayak Linux #

This is an incomplete [XKCD927-compliant](https://xkcd.com/927) Linux
distribution.


## What? ##

This is a Linux distribution.  It consists of:

* a buildsystem
* a package manager,
* some shell scripts to automate creation of LXC containers
* build scripts for packages required to run Linux
* shell scripts to create CD and HDD images containing built packages
  with an appropriate bootloader installed in the boot sector
* lots of comments containing the word `TODO`


## Does it run in production? ##

No.  Don't expect to use it in production for some time.


## Why would you release an incomplete project? ##

The shell scripts wrapping Linux containers (LXC) have proven to be
somewhat useful.


## Why would you do this? ##

I wanted a distribution that:

* is well tested
* is free of systemd
* makes upstream releases available fairly quickly
* has minimal distribution specific cruft

Maybe this distribution will get there.


## How is it different? ##

The following planned features are somewhat less common amongst current
Linux distributions:

* Automated, native integration tests in the build system.  These will allow
  you to chase the bleeding edge without worrying too much about your entire
  system becoming corrupted.
* No `systemd`.  System V init used.  Server boot times are long: nobody
  should care if getting from a bootloader to a usable shell takes 30 seconds
  less when getting past POST requires 10 minutes.  System V init is fairly
  simple to understand.
* Immutable, file-based packaging.  This should bring lots of performance
  advantages to a containerized environment: a package filesystem could be
  built, allowing containers to be created with no need to copy files around.
  This enables near-instant container creation.

## How can you install it? ##

"Easy" (with air-quotes):

* find a machine you don't care about
* install Red Hat Enterprise Linux 6 or CentOS 6
* no, really - do this on a clean machine / VM - it will trample your
  network settings, start services, and in general make a huge mess
* log in as `root`
* seriously reconsider doing this
* run `yum install -y git lxc bridge-utils`
* run `git clone https://github.com/jgilik/gigayak-linux`
* run `cd gigayak-linux`
* run `./buildall.sh`
* run `./create_network.sh`
* run `./create_all_containers.sh`
* run `./lfs.stage1.sh`
* assume 10.0.0.42 is an available IP on your local subnet - if it is
  not, change it to one when you run this: `export IP=10.0.0.42`
* run `./lfs.stage2.create_iso_image.sh
  --ip_address=$IP --mac_address="$(./create_mac.sh)"
  --output_path=/var/www/html/tgzrepo/stage2.iso`
* find a second machine you don't care about, or reuse the first machine
  you don't care about if you're feeling brave and/or silly
* make sure it is connected to a subnet for which `$IP` is a valid IP to
  communicate with
* boot the resulting ISO (either burn it or insert over virtual media if
  you have a DRAC/iLO/IPMI card)
* log in as `root`
* act shocked at not needing a password
* run `install-jpgl` (*WARNING*: this destroys the first hard disk it
  detects with absolutely no confirmation required - do *NOT* run this on a
  machine you care about)
* reboot without CD-ROM image present
* run `/tools/i686/bin/buildsystem/lfs.stage3.sh`
* ???
* **TODO**: actually finish this project
* ???
* profit (good luck)

These directions are untested, and as a result, likely to be  pretty broken.
Therefore, be warned: here there be dragons.  Or yaks.  Or something.

**TODO:** Move this section into its own document and test it.


## When was this all built? ##

`git log` indicates that development began in February 2015.
