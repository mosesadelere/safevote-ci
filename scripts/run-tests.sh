#!/bin/bash
set -e

SUT_IP=$1
PORT=$2
TEST_DIR="$(dirname "$0")/../tests"
OUTPUT_DIR="test-results/$(date +%Y%m%d-%H%M%S)"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Run Robot Framework tests
echo "Running integration tests against $SUT_IP:$PORT..."
robot \
  --variable SUT_IP:$SUT_IP \
  --variable PORT:$PORT \
  --outputdir "$OUTPUT_DIR" \
  "$TEST_DIR"

# Upload test results to S3 if AWS credentials are available
if [ -n "$AWS_ACCESS_KEY_ID" ] && [ -n "$AWS_SECRET_ACCESS_KEY" ] && [ -n "$S3_BUCKET" ]; then
    echo "Uploading test results to S3..."
    aws s3 cp "$OUTPUT_DIR" "s3://$S3_BUCKET/test-results/$(basename "$OUTPUT_DIR")" --recursive
fi

echo "Test execution completed. Results available in $OUTPUT_DIR"
exit 0
