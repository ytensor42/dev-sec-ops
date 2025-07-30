#!/usr/bin/env bash
# terraform wrapper
#
# This script is designed for both manual execution via the command line and automated execution via GitHub Actions workflows.
#

## argument check
[[ $# -ne 2 ]] \
    && echo "Error: (arguments) missing" && exit 1

## terraform check
[[ "$(which terraform | sed 's/.*\///')" != "terraform" ]] \
    && echo "Error: (tool) terraform" && exit 1


CONFIG="./../config.yaml"
TFDIR="./../temp"
OS=$(uname -s)

COMMAND=$1      # plan, show, apply, destroy
INFRA=$2        # infra/aws/base

[[ ! -d ../${INFRA} ]] \
    && echo "Error: (folder) ${INFRA}" && exit 1

PAIRS=$(yq ".$(echo ${INFRA} | tr '/' '.') | to_entries[] | .key +\",\"+ .value" ${CONFIG})
[[ -z $PAIRS ]] \
    && echo "Error: (config) ${INFRA}" && exit 1

[[ -d ${TFDIR} ]] && rm -rf ${TFDIR} && echo "Info: (folder) deleted"
mkdir ${TFDIR}
echo "Info: (infra) ${INFRA}"

cp ../${INFRA}/*.tf ${TFDIR}/
[[ $? -ne 0 ]] \
    && echo "Error: (file) copy" && exit 1
echo "Info: (file) copy" \

for file in $(ls ${TFDIR}/*.tf)
do
    echo -e "Info: (file) $(basename ${file})\c"
    for pair in ${PAIRS}
    do
        key=$(echo ${pair} | awk -F',' '{print $1}')
        value=$(echo ${pair} | awk -F',' '{print $2}')
        [ "$OS" == "Darwin" ] \
            && sed -i '' "s|<${key}>|${value}|" ${file} \
            || sed -i "s|<${key}>|${value}|" ${file}
    done
    echo " ... generated"
done

ls -la ${TFDIR}/*.tf
