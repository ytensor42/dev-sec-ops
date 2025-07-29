#!/usr/bin/env bash
# terraform wrapper
#
# This script is designed for both manual execution via the command line and automated execution via GitHub Actions workflows.
#

CONFIG="./../config.yaml"
TFDIR="./../temp"
OS=$(uname -s)
COMMAND=$1

## functions
tf_generate_from_infra_template() {

    INFRA=$1

    [ ! -d $TFDIR ] \
        && mkdir $TFDIR \
        || rm -f ${TFDIR}/.terraform* ${TFDIR}/*.tf

    echo "Infra: $INFRA"

    cp ../${INFRA}/*.tf $TFDIR/
    [ $? -eq 0 ] \
        && echo "Template Files Copied" \
        || (echo "Error: Template Files"; exit 1)

    PAIRS=$(yq ".$(echo $INFRA | tr '/' '.') | to_entries[] | .key +\",\"+ .value" $CONFIG)
    TFFILES=$(ls ${TFDIR}/*.tf)

    for file in $TFFILES
    do
        echo -e "File: $(basename $file)\c"
        for pair in $PAIRS
        do
            key=$(echo $pair | awk -F',' '{print $1}')
            value=$(echo $pair | awk -F',' '{print $2}')

            [ "$OS" == "Darwin" ] \
                && sed -i '' "s|<${key}>|${value}|" $file \
                || sed -i "s|<${key}>|${value}|" $file
        done
        echo " .. done"
    done
}

## main

#INFRA="infra/aws/base"
INFRA=$1
COMMAND=$2   # plan, show, apply, destroy
[ ! -d ../$INFRA ] \
    && echo "Error: ($INFRA) Folder Not Exist" && exit 1

terraform_check=$(which terraform)
[ "$(basename $terraform_check)" != "terraform" ] \
    && echo "Error: Terraform Not Found" && exit 1

tf_generate_from_infra_template $INFRA

cd $TFDIR
terraform init
if [ "$COMMAND" == "plan" ]; then
    terraform plan
elif [ "$COMMAND" == "show" ]; then
    terraform show
elif [ "$COMMAND" == "apply" ]; then
    terraform apply -auto-approve
elif [ "$COMMAND" == "destroy" ]; then
    terraform destroy -auto-approve
else
    echo "Error: Invalid command"
    exit 1
fi
