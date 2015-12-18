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

See [INSTALL.md](INSTALL.md).


## When was this all built? ##

`git log` indicates that development began in February 2015.
