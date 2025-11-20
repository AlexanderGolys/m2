#!/bin/bash
# Quick test script to check if M2 is working
# Run this on your server

echo "Testing Macaulay2 installation..."
echo "================================"

# Check if M2 is installed
if command -v M2 &> /dev/null; then
    echo "M2 is installed"
    echo ""
    
    echo "M2 Version:"
    M2 --version
    echo ""
    
    echo "Testing M2 execution..."
    echo "Code: 2+2"
    echo "2+2" | M2 -q --stop
    echo ""
    
    echo "Testing with script file..."
    cat > /tmp/test.m2 << 'EOF'
R = QQ[x,y,z]
I = ideal(x^2 + y^2, z^2)
I
EOF
    
    echo "Running: M2 --script /tmp/test.m2"
    M2 --script /tmp/test.m2
    echo ""
    
    echo "Running: M2 -q --script /tmp/test.m2"
    M2 -q --script /tmp/test.m2
    
    rm /tmp/test.m2
else
    echo "✗ M2 is NOT installed or not in PATH"
    echo "Install with: sudo apt-get install macaulay2"
fi

echo ""
echo "================================"
echo "Checking backend service..."
if systemctl is-active --quiet m2-backend; then
    echo "✓ Backend service is running"
    echo ""
    echo "Recent logs:"
    journalctl -u m2-backend -n 20 --no-pager
else
    echo "✗ Backend service is NOT running"
    echo "Start with: sudo systemctl start m2-backend"
    echo "Check status: sudo systemctl status m2-backend"
fi

echo ""
echo "================================"
echo "Testing backend API..."
if curl -s http://localhost:8000/health > /dev/null; then
    echo "✓ Backend API is responding"
    echo ""
    echo "Health check response:"
    curl -s http://localhost:8000/health | python3 -m json.tool
else
    echo "✗ Backend API is NOT responding"
fi
