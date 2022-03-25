#!/usr/bin/env bash#
# /#Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# /#SPDX-License-Identifier: Apache-2.0
#
set -e

INPUT=$(($1))
TILES=$((INPUT-1))
SUBNETS=$2
VPC=$3
SG=$4
KEYPAIR_NAME=$5
CLUSTER_NAME=$6

# Provision the ECS cluster
ecs-cli up --force --keypair $KEYPAIR_NAME --capability-iam --size $INPUT --instance-type m6i.large --subnets $SUBNETS --vpc $VPC --security-group $SG --region us-east-1 --launch-type EC2

# Wait 60 seconds until the cluster is ready
sleep 60

# Provision tasks
for value in `seq 0 $TILES`
do
  echo "Starting CQLReplicator"$value
  echo $CLUSTER_NAME$value
  aws ecs run-task --cluster $CLUSTER_NAME --task-definition CQLReplicator$value --output text
done