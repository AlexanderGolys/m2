#!/bin/bash
# Quick start script for local development (Linux/WSL)

echo "========================================="
echo "Macaulay2 Web Interface - Quick Start"
echo "========================================="

# Check if Macaulay2 is installed
if ! command -v M2 &> /dev/null; then
    echo "❌ Macaulay2 not found!"
    echo "Install it with: sudo apt install macaulay2"
    exit 1
fi

echo "✅ Macaulay2 found: $(M2 --version | head -n 1)"


# Start backend in background
echo ""
echo "Starting backend..."
cd backend

if [ ! -d "venv" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv venv
fi

source venv/bin/activate
pip install -q -r requirements.txt

# Use port 8001 for dev, default to 8000 if not specified
BACKEND_PORT=8001
python main.py --port $BACKEND_PORT &
BACKEND_PID=$!
echo "✅ Backend started on port $BACKEND_PORT (PID: $BACKEND_PID)"

cd ..

# Start frontend in background
echo ""
echo "Starting frontend..."
cd frontend

if [ ! -d "node_modules" ]; then
    echo "Installing npm dependencies..."
    npm install
fi

npm run dev &
FRONTEND_PID=$!
echo "✅ Frontend started (PID: $FRONTEND_PID)"

cd ..

echo ""
echo "========================================="
echo "✨ Application is running!"
echo "========================================="
echo ""
echo "Frontend: http://localhost:5173"
echo "Backend:  http://localhost:$BACKEND_PORT"
echo "API Docs: http://localhost:$BACKEND_PORT/docs"
echo ""
echo "Press Ctrl+C to stop both servers"
echo ""

# Wait for user interrupt
trap "kill $BACKEND_PID $FRONTEND_PID; echo 'Stopped servers'; exit 0" INT
wait
