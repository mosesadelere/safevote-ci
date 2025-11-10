#!/bin/bash
set -e

BUILD_DIR=$1
S3_BUCKET=$2

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI is not installed"
    exit 1
fi

# Check if build directory exists
if [ ! -d "$BUILD_DIR" ]; then
    echo "Error: Build directory $BUILD_DIR does not exist"
    exit 1
fi

# Check if S3 bucket exists
if ! aws s3 ls "s3://$S3_BUCKET" &> /dev/null; then
    echo "Error: S3 bucket $S3_BUCKET does not exist or you don't have permission to access it"
    exit 1
fi

# Upload files to S3 with proper cache control
echo "Uploading files to S3 bucket: $S3_BUCKET..."
aws s3 sync \
  --delete \
  --cache-control "public, max-age=31536000" \
  --exclude "index.html" \
  "$BUILD_DIR/" "s3://$S3_BUCKET/"

# Upload index.html with no-cache
echo "Uploading index.html with no-cache..."
aws s3 cp \
  --cache-control "no-cache, no-store, must-revalidate" \
  "$BUILD_DIR/index.html" "s3://$S3_BUCKET/index.html"

# Enable static website hosting if not already enabled
if ! aws s3 website "s3://$S3_BUCKET" --index-document index.html --error-document index.html 2> /dev/null; then
    echo "Enabling static website hosting..."
    aws s3 website "s3://$S3_BUCKET" --index-document index.html --error-document index.html
fi

# Set bucket policy for public read access
cat > /tmp/bucket-policy.json <<EOL
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::$S3_BUCKET/*"
        }
    ]
}
EOL

aws s3api put-bucket-policy --bucket $S3_BUCKET --policy file:///tmp/bucket-policy.json
rm /tmp/bucket-policy.json

echo "Frontend deployed successfully to S3 bucket: $S3_BUCKET"
echo "Website URL: http://$S3_BUCKET.s3-website.$AWS_REGION.amazonaws.com"

exit 0
