#!/bin/bash
# Track RAM using top until process is killed
TIM=${1} # Time (in seconds) between top checks
SECONDS=0.5
while :
do
    echo "TIME ${SECONDS}"
    COLUMNS=160 top -E m -b -o RES -n 1 -u $USER -w | tail -n +5 | grep 'R$' | awk {'print $6'}
    # COLUMNS=160 top -b -o RES -n 1 -u james.eapen -w 
    sleep ${TIM}
done
