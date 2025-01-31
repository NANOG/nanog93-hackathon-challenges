#!/usr/bin/env bash

reset-checkfile() {
  local CHECKFILE=${1}
  if [ -f ${CHECKFILE} ]; then
    echo "resetting challenge checkfile: ${CHECKFILE}"
    rm "${CHECKFILE}"
  fi
}

score-checkfile() {
  local CHECKFILE=${1}
  local CTFD_ID=${2}
  local SCORE=$(wc -l ${CHECKFILE} | md5sum | cut -d " " -f1)
  echo "${CTFD_ID} flag value: ${SCORE}"
}

## network-02-1: generate the output to score the net-02.1 challenge
network-02-1() {
  NET02_1_CHECK="/tmp/net-02-1-check.txt"
  reset-checkfile "${NET02_1_CHECK}"

  # for each router count the number of ISISv6 routes learned
  for I in $(seq 1 4)
  do
    echo "scoring r${I}"
    ssh admin@172.20.20.6${I} "show ipv6 route isis" | egrep '^ I' >> ${NET02_1_CHECK}
    V4_CHECK=$(ssh admin@172.20.20.6${I} "show ip route summary" | grep 'isis' | awk '{print $2}')
    if [ ${V4_CHECK} != "0" ]; then
      echo "${V4_CHECK} - v4 prefix leaked"
      echo "${V4_CHECK}" >> ${NET02_1_CHECK}
    fi
  done

  score-checkfile ${NET02_1_CHECK} "net-02.1"
}

## network-02-2: generate the output to score the net-02.2 challenge
network-02-2() {
  NET02_2_CHECK="/tmp/net-02-2-check.txt"
  reset-checkfile "${NET02_2_CHECK}"

  # for each router count the number of ISISv6 routes learned
  for I in $(seq 1 4)
  do
    echo "scoring r${I}"
    ssh admin@172.20.20.6${I} "show isis segment-routing prefix-segments ipv6" | grep -i "2001:db8" >> ${NET02_2_CHECK}
  done

  score-checkfile ${NET02_2_CHECK} "net-02.2"
}

## network-02-3: generate the output to score the net-02.3 challenge
network-02-3() {
  NET02_3_CHECK="/tmp/net-02-3-check.txt"
  reset-checkfile "${NET02_3_CHECK}"
  
  for I in $(seq 1 4)
  do
    echo "scoring r${I}"
    ssh admin@172.20.20.6${I} "show ipv6 bgp summary" | grep "2001:" >> ${NET02_3_CHECK}
    ssh admin@172.20.20.6${I} "show ip bgp" | grep '* >' >> ${NET02_3_CHECK}
  done

  score-checkfile ${NET02_3_CHECK} "net-02.3"
}

## network-02-4: generate the output to score the net-02.4 challenge
network-02-4() {
  NET02_4_CHECK="/tmp/net-02-4-check.txt"
  reset-checkfile "${NET02_4_CHECK}"
  
  echo "scoring r2"
  ssh admin@172.20.20.62 "show ipv6 bgp detail" | grep 'Color' >> ${NET02_4_CHECK}
  ssh admin@172.20.20.62 "show ip bgp detail" | grep 'Color' >> ${NET02_4_CHECK}

  echo "scoring r4"
  ssh admin@172.20.20.64 "show traffic-engineering segment-routing policy | json" | grep -E '"(color|endpoint|mplsLabelSid)"' >> ${NET02_4_CHECK}
  ssh admin@172.20.20.64 "sh ip route 10.102.0.0/24 | json" | grep -E '"(color|endpoint)"' >> ${NET02_4_CHECK}
  ssh admin@172.20.20.64 "sh ipv6 route 2001:db8:10:102::/64 | json" | grep -E '"(color|endpoint)"' >> ${NET02_4_CHECK}

  score-checkfile ${NET02_4_CHECK} "net-02.4"
}

trap cleanup SIGINT SIGTERM ERR EXIT

usage() {
    cat << EOF
usage: ${0##*/} [-h]

    -h          display help and exit
    XXX - list of args here

EOF
}

# anything that has ## at the front of the line will be used as input.
## help: details the available functions in this script
help() {
  usage
  echo "available functions:"
  sed -n 's/^##//p' $0 | column -t -s ':' | sed -e 's/^/ /'
}

cleanup() {
    trap - SIGINT SIGTERM ERR EXIT

    # script cleanup here, tmp files, etc.
}

if [[ $# -lt 1 ]]; then
  help
  exit
fi

case $1 in
  *)
    # shift positional arguments so that arg 2 becomes arg 1, etc.
    CMD=$1
    shift 1
    ${CMD} ${@} || help
    ;;
esac
