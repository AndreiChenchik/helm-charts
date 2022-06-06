#!/usr/bin/env sh

SCRIPT_DIR="$(dirname $0)"
cd $SCRIPT_DIR

code=0

CHARTS="$SCRIPT_DIR/charts/*"
for chart in $CHARTS
do
  if [ ! -d "$chart" ]
  then
    >&2 echo "Skipping: Can't find chart dir at $chart..."
    continue
  fi
  chart_name=$(basename $chart)
  
  sh $SCRIPT_DIR/tests/run.sh $chart_name $1
  if [ ! "$?" = "0" ]
  then
    code=1
  fi
done

if [ "$code" = "0" ]
then
  >&2 echo "\nSuccess!"
else
  >&2 echo "\nTests failed!"
fi