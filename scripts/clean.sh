#!/bin/bash

# Miranda Cleanup Script

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧹 Cleaning Miranda build artifacts...${NC}"

# Stop servers first
./scripts/stop.sh

# Clean backend
if [ -d "backend/__pycache__" ]; then
    rm -rf backend/__pycache__
    echo -e "${GREEN}✅ Cleaned backend cache${NC}"
fi

# Clean frontend
if [ -d "frontend/dist" ]; then
    rm -rf frontend/dist
    echo -e "${GREEN}✅ Cleaned frontend build${NC}"
fi

if [ -d "frontend/node_modules/.cache" ]; then
    rm -rf frontend/node_modules/.cache
    echo -e "${GREEN}✅ Cleaned frontend cache${NC}"
fi

echo -e "${GREEN}✅ Cleanup complete${NC}"
