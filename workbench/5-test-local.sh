#!/bin/bash

# 🚀 BoxLang Lambda Local Test Runner
# Test your Lambda locally without deploying to AWS

set -e

echo "🚀 BoxLang Lambda Local Testing"
echo "================================"

# Function to test SAM CLI functionality
test_sam_cli() {
    # Try to run a simple SAM command that doesn't require AWS credentials
    # Use a timeout to prevent hanging
    if timeout 10s sam --version &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Check if SAM CLI is available and working
USE_SAM=false
if command -v sam &> /dev/null; then
    echo "🔍 SAM CLI found, testing functionality..."

    if test_sam_cli; then
        USE_SAM=true
        echo "✅ SAM CLI detected and working - enhanced local testing available"
    else
        echo "⚠️  SAM CLI found but not working properly"
        echo "   This might be due to AWS credentials configuration issues"
        echo "   Falling back to Gradle runner"
    fi
else
    echo "ℹ️  SAM CLI not found - using Gradle runner"
    echo "   💡 Install SAM CLI for HTTP endpoint testing: https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html"
fi

echo ""

# Build the project first
echo "🔨 Building project..."
./gradlew build -q

if [ "$USE_SAM" = true ]; then
    echo ""
    echo "🌐 Starting SAM local API server..."
    echo "📍 Your Lambda will be available at: http://localhost:3000"
    echo "🛑 Press Ctrl+C to stop"
    echo ""
    echo "💡 Test your API with:"
    echo "   curl http://localhost:3000"
    echo "   curl -X POST http://localhost:3000 -d '{\"test\":\"data\"}' -H 'Content-Type: application/json'"
    echo ""

    # Start SAM local with the local template
    cd workbench

    # Try to start SAM local, but handle failures gracefully
    if sam local start-api --template template-local.yml --port 3000 2>&1; then
        echo "✅ SAM local server stopped"
    else
        echo ""
        echo "❌ SAM local server failed to start"
        echo "� Falling back to Gradle runner..."
        echo ""
        cd ..
        echo "🧪 Running default local test..."
        ./gradlew runLocal
    fi
else
    echo ""
    echo "🔧 Using Gradle local runner..."

    # Show available commands
    echo "📋 Available test commands:"
    echo "  ./gradlew runLocal                    # Run with default event"
    echo "  ./gradlew runLocalApi                 # Run with API Gateway event"
    echo "  ./gradlew runLocalLegacy              # Run with Legacy API Gateway event"
    echo "  ./gradlew runLocal -PeventFile=path   # Run with custom event file"
    echo ""

    # Run default local test
    echo "🧪 Running default local test..."
    ./gradlew runLocal

    echo ""
    echo "✅ Local test completed!"
    echo ""
    echo "💡 AWS Credentials Issue?"
    echo "   If you saw SAM CLI errors, it might be due to:"
    echo "   • Malformed ~/.aws/credentials file"
    echo "   • Missing AWS configuration"
    echo "   • Run: aws configure"
    echo "   • Or create ~/.aws/credentials with:"
    echo "     [default]"
    echo "     aws_access_key_id = your-key"
    echo "     aws_secret_access_key = your-secret"
    echo "     region = us-east-1"
fi
