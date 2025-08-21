#!/bin/bash

# 🛠️ AWS Credentials Troubleshooter for SAM CLI
# Helps diagnose and fix AWS configuration issues

echo "🔍 AWS Configuration Troubleshooter"
echo "==================================="

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found"
    echo "📥 Install with: brew install awscli"
    exit 1
fi

echo "✅ AWS CLI found: $(aws --version)"

# Check AWS credentials file
CREDENTIALS_FILE="$HOME/.aws/credentials"
CONFIG_FILE="$HOME/.aws/config"

echo ""
echo "🔍 Checking AWS credentials..."

if [ ! -f "$CREDENTIALS_FILE" ]; then
    echo "❌ AWS credentials file not found: $CREDENTIALS_FILE"
    echo "🔧 Create it by running: aws configure"
else
    echo "✅ AWS credentials file found: $CREDENTIALS_FILE"

    # Check if file is readable and valid
    if [ -r "$CREDENTIALS_FILE" ]; then
        echo "✅ Credentials file is readable"

        # Try to parse the file
        if grep -q "\[default\]" "$CREDENTIALS_FILE" 2>/dev/null; then
            echo "✅ Default profile found"
        else
            echo "⚠️  Default profile not found in credentials file"
        fi
    else
        echo "❌ Credentials file is not readable"
    fi
fi

# Check AWS config file
echo ""
echo "🔍 Checking AWS config..."

if [ ! -f "$CONFIG_FILE" ]; then
    echo "ℹ️  AWS config file not found: $CONFIG_FILE (optional)"
else
    echo "✅ AWS config file found: $CONFIG_FILE"
fi

# Test AWS connectivity
echo ""
echo "🌐 Testing AWS connectivity..."

if aws sts get-caller-identity &> /dev/null; then
    echo "✅ AWS credentials working!"
    aws sts get-caller-identity --output table 2>/dev/null || echo "Connected but can't display details"
else
    echo "❌ AWS credentials not working"
    echo ""
    echo "🔧 Quick fix options:"
    echo ""
    echo "1️⃣  Run AWS configuration:"
    echo "   aws configure"
    echo ""
    echo "2️⃣  Or manually create credentials file:"
    echo "   mkdir -p ~/.aws"
    echo "   cat > ~/.aws/credentials << EOF"
    echo "   [default]"
    echo "   aws_access_key_id = YOUR_ACCESS_KEY"
    echo "   aws_secret_access_key = YOUR_SECRET_KEY"
    echo "   region = us-east-1"
    echo "   EOF"
    echo ""
    echo "3️⃣  Or use environment variables:"
    echo "   export AWS_ACCESS_KEY_ID=your-key"
    echo "   export AWS_SECRET_ACCESS_KEY=your-secret"
    echo "   export AWS_DEFAULT_REGION=us-east-1"
fi

echo ""
echo "💡 Note: For local testing only, you can use dummy credentials"
echo "   if you don't need actual AWS connectivity."
