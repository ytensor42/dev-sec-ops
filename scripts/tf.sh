#!/usr/bin/env bash
# terraform wrapper
#

CONFIG="./../config.yaml"
TFDIR="./../temp"
OS=$(uname -s)
COMMAND=$1

./generate.sh $@
[[ $? -ne 0 ]] && exit 1

terraform -chdir=${TFDIR} init
if [ "$COMMAND" == "plan" ]; then
    terraform -chdir=${TFDIR} plan
elif [ "$COMMAND" == "show" ]; then
    terraform -chdir=${TFDIR} show
elif [ "$COMMAND" == "apply" ]; then
    terraform -chdir=${TFDIR} apply -auto-approve
elif [ "$COMMAND" == "destroy" ]; then
    terraform -chdir=${TFDIR} destroy -auto-approve
else
    echo "Error: Invalid command"
    exit 1
fi
