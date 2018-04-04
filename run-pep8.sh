#!/bin/bash -x

venv=pep8

tox -v -e$venv
rc=$?

[ -e .tox/$venv/bin/pbr ] && freezecmd=pbr || freezecmd=pip

echo "Begin $freezecmd freeze output from test virtualenv:"
echo "======================================================================"
.tox/${venv}/bin/${freezecmd} freeze
echo "======================================================================"

exit $rc
