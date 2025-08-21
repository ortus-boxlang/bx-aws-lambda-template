#!/bin/bash

# 🚀 BoxLang Lambda Local Test Runner
# Test your Lambda locally without deploying to AWS

set -e

echo "🚀 BoxLang Lambda Local Testing"
echo "================================"

# Check if SAM CLI is available
if command -v sam &> /dev/null; then
    USE_SAM=true
    echo "✅ SAM CLI detected - enhanced local testing available"
else
    USE_SAM=false
    echo "ℹ️  SAM CLI not found - using Gradle runner (install SAM CLI for HTTP endpoint testing)"
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

    # Start SAM local with the local template
    cd workbench
    sam local start-api --template template-local.yml --port 3000
else
    echo ""
    echo "🔧 Running with Gradle local runner..."

    # Show available commands
    echo "Available test commands:"
    echo "  ./gradlew runLocal                    # Run with default event"
    echo "  ./gradlew runLocalApi                 # Run with API Gateway event"
    echo "  ./gradlew runLocalLegacy              # Run with Legacy API Gateway event"
    echo "  ./gradlew runLocal -PeventFile=path   # Run with custom event file"
    echo ""

    # Run default local test
    echo "🧪 Running default local test..."
    ./gradlew runLocal
fi
