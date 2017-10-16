#!/bin/bash

PARAMS_FILE=/etc/nginx/sylius_params

cat >${PARAMS_FILE} <<DISCLAIMER
# Content of this file will be generated on container startup
# by $0
DISCLAIMER

for sylius_env in `printenv | grep SYLIUS | awk -F'=' '{print $1}'`; do
	echo "fastcgi_param ${sylius_env} ${!sylius_env};" >> ${PARAMS_FILE}
done
