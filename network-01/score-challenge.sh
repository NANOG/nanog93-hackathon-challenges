#!/usr/bin/env bash


## list-routes: display the routes for the hosts
list-routes() {
  echo "host 1 routes - ipv4"
  echo "----------------------------------------------------------------------"
  docker exec -u root network-01-host1 ip route list
  echo "host 1 routes - ipv6"
  echo "----------------------------------------------------------------------"
  docker exec -u root network-01-host1 ip -6 route list

  echo 
  echo "host 2 routes - ipv4"
  echo "----------------------------------------------------------------------"
  docker exec -u root network-01-host2 ip route list
  echo "host 2 routes - ipv6"
  echo "----------------------------------------------------------------------"
  docker exec -u root network-01-host2 ip -6 route list
}


reset-checkfile() {
  local CHECKFILE=${1}
  if [ -f ${CHECKFILE} ]; then
    echo "resetting challenge checkfile: ${CHECKFILE}"
    rm "${CHECKFILE}"
  fi
}

score-checkfile-01() {
  local CHECKFILE=${1}
  # check to make sure that we have only the _right_ lines
  local SCORE=$(grep -i " 0% packet loss" ${CHECKFILE} | wc -l | md5sum | cut -d " " -f1)
  echo "net-01.1 flag value: ${SCORE}"
}

score-checkfile-02() {
  local CHECKFILE=${1}
  local SCORE=$(wc -l ${CHECKFILE} | md5sum | cut -d " " -f1)
  echo "net-01.2 flag value: ${SCORE}"
}


## network-01-1: generate the output to score net-01.1 challenge
network-01-1() {
  NET01_1_CHECK="/tmp/net-01-1-check.txt"

  declare -a HOST1_ADDRS=( 
    "10.100.0.2"
    "2001:db8:10:100::2"
  )

  declare -a HOST2_ADDRS=( 
    "10.100.1.2" 
    "2001:db8:10:101::2" 
  )

  reset-checkfile "${NET01_1_CHECK}"

  # host 1: loopback checks 
  for I in $(seq 1 4)
  do
    docker exec network-01-host1 ping -c1 192.168.0.${I} | grep -i "transmitted" | sed 's/\, time.*$//' >> ${NET01_1_CHECK}
    docker exec network-01-host1 ping -c1 2001:db8:0:1::${I} | grep -i "transmitted" | sed 's/\, time.*$//' >> ${NET01_1_CHECK}
  done

  # host 1: validate far host reachability
  for ADDR in "${HOST2_ADDRS[@]}"
  do
    docker exec network-01-host1 ping -c1 ${ADDR} | grep -i "transmitted" | sed 's/\, time.*$//' >> ${NET01_1_CHECK}
  done

  # host 2: loopback checks
  for I in $(seq 1 4)
  do
    docker exec network-01-host2 ping -c1 192.168.0.${I} | grep -i "transmitted" | sed 's/\, time.*$//' >> ${NET01_1_CHECK}
    docker exec network-01-host2 ping -c1 2001:db8:0:1::${I} | grep -i "transmitted" | sed 's/\, time.*$//' >> ${NET01_1_CHECK}
  done

  # echo "host 2: validate far host reachability"
  for ADDR in "${HOST1_ADDRS[@]}"
  do
    docker exec network-01-host2 ping -c1 ${ADDR} | grep -i "transmitted" | sed 's/\, time.*$//' >> ${NET01_1_CHECK}
  done

  score-checkfile-01 "${NET01_1_CHECK}"
}

## network-01-2: generate the output to score net-01.2 challenge
network-01-2() {

  NET01_2_CHECK="/tmp/net-01-2-check.txt"

  declare -a HOST1_ADDRS=( 
    "10.100.0.2"
    "2001:db8:10:100::2"
  )

  declare -a HOST2_ADDRS=( 
    "10.100.1.2" 
    "2001:db8:10:101::2" 
  )

  reset-checkfile "${NET01_2_CHECK}"

  # host1 loopback checks
  for I in $(seq 1 4)
  do
    docker exec network-01-host1 traceroute -n 192.168.0.${I} | grep -iv "traceroute" >> ${NET01_2_CHECK}
    docker exec network-01-host1 traceroute -n 2001:db8:0:1::${I} | grep -iv "traceroute" >> ${NET01_2_CHECK}
  done
  
  # host2 loopback checks
  for I in $(seq 1 4)
  do
    docker exec network-01-host2 traceroute -n 192.168.0.${I} | grep -iv "traceroute" >> ${NET01_2_CHECK}
    docker exec network-01-host2 traceroute -n 2001:db8:0:1::${I} | grep -iv "traceroute" >> ${NET01_2_CHECK}
  done

  # host1: validate far host reachability
  for ADDR in "${HOST2_ADDRS[@]}"
  do
    docker exec network-01-host1 traceroute -n ${ADDR} | grep -iv "traceroute" >> ${NET01_2_CHECK}
  done
  #
  # host2: validate far host reachability
  for ADDR in "${HOST1_ADDRS[@]}"
  do
    docker exec network-01-host2 traceroute -n ${ADDR} | grep -iv "traceroute" >> ${NET01_2_CHECK}
  done

  score-checkfile-02 "${NET01_2_CHECK}"

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
