# Dependency Schema

Ultimately have a configuration language issue here: each package has a
"configuration file" specifying what packages it requires to satisfy
its dependencies.  If we go crazy, this sort of stuff can easily become
Yet Another Turing Complete Configuration Language.

Might be ideal to consider what sort of requirements this language would
have, and try to find a pre-existing one that works.

Ideally:

  * Language would be the same for specifying dependencies satisfied and
    specifying desired dependencies.
  * Very cross-platform (rules out proto3, which requires recent
    autoconf)
  * Can be handled by a shell script somewhat easily.
  * Backwards-compatible with simple case (name as bare string a la "sed")

In the spirit of not over-engineering, is there a string-based solution
which would work?  What sort of dependencies can be expected?

  * arch doesn't matter
  * arch is host architecture
  * arch is one of 'alpha', 'darwin', or 'cheese'
  * arch is one of host architecture or 'cheese'
  * arch is host architecture and one of 'alpha', 'darwin', or 'cheese'
  * arch is host architecture and not one of 'alpha', 'darwin', or 'cheese'
  * arch is any architecture except 'alpha', 'darwin', or 'cheese'
  * arch matches '*86' <== does this matter?  or is it just x86 / x64
  * arch matches '*86' except 'weirdnotintel111086' <== see above

Most of these are on the "what dependencies does this pkg satisfy" side.
"What dependencies does it need?" is limited to:

  * host distro, host arch, specific name
  * host distro, specific arch, specific name
  * specific distro, host arch, specific name
  * specific distro, specific arch, specific name

Always will call for a specific arch or distro if specifying one, except
for the multilib case.  Even then, it's likely going to be x86_64 host
requesting a 32-bit library.

Does multilib make sense for the future?  Can I say "no" and revisit
this design later if I change my mind?

If the main complexity is in a package acknowledging whether it can build
for a particular target arch/distro pair on a given host arch/distro
pair, then that can be left for build time and evaluated in another
script.

Builds that are *significantly* different between target architectures,
distributions, or host arch/distros, can have a script sit in front of
the package specs providing the parameters to pkg.from_spec.sh.  This
provides a good amount of flexibility and matches current patterns-ish.

Lastly: actual dependency schema...

Two formats:

  1. Backwards-compatible: "name" - just the name, implies host attributes
  2. New: "arch-distro:name", where:

    * name cannot contain ':'
    * arch and distro cannot contain '-' or ':'

