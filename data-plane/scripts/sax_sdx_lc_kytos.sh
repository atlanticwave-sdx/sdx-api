#!/bin/sh
set -eu

sleep 30

while ! nc -z 192.168.0.6 27027; do   
  sleep 1 # wait 1 second before check for mongo1t again
done

while ! nc -z 192.168.0.7 27028; do   
  sleep 1 # wait 1 second before check for mongo2t again
done

while ! nc -z 192.168.0.8 27029; do   
  sleep 1 # wait 1 second before check for mongo3t again
done

tmux new-sess -d -s k1 kytosd -f --database mongodb
touch /var/log/sax/access_sdx_lc.log
touch /var/log/sax/error_sdx_lc.log
touch /var/log/sax/access_validator.log
touch /var/log/sax/error_validator.log
touch /var/log/sax/kytos.log
tail -f /var/log/sax/kytos.log
pipenv install --dev
pipenv run gunicorn 'swagger_server.__main__:app' -w 4 -b 0.0.0.0:8080 \
        --daemon \
        --access-logfile var/log/sax/access_sdx_lc.log \
        --error-logfile var/log/sax/error_sdx_lc.log \
        --capture-output \
        --log-level='debug'

pipenv run gunicorn 'sdx_topology.validator.app:app' -w 4 -b 0.0.0.0:8000 \
        --daemon \
        --access-logfile var/log/sax/access_validator.log \
        --error-logfile var/log/sax/error_validator.log \
        --capture-output \
        --log-level='debug'

exec "$@"
