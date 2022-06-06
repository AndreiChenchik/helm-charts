#!/usr/bin/env sh

if [ "$1" = "" ]
then
  >&2 echo "Usage: $0 <name of chart to bested> --debug"
  exit
fi

SCRIPT_DIR="$(dirname $0)"

if [ ! -d "$SCRIPT_DIR/$1" ]
then
  >&2 echo "Skipping: No tests set for $1"
  exit 0
fi

cd $SCRIPT_DIR/$1
>&2 printf '%s' "Testing $1: "

code=0

log=$(mktemp)
error_log=$(mktemp)

YAMLS="$SCRIPT_DIR/$1/*.yaml"
for yaml in $YAMLS
do
  helm template test ../../charts/$1 -f $yaml 2>>$error_log >>$log 
  if [ "$?" = "0" ]
  then
    >&2 printf '%s' "+"
  else
    >&2 printf '%s' "!"
    code=1
  fi
done
echo ""

>&2 cat $error_log

if [ "$2" = "--debug" ]
then
  cat $log
fi

exit $code
