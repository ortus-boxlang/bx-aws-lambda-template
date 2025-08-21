#!/bin/bash

# Check if bucket name is provided as argument or environment variable
if [ "$1" ]; then
    BUCKET_NAME="$1"
elif [ "$AWS_LAMBDA_BUCKET" ]; then
    BUCKET_NAME="$AWS_LAMBDA_BUCKET"
else
    # Generate random bucket name as fallback
    echo "No bucket name provided. Generating random bucket name..."
    echo "Usage: $0 <bucket-name>"
    echo "   or: export AWS_LAMBDA_BUCKET=your-bucket-name"
    BUCKET_ID=$(dd if=/dev/random bs=8 count=1 2>/dev/null | od -An -tx1 | tr -d ' \t\n')
    BUCKET_NAME="lambda-artifacts-$BUCKET_ID"
    echo "Using generated bucket name: $BUCKET_NAME"
fi

# Validate bucket name format
if [[ ! "$BUCKET_NAME" =~ ^[a-z0-9][a-z0-9-]*[a-z0-9]$ ]] || [[ ${#BUCKET_NAME} -lt 3 ]] || [[ ${#BUCKET_NAME} -gt 63 ]]; then
    echo "Error: Invalid bucket name format. Must be 3-63 characters, lowercase letters, numbers, and hyphens only."
    exit 1
fi

echo "Creating S3 bucket: $BUCKET_NAME"
echo $BUCKET_NAME > bucket-name.txt

# Check if bucket already exists
if aws s3 ls "s3://$BUCKET_NAME" 2>/dev/null; then
    echo "✅ Bucket $BUCKET_NAME already exists and is accessible"
else
    echo "🚀 Creating new bucket: $BUCKET_NAME"
    aws s3 mb "s3://$BUCKET_NAME"
fi
