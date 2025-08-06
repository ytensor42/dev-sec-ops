#!/usr/bin/env bash
# terraform file generator
#
# This script is designed for
# both manual execution via the command line
# and automated execution via GitHub Actions workflows.
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

# check infra folder
[[ ! -d ../${INFRA} ]] \
    && echo "Error: (folder) ${INFRA}" && exit 1

# generate key pairs
PAIRS=$(yq ".$(echo ${INFRA} | tr '/' '.') | explode(.) | to_entries[] | .key +\" \"+ .value" ${CONFIG})
[[ -z $PAIRS ]] \
    && echo "Error: (config) ${INFRA}" && exit 1

IFS=$'\n' read -d '' -r -a PAIR <<< "$PAIRS"

# cleanup temp folder
[[ -d ${TFDIR} ]] && rm -rf ${TFDIR} && echo "Info: (folder) deleted"
mkdir ${TFDIR}
echo "Info: (infra) ${INFRA}"

# copy infra templates into temp folder
cp ../${INFRA}/*.tf ${TFDIR}/
[[ $? -ne 0 ]] \
    && echo "Error: (file) copy" && exit 1
echo "Info: (file) copy" \

# update templates with values
for file in $(ls ${TFDIR}/*.tf)
do
    echo -e "Info: (file) $(basename ${file})\c"
    for i in ${!PAIR[@]}; do
        key=$(echo ${PAIR[i]} | awk '{print $1}')
        value=$(echo ${PAIR[i]} | awk '{print $2}')
        [ "$OS" == "Darwin" ] \
            && sed -i '' "s|<${key}>|${value}|" ${file} \
            || sed -i "s|<${key}>|${value}|" ${file}
    done
    echo " ... generated"
done

ls -la ${TFDIR}/*.tf
