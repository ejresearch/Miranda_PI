#!/bin/bash

# Miranda Test Runner

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧪 Running Miranda test suite...${NC}"

# Backend tests
if [ -d "backend/tests" ]; then
    echo -e "${BLUE}🐍 Running backend tests...${NC}"
    cd backend
    source venv/bin/activate
    python -m pytest tests/ -v
    cd ..
else
    echo -e "${RED}⚠️ Backend tests not found${NC}"
fi

# Frontend tests
if [ -f "frontend/package.json" ]; then
    echo -e "${BLUE}⚛️ Running frontend tests...${NC}"
    cd frontend
    npm test
    cd ..
else
    echo -e "${RED}⚠️ Frontend tests not found${NC}"
fi

echo -e "${GREEN}✅ Test suite complete${NC}"
