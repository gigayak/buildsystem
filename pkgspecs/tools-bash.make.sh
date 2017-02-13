#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd "$YAK_WORKSPACE"
version=4.3.30
echo "$version" > "$YAK_WORKSPACE/version"
url="https://ftp.gnu.org/gnu/bash/bash-$version.tar.gz"
wget "$url"

tar -zxf "bash-$version.tar.gz"
cd bash-*/

# Per CLFS:
#   When Bash is cross-compiled, it cannot test for the presence of named pipes,
#   among other things. If you used su to become an unprivileged user, this
#   combination will cause Bash to build without process substitution, which
#   will break one of the C++ test scripts in glibc. The following prevents
#   future problems by skipping the check for named pipes, as well as other
#   tests that can not run while cross-compiling or that do not run properly.
cat > config.cache << "EOF"
ac_cv_func_mmap_fixed_mapped=yes
ac_cv_func_strcoll_works=yes
ac_cv_func_working_mktime=yes
bash_cv_func_sigsetjmp=present
bash_cv_getcwd_malloc=yes
bash_cv_job_control_missing=present
bash_cv_printf_a_format=yes
bash_cv_sys_named_pipes=present
bash_cv_ulimit_maxfds=yes
bash_cv_under_sys_siglist=yes
bash_cv_unusable_rtsigs=no
gt_cv_int_divbyzero_sigfpe=yes
EOF

# The usual configure / make
./configure \
  --prefix="/tools/${YAK_TARGET_ARCH}" \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET" \
  --without-bash-malloc \
  --cache-file=config.cache

make
