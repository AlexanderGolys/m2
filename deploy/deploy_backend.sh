#!/bin/bash
# Deploy Backend Script

set -e

APP_DIR="/var/www/m2-interface"
BACKEND_DIR="$APP_DIR/backend"

echo "==================================="
echo "Deploying Backend"
echo "==================================="

cd $BACKEND_DIR

# Create virtual environment
echo "Creating Python virtual environment..."
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Install dependencies
echo "Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Create systemd service
echo "Creating systemd service..."
sudo tee /etc/systemd/system/m2-backend.service > /dev/null <<EOF
[Unit]
Description=Macaulay2 Backend API
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$BACKEND_DIR
Environment="PATH=$BACKEND_DIR/venv/bin"
ExecStart=$BACKEND_DIR/venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000
Restart=always
RestartSec=10

# Resource limits
LimitNOFILE=4096
LimitNPROC=512

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable and start service
echo "Starting backend service..."
sudo systemctl daemon-reload
sudo systemctl enable m2-backend
sudo systemctl restart m2-backend

# Check status
echo "Backend service status:"
sudo systemctl status m2-backend --no-pager

echo "==================================="
echo "Backend deployed successfully!"
echo "==================================="
echo "Backend is running on http://localhost:8000"
echo "Check logs with: sudo journalctl -u m2-backend -f"
