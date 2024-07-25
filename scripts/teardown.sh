#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo "Script directory: $SCRIPT_DIR"

echo "Pulling environment variables configuration"
. $SCRIPT_DIR/env.sh

# Destroy CDK
echo "Tearing down CDK application..."
cd $SCRIPT_DIR/../cdk
cdk destroy --all --force

# Deleting S3 CDK bucket
echo "Deleting CDK bootstrap in $AWS_REGION..."
CDK_BUCKET=$(aws cloudformation describe-stacks \
    --stack-name CDKToolkit \
    --query 'Stacks[0].Outputs[?OutputKey==`BucketName`].OutputValue' \
    --region $AWS_REGION \
    --output text)
. $SCRIPT_DIR/delete-s3-object-version.sh --bucket $CDK_BUCKET
aws s3 rb s3://$CDK_BUCKET

# Deleting ECR image repository
IMAGE_REPOSITORY_NAME=$(aws cloudformation describe-stacks \
    --stack-name CDKToolkit \
    --query 'Stacks[0].Outputs[?OutputKey==`ImageRepositoryName`].OutputValue' \
    --region $AWS_REGION \
    --output text)
aws ecr delete-repository --repository-name $IMAGE_REPOSITORY_NAME --force

# Deleting CDK Toolkit
aws cloudformation delete-stack --stack-name CDKToolkit --region $AWS_REGION