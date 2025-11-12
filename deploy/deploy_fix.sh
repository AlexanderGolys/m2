#!/bin/bash
# Run this on your server to deploy the fix

echo "🚀 Deploying M2 stdin method fix..."
echo ""

cd /var/www/m2-interface

echo "📥 Pulling latest code..."
git pull

echo ""
echo "🔄 Restarting backend service..."
sudo systemctl restart m2-backend

echo ""
echo "✅ Checking service status..."
sudo systemctl status m2-backend --no-pager | head -10

echo ""
echo "🧪 Testing execution..."
curl -s -X POST http://localhost:8000/execute \
  -H "Content-Type: application/json" \
  -d '{"code": "2+2"}' | python3 -m json.tool

echo ""
echo "✨ Done! Test it at https://macaulay2.fun"
