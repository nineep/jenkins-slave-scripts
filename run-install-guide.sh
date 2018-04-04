#!/bin/bash -xe

# This script is used to publish project-specific install-guide
# documents to the proper place. Master will be published to a draft
# directory, stable/X will be published to the X directory. For
# example stable/newton documents will life in the newton directory.

venv=install-guide
tox -e $venv
result=$?

[ -e .tox/$venv/bin/pbr ] && freezecmd=pbr || freezecmd=pip

echo "Begin pbr freeze output from test virtualenv:"
echo "======================================================================"
.tox/${venv}/bin/${freezecmd} freeze
echo "======================================================================"

if [ -z "$ZUUL_REFNAME" ]; then
    TARGET=""
    # Leave documents where they are
elif [ "$ZUUL_REFNAME" == "master" ] ; then
    TARGET=draft
elif echo $ZUUL_REFNAME | grep stable/ >/dev/null ; then
    # Put stable release changes in dir named after stable release under the
    # build dir. When Jenkins copies these files they will be accessible under
    # the developer docs root using the stable release's name.
    TARGET=$(echo $ZUUL_REFNAME | sed 's/stable.//')
else
    # Put other branch changes in dir named after branch under the
    # build dir. When Jenkins copies these files they will be
    # accessible under the developer docs root using the branch name.
    # EG: feature/foo or milestone-proposed
    TARGET=$ZUUL_REFNAME
fi

if [ ! -z $TARGET ] ; then
    # Move the docs into subdir based on branch
    mkdir install-guide/build/$TARGET
    mv install-guide/build/html/* install-guide/build/$TARGET
    mv install-guide/build/$TARGET install-guide/build/html/$TARGET
fi

exit $result
