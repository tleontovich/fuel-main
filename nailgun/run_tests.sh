#!/bin/bash

function usage {
  echo "Usage: $0 [OPTION]..."
  echo "Run tests"
  echo ""
  echo "  -p, --pep8               Just run PEP8 and HACKING compliance check"
  echo "  -x, --xunit              Generate reports (useful in Jenkins environment)"
  echo "  -P, --no-pep8            Don't run static code checks"
  echo "  -c, --clean              Only clean *.log, *.json, *.pyc, *.pid files, doesn't run tests"
  echo "  -h, --help               Print this usage message"
  echo ""
  echo "By default it runs tests and pep8 check."
  exit
}

function process_option {
  case "$1" in
    -h|--help) usage;;
    -p|--pep8) just_pep8=1;;
    -P|--no-pep8) no_pep8=1;;
    -x|--xunit) xunit=1;;
    -c|--clean) clean=1;;
    -*) noseopts="$noseopts $1";;
    *) noseargs="$noseargs $1"
  esac
}

just_pep8=0
no_pep8=0
xunit=0
clean=0
noseargs=
noseopts=

for arg in "$@"; do
  process_option $arg
done

function clean {
  echo "cleaning *.pyc, *.json, *.log, *.pid files"
  find . -type f -name "*.pyc" -delete
  rm -f *.json
  rm -f *.log
  rm -f *.pid
}

if [ $clean -eq 1 ]; then
  clean
  exit 0
fi

# If enabled, tell nose to create xunit report
if [ $xunit -eq 1 ]; then
    noseopts="--with-xunit"
fi

function run_pep8 {
  pep8 --show-source --show-pep8 --count . || return 1
  echo "PEP8 check passed successfully."
}

if [ $just_pep8 -eq 1 ]; then
    run_pep8 || exit 1
    exit
fi

function run_tests {
  clean
  [ -z "$noseargs" ] && test_args=nailgun || test_args="$noseargs"
  python nailgun.py test $noseopts $test_args
}

run_tests || exit 1

if [ -z "$noseargs" ]; then
  if [ $no_pep8 -eq 0 ]; then
    run_pep8
  fi
fi
