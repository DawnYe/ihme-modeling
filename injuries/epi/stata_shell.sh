#!/bin/sh
#$ -S /bin/sh
export STATA_DO="do \"$1\""
/usr/local/bin/stata-mp -q $STATA_DO $2
