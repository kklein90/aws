#!/bin/bash

SRCDIR=/home/kklein/Work/companies/asterkey/projects/ak-aws-tools/scripts/ECSTemplate

cp -Rp $SRCDIR/SKEL ./

# read in variable values
cat variables.txt | grep -o '^[^#]*' >>localvar.txt

while read line; do
    VARNAME=$(echo $line | awk -F= '{print $1}')
    VARVAL=$(echo $line | awk -F= '{print $2}')
    for FILE in $(find SKEL/ -type f); do
        sed -i "s,${VARNAME},${VARVAL},g" $FILE
    done
done <localvar.txt

mv SKEL/github ./.github
mv SKEL/devops devops
