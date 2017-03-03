#!/usr/bin/env bash

set -e

[ "${DEBUG}" = "yes" ] && set -x

# Make www-data user to have the same uid/gid as the mounted volume.
# This is a work around for permission issues.

if [[ "${UPDATE_UID_GID}" = "yes" ]]; then
    DOCKER_UID=$(stat -c '%u' /var/www/sylius)
    DOCKER_GID=$(stat -c '%g' /var/www/sylius)

    echo "Docker: uid = ${DOCKER_UID}, gid = ${DOCKER_GID}"

    usermod -u ${DOCKER_UID} www-data 2> /dev/null && {
	    groupmod -g ${DOCKER_GID} www-data 2> /dev/null || usermod -a -G ${DOCKER_GID} www-data
    }
fi;
