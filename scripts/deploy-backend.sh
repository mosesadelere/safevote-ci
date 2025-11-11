#!/bin/bash
set -e

BACKEND_URL=$1
SUT_IP=$2
PORT=$3
TEMP_DIR="/tmp/safevote-backend"
SERVICE_NAME="safevote-backend"

# validate inputs
if [[ "${{ BACKEND_URL }}" == *"localhost"* ]]; then
  echo "::error::BACKEND_URL ($BACKEND_URL) appears to be a localhost URL. This is not valid for deployment."
  echo "Please set BACKEND_DOWNLOAD_URL variable in your repository settings to a valid URL."
  exit 1
fi

if [[ "$SUT_IP" == *"localhost"* ]]; then
    echo "::error::SUT_IP ($SUT_IP) appears to be localhost. This is not valid for deployment."
    echo "Please set SUT_IP_ADDRESS variable in your repository settings to a valid server IP."
    exit 1
fi

# Create temporary directory
mkdir -p $TEMP_DIR
cd $TEMP_DIR

# Download and extract backend
echo "Downloading backend from $BACKEND_URL..."
if [[ ! wget -O backend.tar.gz $BACKEND_URL ]]; then
  echo "::error::Downloaded file backend.tar.gz does not exist"
  exit 1
fi

if [ ! -f backend.tar.gz ]; then
    echo "::error::Downloaded file backend.tar.gz does not exist"
    exit 1
fi

# Extract the archive
if ! tar -xzf backend.tar.gz; then
    echo "::error::Failed to extract backend.tar.gz"
    exit 1
fi

# Install dependencies
echo "Installing backend dependencies..."
npm install --production

# Create systemd service file
cat > /etc/systemd/system/$SERVICE_NAME.service <<EOL
[Unit]
Description=SafeVote Backend Service
After=network.target

[Service]
User=node
WorkingDirectory=$TEMP_DIR
Environment="NODE_ENV=production"
ExecStart=/usr/bin/node index.js
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd and start service
systemctl daemon-reload
systemctl enable $SERVICE_NAME
systemctl restart $SERVICE_NAME

# Verify service is running
if ! systemctl is-active --quiet $SERVICE_NAME; then
  echo "Error: $SERVICE_NAME failed to start"
  journalctl -u $SERVICE_NAME -n 50 --no-pager
  exit 1
fi

# Verify backend is responding
MAX_RETRIES=30
COUNTER=0
while ! nc -z $SUT_IP $PORT; do
  if [ $COUNTER -ge $MAX_RETRIES ]; then
    echo "Error: Backend did not start on $SUT_IP:$PORT after $MAX_RETRIES attempts"
    exit 1
  fi
  echo "Waiting for backend to start on $SUT_IP:$PORT..."
  sleep 5
  COUNTER=$((COUNTER+1))
done

echo "Backend deployed and running on $SUT_IP:$PORT"
exit 0
