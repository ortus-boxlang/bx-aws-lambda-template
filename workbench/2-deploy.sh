#!/bin/bash
set -eo pipefail

# Load configuration if available
if [ -f "config.local.env" ]; then
    echo "📝 Loading configuration from config.local.env"
    export $(grep -v '^#' config.local.env | xargs)
elif [ -f "config.env" ]; then
    echo "📝 Loading default configuration from config.env"
    export $(grep -v '^#' config.env | xargs)
fi

# Get bucket name from file or environment
if [ -f "bucket-name.txt" ]; then
    ARTIFACT_BUCKET=$(cat bucket-name.txt)
elif [ "$AWS_LAMBDA_BUCKET" ]; then
    ARTIFACT_BUCKET="$AWS_LAMBDA_BUCKET"
else
    echo "❌ Error: No bucket name found. Please run 1-create-bucket.sh first or set AWS_LAMBDA_BUCKET environment variable."
    exit 1
fi

# Set stack name from environment or use default
STACK_NAME=${STACK_NAME:-"boxlang-lambda-stack"}

TEMPLATE=template.yml
if [ $1 ]
then
  if [ $1 = mvn ]
  then
    TEMPLATE=template-mvn.yml
    mvn package
  fi
else
  echo "🏗️ Building with Gradle..."
  gradle build -i
fi

echo "📦 Packaging CloudFormation template..."
aws cloudformation package --template-file $TEMPLATE --s3-bucket $ARTIFACT_BUCKET --output-template-file out.yml

echo "🚀 Deploying to AWS CloudFormation stack: $STACK_NAME"
aws cloudformation deploy --template-file out.yml --stack-name $STACK_NAME --capabilities CAPABILITY_NAMED_IAM
