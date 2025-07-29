#!/bin/bash
set -e

echo "🚀 Starting Miranda servers..."

# Start backend
cd backend
source venv/bin/activate
uvicorn main:app --reload --port 8000 &
BACKEND_PID=$!
cd ..

# Start frontend
cd frontend
npm run dev &
FRONTEND_PID=$!
cd ..

echo "✅ Miranda is running!"
echo "Frontend: http://localhost:3000"
echo "Backend: http://localhost:8000"
echo "API Docs: http://localhost:8000/docs"
echo ""
echo "Press Ctrl+C to stop both servers"

# Handle shutdown
trap 'kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; exit 0' INT
wait
