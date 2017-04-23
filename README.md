# Gigayak Linux #

This is an [XKCD927-compliant](https://xkcd.com/927) Linux distribution.


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

Depends on definitions.  It's more production-ready than an OS that only boots
in VMs, but much less ready than familiar distributions (such as Ubuntu), which
can be reasonably expected to run on just about anything with a reasonable level
of stability.

It runs on some physical hardware (as opposed to just VMs), but pretty much
every new machine configuration thrown at it reveals missing kernel
configuration flags at this point.  It works on specific physical hardware
configurations, not necessarily all.

Integration of upstream software updates is a slow process today requiring
manual code changes, no central package repository exists, and no automatic
updater exists.  Running this on a public, internet-facing server would probably
be a bad idea, as you can be reasonably certain to be behind on security
updates.

Consider it early alpha quality at this time.


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

The first successful boot (i.e. made it into a userland shell) of the
non-self-hosted distribution was on Friday, January 15, 2016, at 5:46PM
Pacific Time.  This was on i686, in a qemu VM.

The first successful boot of the self-hosted distribution was on Saturday,
September 10, 2016, at 12:33PM Pacific Time.  Again, on i686, and in a qemu VM.

The first successful boot on a different architecture was on Sunday, February
12, 2017, at 9:32PM Pacific Time.  The new architecture was x86_64, and the
boot was again within a qemu VM.

First successful boot on physical hardware was on February 18, 2017, at 12:17AM
Pacific time.  This was on an Acer CB3-131 laptop (Chromebook), running x86_64.
