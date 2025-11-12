#!/bin/bash
# Quick deploy script - run this on your server after git push

set -e

echo "Quick Deploy: Macaulay2 Interface"
echo ""

cd /var/www/m2-interface

# Pull latest code
echo "Pulling latest code from GitHub..."
git pull

# Deploy backend
echo ""
echo "Deploying backend..."
cd backend
source venv/bin/activate
pip install -r requirements.txt --quiet

# Restart backend service
echo "Restarting backend service..."
sudo systemctl restart m2-backend

# Check backend status
echo ""
echo "Backend status:"
sudo systemctl status m2-backend --no-pager | head -15

# Deploy frontend (optional - uncomment if you made frontend changes)
# echo ""
# echo "Deploying frontend..."
# cd ../frontend
# npm install
# npm run build
# sudo rm -rf /var/www/html/m2
# sudo mkdir -p /var/www/html/m2
# sudo cp -r dist/* /var/www/html/m2/

echo ""
echo "Deployment complete!"
echo ""
echo "Test the backend:"
echo "  curl http://localhost:8000/health"
echo ""
echo "Test M2 execution methods:"
echo "  curl http://localhost:8000/test-m2"
echo ""
echo "View backend logs:"
echo "  sudo journalctl -u m2-backend -f"
