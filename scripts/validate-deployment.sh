#!/bin/bash
set -e

SUT_IP=$1
PORT=$2
VALIDATION_DIR="validation-results/$(date +%Y%m%d-%H%M%S)"

# Create validation directory
mkdir -p "$VALIDATION_DIR"

# Function to check HTTP endpoint
check_endpoint() {
    local url=$1
    local expected_status=$2
    local description=$3
    
    echo "Checking $description at $url..."
    status_code=$(curl -s -o /dev/null -w "%{http_code}" "$url" || echo "000")
    
    if [ "$status_code" -eq "$expected_status" ]; then
        echo "✓ $description is accessible (Status: $status_code)"
        return 0
    else
        echo "✗ $description is not accessible (Status: $status_code, Expected: $expected_status)"
        return 1
    fi
}

# Validate backend endpoints
check_endpoint "http://$SUT_IP:$PORT/api/health" 200 "Backend Health Check"
check_endpoint "http://$SUT_IP:$PORT/api/votes" 401 "Votes Endpoint (expecting 401 for unauthenticated)"

# Validate frontend (assuming it's served from S3)
if [ -n "$S3_BUCKET" ]; then
    FRONTEND_URL="http://$S3_BUCKET.s3-website.$AWS_REGION.amazonaws.com"
    check_endpoint "$FRONTEND_URL" 200 "Frontend"
    check_endpoint "$FRONTEND_URL/index.html" 200 "Frontend Index"
fi

# Run smoke tests with curl
run_smoke_test() {
    local test_name=$1
    local url=$2
    local method=$3
    local data=$4
    local expected_status=$5
    
    echo "\nRunning smoke test: $test_name"
    echo "$method $url"
    
    if [ -n "$data" ]; then
        response=$(curl -s -o /dev/null -w "%{http_code}" -X "$method" -H "Content-Type: application/json" -d "$data" "$url" || echo "000")
    else
        response=$(curl -s -o /dev/null -w "%{http_code}" -X "$method" "$url" || echo "000")
    fi
    
    if [ "$response" -eq "$expected_status" ]; then
        echo "✓ Test passed (Status: $response)"
        return 0
    else
        echo "✗ Test failed (Status: $response, Expected: $expected_status)"
        return 1
    fi
}

# Example smoke tests (adjust based on your API)
run_smoke_test "Get Public Info" "http://$SUT_IP:$PORT/api/info" "GET" "" 200
run_smoke_test "Unauthenticated Vote" "http://$SUT_IP:$PORT/api/votes" "POST" '{"electionId":1,"choiceId":1}' 401

# Save validation results
{
    echo "Validation Results"
    echo "================="
    echo "Timestamp: $(date)"
    echo "Backend: http://$SUT_IP:$PORT"
    [ -n "$S3_BUCKET" ] && echo "Frontend: http://$S3_BUCKET.s3-website.$AWS_REGION.amazonaws.com"
    echo "\nAll tests completed."
} > "$VALIDATION_DIR/validation-summary.txt"

echo "\nValidation completed. Results saved to $VALIDATION_DIR"
exit 0
