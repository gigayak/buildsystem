#!/usr/bin/env python
# TODO: REDO THIS IN GO
# format of diffs is from http://stackoverflow.com/a/12037164
import sys, os, shutil

if len(sys.argv) != 3:
  print "Usage: ... <source_root> <target_root>"
  sys.exit(1)
source_root = sys.argv[1]
target_root = sys.argv[2]

def pardir(d):
  return os.path.abspath(os.path.join(d, '..'))

def noop(s, t, f):
  return

def copy_dir(s, t, f=None):
  """
  Recursively copy this directory and all of its parent directories as needed.
  Takes care to make sure owners and groups are correct.
  """
  # Prefix paths with root in both cases.
  if f is not None:
    s = os.path.join(s, f).strip()
    t = os.path.join(t, f).strip()

  # Stop recursion at the root directory.
  if os.path.normpath(s) == os.path.normpath(source_root):
    return

  # Create missing directories.
  if not os.path.isdir(t):
    if os.path.exists(t):
      raise Exception("target directory '{0}' is a file".format(t))
    if not os.path.isdir(pardir(t)):
      copy_dir(pardir(s), pardir(t))
    print "Creating directory:", t
    os.mkdir(t)

  # Insure correct owner, group, and perms
  s_stat = os.stat(s)
  t_stat = os.stat(t)
  if s_stat.st_uid != t_stat.st_uid or s_stat.st_gid != t_stat.st_gid:
    os.chown(t, s_stat.st_uid, s_stat.st_gid)
  if s_stat.st_mode != t_stat.st_mode:
    os.chmod(t, s_stat.st_mode)

def copy_file(s, t, f):
  """
  Copy an individual file.
  """
  # Prefix file with root in both cases.
  s = os.path.join(s, f).strip()
  t = os.path.join(t, f).strip()

  # Filter out certain files we don't want
  # (This should be arg-controlled!)
  (name, ext) = os.path.splitext(os.path.basename(s))
  if ext in ['.pyc']:
    return

  # hooray.
  if not os.path.isdir(pardir(t)):
    copy_dir(pardir(s), pardir(t))
  print "Copying file:", t
  shutil.copy2(s, t)

def copy_link(s, t, f):
  """
  Copy a symlink.

  Source will be something like
    /tmp/tmp.xZuLzxnzuB/usr/lib/libzmq.so -> libzmq.so.4.0.0
  So, we have to parse it!
  """
  pieces = f.split(' -> ')
  if len(pieces) != 2:
    raise Exception("failed to find two pieces when parsing link spec")
  s = os.path.join(s, pieces[0]).strip()
  t = os.path.join(t, pieces[0]).strip()
  if not os.path.isdir(pardir(t)):
    copy_dir(pardir(s), pardir(t))
  original_link_target = pieces[1]
  link_target = os.readlink(s)
  print "Linking:", t, "->", link_target
  os.symlink(link_target, t)

def copy_device(s, t, f):
  """
  Copy a device inode.
  """
  # Prefix file with root in both cases.
  s = os.path.join(s, f).strip()
  t = os.path.join(t, f).strip()

  # Create parent directories.
  if not os.path.isdir(pardir(t)):
    copy_dir(pardir(s), pardir(t))

  # Copy major/minor dev numbers.
  stat = os.stat(s)
  mode = stat.st_mode
  dev = stat.st_rdev
  os.mknod(t, mode, dev)
  os.chmod(t, stat.st_mode)
  os.chown(t, stat.st_uid, stat.st_gid)
  print "Creating:", t, "as device major =", os.major(dev), "and minor =", os.minor(dev)

def warn_on_permissions(s, t, f):
  """
  Warn when permissions differ (as we're dropping them).
  """
  # TODO: Figure out why this happens during qemu install :(
  print "WARNING: Permissions differ for file {0}".format(f)
  print "This permission change will be lost!"

# Keys can be interpreted by using this page:
#   http://andreafrancia.it/2010/03/understanding-the-output-of-rsync-itemize-changes.html
ops = {
  '.d..t......': noop,
  '.d..T......': noop,
  '.d...p.....': warn_on_permissions,
  'cd+++++++++': copy_dir,
  '>f.s.......': copy_file,
  '.f..t......': noop,
  '>f..t......': copy_file,
  '.f...p.....': warn_on_permissions,
  '.f..T......': noop,
  '>f..T......': copy_file,
  '>f.st......': copy_file,
  '>f.sT......': copy_file,
  '>f+++++++++': copy_file,
  'cL+++++++++': copy_link,
  'cLc.T......': copy_link,
  'cD+++++++++': copy_device,
}
for line in sys.stdin:
  pieces = line.split(" ")
  spec = pieces[0]
  file = ' '.join(pieces[1:])
  if spec not in ops:
    raise Exception("unknown spec {0} for file {1}".format(spec, file))
  ops[spec](
    source_root,
    target_root,
    file,
  )
sys.exit(0)
