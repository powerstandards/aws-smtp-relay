#!/bin/bash

# Required parameter with profile name else exit.
STAGE=$(echo "$1" | tr '[:upper:]' '[:lower:]')
REGION=$2
REPO_TOKEN=$3

if [ -z $STAGE ] || [ -z $REGION ] ; then
	echo "ERROR: Must pass a stage name and a region as parameters.";
	STAGE='-h';
fi

if [ -z REPO_TOKEN ] ; then
  echo "ERROR: Must pass a valid repo token";
  echo "For GitHub, the token should have no expiration date";
  echo "and should have these capabilities: admin:repo_hook, repo, workflow";
  STAGE='-h';
fi

if [ $STAGE = '-h' ] || [ $STAGE = '--help' ] ; then
  echo "Usage: $0 [production | staging | development] region repoToken";
  echo "E.g. $0 staging us-east-1 ghp_9AAAAaAAa9aAAAaAaAA99AaAaA9aAa9AaAa9";
	exit 1;
fi

PROJECT_NAME=aws-smtp-relay
PROJECT_NAME_LOWER_CASE=$(echo ${PROJECT_NAME} | tr '[:upper:]' '[:lower:]')
APEX_DOMAIN='powerside.com'
# Make sure ENTITY_NAME is lowercase!
ENTITY_NAME='insite'
REPO_OWNER=powerstandards

# How to handle updates which are not recognized as changes. Lists types of changes not recognized.
# https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/troubleshooting.html
# Add this to a Resource:     Metadata: {"force": Forcing stack to update."}

# TODO: Create and verify change sets https://dev.to/moleculeman/lessons-learned-from-4-years-of-working-with-cloudformation-n72

if [ $STAGE == "staging" ]; then
	aws cloudformation deploy \
	--profile=${ENTITY_NAME}-${STAGE} \
  --region=${REGION} \
	--stack-name=${PROJECT_NAME}-pipelineStack \
	--template-file=pipeline.template.yml \
	--capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND \
	--parameter-overrides \
  ProjectName=${PROJECT_NAME} \
  ProjectNameLowerCase=${PROJECT_NAME_LOWER_CASE} \
  EntityName=${ENTITY_NAME} \
	DevelopmentStage=staging \
	RepoProvider=GitHub \
	RepoOwner=${REPO_OWNER} \
	RepoProject=${PROJECT_NAME} \
	RepoBranch=staging \
	RepoToken=${REPO_TOKEN} \
	ApexDomain=${APEX_DOMAIN} \
	Subdomain=staging.emailserver

	exit $?
fi

if [ $STAGE == "production" ]; then
	aws cloudformation deploy \
	--profile=${ENTITY_NAME}-${STAGE} \
  --region=${REGION} \
	--stack-name=${PROJECT_NAME}-pipelineStack \
	--template-file=pipeline.template.yml \
	--capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND \
	--parameter-overrides \
  ProjectName=${PROJECT_NAME} \
  ProjectNameLowerCase=${PROJECT_NAME_LOWER_CASE} \
  EntityName=${ENTITY_NAME} \
	DevelopmentStage=production \
	RepoProvider=GitHub \
	RepoOwner=${REPO_OWNER} \
	RepoProject=${PROJECT_NAME} \
	RepoBranch=production \
	RepoToken=${REPO_TOKEN} \
	ApexDomain=${APEX_DOMAIN} \
	Subdomain=emailserver

	exit $?
fi

if [ $STAGE == "development" ]; then
	aws cloudformation deploy \
	--profile=${ENTITY_NAME}-${STAGE} \
  --region=${REGION} \
	--stack-name=${PROJECT_NAME}-pipelineStack \
	--template-file=pipeline.template.yml \
	--capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND \
	--parameter-overrides \
  ProjectName=${PROJECT_NAME} \
  ProjectNameLowerCase=${PROJECT_NAME_LOWER_CASE} \
  EntityName=${ENTITY_NAME} \
	DevelopmentStage=development \
	RepoProvider=GitHub \
	RepoOwner=${REPO_OWNER} \
	RepoProject=${PROJECT_NAME} \
	RepoBranch=development \
	RepoToken=${REPO_TOKEN} \
	ApexDomain=${APEX_DOMAIN} \
	Subdomain=development.emailserver

	exit $?
fi

echo "ERROR:" $STAGE "did not match a defined aws profile.";
exit 1;