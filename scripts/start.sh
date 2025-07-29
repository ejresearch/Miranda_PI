#!/bin/bash

# Miranda Development Server Launcher

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${PURPLE}🚀 Starting Miranda Development Servers${NC}"
echo "========================================="

# Check if setup has been run
if [ ! -f ".env" ]; then
    echo -e "${RED}❌ Environment not set up. Run './scripts/setup.sh' first${NC}"
    exit 1
fi

# Load environment variables
set -a
source .env
set +a

# Function to check if port is in use
check_port() {
    if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Check for conflicting processes
if check_port 8000; then
    echo -e "${RED}❌ Port 8000 is already in use${NC}"
    echo "Kill the process and try again, or run './scripts/stop.sh' first"
    exit 1
fi

if check_port 3000; then
    echo -e "${RED}❌ Port 3000 is already in use${NC}"
    echo "Kill the process and try again, or run './scripts/stop.sh' first"  
    exit 1
fi

# Start backend
echo -e "${BLUE}🐍 Starting Python backend...${NC}"
cd backend

if [ ! -d "venv" ]; then
    echo -e "${RED}❌ Virtual environment not found. Run './scripts/setup.sh' first${NC}"
    exit 1
fi

source venv/bin/activate

if [ ! -f "main.py" ]; then
    echo -e "${RED}❌ main.py not found in backend directory${NC}"
    exit 1
fi

uvicorn main:app --reload --port 8000 &
BACKEND_PID=$!

cd ..

# Wait a moment for backend to start
sleep 2

# Start frontend
echo -e "${BLUE}⚛️ Starting React frontend...${NC}"
cd frontend

if [ ! -f "package.json" ]; then
    echo -e "${RED}❌ package.json not found in frontend directory${NC}"
    kill $BACKEND_PID
    exit 1
fi

npm run dev &
FRONTEND_PID=$!

cd ..

echo ""
echo -e "${GREEN}✅ Miranda servers started successfully!${NC}"
echo ""
echo -e "${BLUE}🌐 Backend API: http://localhost:8000${NC}"
echo -e "${BLUE}🌐 Frontend App: http://localhost:3000${NC}"
echo -e "${BLUE}📚 API Documentation: http://localhost:8000/docs${NC}"
echo ""
echo -e "${PURPLE}Press Ctrl+C to stop all servers${NC}"

# Handle shutdown gracefully
cleanup() {
    echo ""
    echo -e "${BLUE}🛑 Shutting down Miranda servers...${NC}"
    kill $BACKEND_PID 2>/dev/null || true
    kill $FRONTEND_PID 2>/dev/null || true
    echo -e "${GREEN}✅ All servers stopped${NC}"
    exit 0
}

trap cleanup INT TERM

# Wait for processes
wait
