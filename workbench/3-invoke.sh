#!/bin/bash

# 🚀 BoxLang Lambda Invoker
#
# Invokes your deployed BoxLang Lambda function on AWS with a test event.
# Uses the deployed function directly by name - no local testing involved.
#
# Configuration:
#   Set FUNCTION_NAME in config.local.env or environment variables
#   Uses event-live.json as the test payload
#
# Usage:
#   ./3-invoke.sh
#
# Prerequisites:
#   - AWS CLI configured with proper credentials
#   - Lambda function deployed via 2-deploy.sh
#   - Function name set in config or environment
#
# Example config.local.env:
#   FUNCTION_NAME=my-stack-bxFunction-ABC123DEF456
#

set -eo pipefail

# Load configuration if available
if [ -f "config.local.env" ]; then
    echo "📝 Loading configuration from config.local.env"
    export $(grep -v '^#' config.local.env | xargs)
elif [ -f "config.env" ]; then
    echo "📝 Loading default configuration from config.env"
    export $(grep -v '^#' config.env | xargs)
fi

# Set stack name from environment or use default
STACK_NAME=${STACK_NAME:-"boxlang-lambda-stack"}

# Set function name from environment or use default
FUNCTION_NAME=${FUNCTION_NAME:-"$STACK_NAME-bxFunction-XXXXXXXXXX"}

echo "🚀 Invoking BoxLang Lambda function..."
echo "🎯 Function: $FUNCTION_NAME"
echo "📄 Using event file: sampleEvents/event-live.json"
echo ""

# Invoke the function with event-live.json
aws lambda invoke \
    --function-name $FUNCTION_NAME \
    --payload fileb://sampleEvents/event-live.json \
    out.json

echo "📥 Response:"
cat out.json
echo ""
echo "✅ Invocation complete!"
