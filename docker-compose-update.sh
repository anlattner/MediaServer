#!/bin/sh

set -e

echo "Commencing docker-compose update 'date'" >> "/var/log/containers/docker-compose-updates.$(date +'%Y-%m-%d').log"
# Do a pull then an update
docker-compose -f /home/lattner/docker-compose.yml pull --no-parallel >> "/var/log/containers/docker-compose-updates.$(date +'%Y-%m-%d').log" 2>&1
docker-compose -f /home/lattner/docker-compose.yml up -d >> "/var/log/containers/docker-compose-updates.$(date +'%Y-%m-%d').log" 2>&1
echo "Sleeping 10 seconds." >> "/var/log/containers/docker-compose-updates.$(date +'%Y-%m-%d').log"
sleep 10
docker-compose -f /home/lattner/docker-compose.yml restart >> "/var/log/containers/docker-compose-updates.$(date +'%Y-%m-%d').log" 2>&1
echo "Finishing docker-compose update `date`" >> "/var/log/containers/docker-compose-updates.$(date +'%Y-%m-%d').log"
echo "--------------------------------------" >> "/var/log/containers/docker-compose-updates.$(date +'%Y-%m-%d').log"