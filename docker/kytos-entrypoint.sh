#!/bin/bash
set -e

HOSTS_ENTRY="127.0.0.1 mongo1 mongo2 mongo3"
COUNT=$(cat /etc/hosts | grep -c "$HOSTS_ENTRY")
if [ $COUNT -eq 0 ]; then
  echo "$HOSTS_ENTRY" >> /etc/hosts
fi


usage() {
  echo "docker run amlight/kytos [options]"
  echo "    -h, --help                    display help information"
  echo "    /path/program ARG1 .. ARGn    execute the specfified local program"
  echo "    --ARG1 .. --ARGn              execute kytos with these arguments"
}


if [ "$1" == "-h" -o "$1" == "--help" ]; then
  usage
  exit 0
fi

# Start the dependency services
test -x /usr/sbin/rsyslogd	&& service rsyslog start
test -x /usr/sbin/ovs-vswitchd	&& service openvswitch-switch start
test -x /usr/sbin/nginx 	&& service nginx start

# If first argument looks like an argument then execute mininet with all the
# arguments
if [ $# -eq 0 ] || [[ "$1" =~ ^- ]]; then
  echo -n "Starting Kytos controller in a tmux session with args: "
  tmux new-session -d -s kytosserver "kytosd -f $@"
  echo "done"
  echo "Leaving tail -f /dev/null running.."
  tail -f /dev/null

# execute only argument
elif [[ "$1" =~ ^/ ]]; then
  exec "$@"

# execute argument + kytosd
else
  echo -n "Starting Kytos controller in a tmux session: "
  tmux new-session -d -s kytosserver "kytosd -f"
  echo "done"
  exec "$@"
fi
