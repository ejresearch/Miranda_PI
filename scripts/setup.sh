#!/bin/bash

# Miranda Environment Setup Script

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔧 Setting up Miranda development environment...${NC}"

# Check for required tools
command -v python3 >/dev/null 2>&1 || { echo -e "${RED}❌ Python 3 is required but not installed${NC}"; exit 1; }
command -v node >/dev/null 2>&1 || { echo -e "${RED}❌ Node.js is required but not installed${NC}"; exit 1; }
command -v npm >/dev/null 2>&1 || { echo -e "${RED}❌ npm is required but not installed${NC}"; exit 1; }

echo -e "${GREEN}✅ Prerequisites check passed${NC}"

# Backend setup
echo -e "${BLUE}🐍 Setting up Python backend...${NC}"
cd backend

if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo -e "${GREEN}✅ Python virtual environment created${NC}"
fi

source venv/bin/activate
pip install --upgrade pip

if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
    echo -e "${GREEN}✅ Python dependencies installed${NC}"
else
    echo -e "${RED}⚠️ requirements.txt not found, skipping Python dependencies${NC}"
fi

cd ..

# Frontend setup
echo -e "${BLUE}⚛️ Setting up React frontend...${NC}"
cd frontend

if [ -f "package.json" ]; then
    npm install
    echo -e "${GREEN}✅ Node.js dependencies installed${NC}"
else
    echo -e "${RED}⚠️ package.json not found, skipping Node.js dependencies${NC}"
fi

cd ..

# Create environment file if it doesn't exist
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo -e "${GREEN}✅ Environment file created from template${NC}"
    echo -e "${BLUE}ℹ️ Please edit .env file with your configuration${NC}"
fi

echo -e "${GREEN}🎉 Miranda setup complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Edit .env file with your OpenAI API key"
echo "2. Run './scripts/start.sh' to start the development servers"
