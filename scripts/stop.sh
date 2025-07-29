#!/bin/bash

# Miranda Server Shutdown Script

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🛑 Stopping Miranda servers...${NC}"

# Kill processes on specific ports
for port in 8000 3000; do
    PID=$(lsof -ti:$port 2>/dev/null || true)
    if [ -n "$PID" ]; then
        kill $PID 2>/dev/null || true
        echo -e "${GREEN}✅ Stopped process on port $port${NC}"
    else
        echo -e "${BLUE}ℹ️ No process running on port $port${NC}"
    fi
done

echo -e "${GREEN}✅ Miranda servers stopped${NC}"
