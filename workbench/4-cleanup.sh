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

# Set stack name from environment, argument, or use default
if [[ $# -eq 1 ]] ; then
    STACK=$1
    echo "🗑️ Deleting stack $STACK (from argument)"
elif [ "$STACK_NAME" ]; then
    STACK="$STACK_NAME"
    echo "🗑️ Deleting stack $STACK (from config)"
else
    STACK="boxlang-lambda-stack"
    echo "🗑️ Deleting stack $STACK (default)"
fi

# Set function name for log cleanup
FUNCTION_NAME=${FUNCTION_NAME:-"$STACK-bxFunction-XXXXXXXXXX"}

echo "⚠️  This will delete:"
echo "   📦 CloudFormation Stack: $STACK"
echo "   📋 Function Logs: /aws/lambda/$FUNCTION_NAME"
echo "   🪣 S3 Bucket: (if created by this template)"
echo ""

aws cloudformation delete-stack --stack-name $STACK
echo "✅ Deleted $STACK stack."

if [ -f bucket-name.txt ]; then
    ARTIFACT_BUCKET=$(cat bucket-name.txt)
    if [[ ! $ARTIFACT_BUCKET =~ lambda-artifacts-[a-z0-9]{16} ]] ; then
        echo "Bucket was not created by this application. Skipping."
    else
        while true; do
            read -p "Delete deployment artifacts and bucket ($ARTIFACT_BUCKET)? (y/n)" response
            case $response in
                [Yy]* ) aws s3 rb --force s3://$ARTIFACT_BUCKET; rm bucket-name.txt; break;;
                [Nn]* ) break;;
                * ) echo "Response must start with y or n.";;
            esac
        done
    fi
fi

while true; do
    read -p "Delete function log group (/aws/lambda/$FUNCTION_NAME)? (y/n)" response
    case $response in
        [Yy]* ) aws logs delete-log-group --log-group-name /aws/lambda/$FUNCTION_NAME; break;;
        [Nn]* ) break;;
        * ) echo "Response must start with y or n.";;
    esac
done

rm -f out.yml out.json
rm -rf build .gradle target
