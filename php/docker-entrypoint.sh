#!/usr/bin/env bash

set -e

[ "${DEBUG}" = "yes" ] && set -x

CMD=$(basename "$1")
if [ "${CMD}" = 'php-fpm' ]; then
    for SCRIPT in /entrypoint-init.d/*.sh; do
        . "${SCRIPT}"
    done
fi

exec "$@"
