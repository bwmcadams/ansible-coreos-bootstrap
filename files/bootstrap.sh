#/bin/bash

set -e

cd

if [[ -e $HOME/.bootstrapped ]]; then
  exit 0
fi

PYPY_VERSION=5.6

if [[ -e $HOME/pypy2-v$PYPY_VERSION-linux64.tar.bz2 ]]; then
  tar -xjf $HOME/pypy2-v$PYPY_VERSION-linux64.tar.bz2
  rm -rf $HOME/pypy2-v$PYPY_VERSION-linux64.tar.bz2
else
  wget -O - https://bitbucket.org/squeaky/portable-pypy/downloads/pypy-$PYPY_VERSION-linux_x86_64-portable.tar.bz2 | tar -xjf -
fi

# remove, because otherwise this version will get placed into a subdir of an existing pypy/
rm -rf pypy
mv -f pypy-$PYPY_VERSION-linux_x86_64-portable pypy

## library fixup
mkdir -p pypy/lib
ln -snf /lib64/libncurses.so.5.9 $HOME/pypy/lib/libtinfo.so.5

mkdir -p $HOME/bin

cat > $HOME/bin/python <<EOF
#!/bin/bash
PYTHONPATH=/home/core/pypy/lib-python/2.7/:$PYTHONPATH LD_LIBRARY_PATH=$HOME/pypy/lib:$LD_LIBRARY_PATH exec $HOME/pypy/bin/pypy "\$@"
EOF

chmod 755 $HOME/bin/python
$HOME/bin/python --version
$HOME/bin/python -m ensurepip

cat > $HOME/bin/pip <<EOF
#!/bin/bash
LD_LIBRARY_PATH=$HOME/pypy/lib:$LD_LIBRARY_PATH $HOME/pypy/bin/\$(basename \$0) \$@
EOF

chmod 755 $HOME/bin/pip

# Link into /usr/bin because a lot of ansible stuff is ignoring ansible_python_interpreter
ln -s $HOME/bin/python /usr/bin/python
chmod 755 /usr/bin/python
ln -s $HOME/bin/pip /usr/bin/pip
chmod 755 /usr/bin/pip
