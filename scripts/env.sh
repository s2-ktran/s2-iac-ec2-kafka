#!/bin/bash

export PROJECT_NAME="iac-ec2-kafka"
export AWS_ACCOUNT_ID=`aws sts get-caller-identity --query Account --output text`
export AWS_REGION=`aws configure get region`
