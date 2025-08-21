# 🚀 AWS Deployment Guide

## Quick Setup

### 1. Configure Your Deployment

Copy the configuration template and customize:

```bash
cp workbench/config.env workbench/config.local.env
```

Edit `workbench/config.local.env`:

```bash
# Required: Your S3 bucket name (must be globally unique)
AWS_LAMBDA_BUCKET=my-company-boxlang-artifacts

# Optional: Customize stack name and region
STACK_NAME=my-boxlang-app
AWS_REGION=us-west-2
```

### 2. Deploy to AWS

```bash
# 1. Create/verify S3 bucket
./workbench/1-create-bucket.sh

# 2. Build and deploy
./workbench/2-deploy.sh

# 3. Test your deployed Lambda
./workbench/3-invoke.sh

# 4. Clean up when done
./workbench/4-cleanup.sh
```

## Configuration Options

### 🪣 **Bucket Name Options (pick one):**

**Option 1: Configuration File** (Recommended)

```bash
# In workbench/config.local.env
AWS_LAMBDA_BUCKET=my-boxlang-artifacts
```

**Option 2: Command Line**

```bash
./workbench/1-create-bucket.sh my-boxlang-artifacts
```

**Option 3: Environment Variable**

```bash
export AWS_LAMBDA_BUCKET=my-boxlang-artifacts
./workbench/1-create-bucket.sh
```

**Option 4: Auto-generated** (Default)

```bash
# No configuration = random bucket name like "lambda-artifacts-a1b2c3d4"
./workbench/1-create-bucket.sh
```

### 📋 **All Configuration Options**

| Variable | Default | Description |
|----------|---------|-------------|
| `AWS_LAMBDA_BUCKET` | auto-generated | S3 bucket for deployment artifacts |
| `STACK_NAME` | `boxlang-lambda-stack` | CloudFormation stack name |
| `AWS_REGION` | your default | AWS region for deployment |
| `LAMBDA_MEMORY` | `128` | Lambda memory allocation (MB) |
| `LAMBDA_TIMEOUT` | `15` | Lambda timeout (seconds) |

## Corporate/Team Usage

### Shared Bucket Strategy

```bash
# Team shares one artifacts bucket
AWS_LAMBDA_BUCKET=company-lambda-artifacts

# Each developer uses unique stack names
STACK_NAME=myapp-dev-john
STACK_NAME=myapp-dev-jane
```

### CI/CD Integration

```bash
# In your CI/CD pipeline
export AWS_LAMBDA_BUCKET=company-cicd-artifacts
export STACK_NAME=myapp-${BRANCH_NAME}-${BUILD_NUMBER}
./workbench/2-deploy.sh
```

## Security Notes

- ✅ `config.local.env` is git-ignored (safe for secrets)
- ✅ `config.env` is checked in (template/defaults only)
- 🔒 Never commit AWS credentials to git
- 🔒 Use IAM roles in production environments
