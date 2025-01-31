#!/bin/bash 
## -*- mode: sh; fill-column: 78; comment-column: 50; tab-width: 2 -*-


## start_sshd: starts the sshd process
start_sshd() {
    /usr/sbin/sshd -f /etc/ssh/sshd_config
}


## config_host1: add the necessary network elements to host1
config_host1() {
  sleep 5
  /usr/sbin/ip address add 10.100.0.2/24 dev eth1
  /usr/sbin/ip route delete default
  /usr/sbin/ip route add default via 10.100.0.1 metric 1

  /usr/sbin/ip -6 address add 2001:db8:10:100::2/64 dev eth1
  /usr/sbin/ip -6 route delete default
  /usr/sbin/ip -6 route add default via 2001:db8:10:100::1 metric 1

  # start_sshd
} 

## config_host2: add the necessary network elements to host2
config_host2() {
  sleep 5
  /usr/sbin/ip address add 10.100.1.2/24 dev eth1
  /usr/sbin/ip route delete default
  /usr/sbin/ip route add default via 10.100.1.1 metric 1

  /usr/sbin/ip -6 address add 2001:db8:10:101::2/64 dev eth1
  /usr/sbin/ip -6 route delete default
  /usr/sbin/ip -6 route add default via 2001:db8:10:101::1 metric 1

  # start_sshd
} 


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
