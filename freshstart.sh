#!/bin/bash

# Miranda Repository Foundation Script
# Creates complete directory structure and basic configuration

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${PURPLE}🚀 Creating Miranda Repository Foundation${NC}"
echo "========================================="

# Check if we're in the right directory
if [ ! -f "freshstart.sh" ]; then
    echo -e "${RED}❌ Run this script from the Miranda repository root${NC}"
    exit 1
fi

# Create main directory structure
echo -e "${BLUE}📁 Creating directory structure...${NC}"

# Root level directories
mkdir -p {scripts,docs,data,deployment,tools}

# Backend structure
mkdir -p backend/{api,core,models,templates,tests/{test_api,test_core,integration}}
mkdir -p backend/api/{brainstorming,writing}
mkdir -p backend/templates/{screenplay,academic,business}

# Frontend structure  
mkdir -p frontend/{src/{components/{layout,forms,ai,common},pages,hooks,services,types},public,tests/{components,pages,integration}}

# Data directories
mkdir -p data/{sample_projects,test_data/{sample_documents,sample_csvs},templates/{export_templates,prompt_templates}}

# Documentation
mkdir -p docs/{guides,api,screenshots}

# Deployment configurations
mkdir -p deployment/{systemd,nginx,pm2,supervisor}

# Tools directory
mkdir -p tools

echo -e "${GREEN}✅ Directory structure created${NC}"

# Create configuration files
echo -e "${BLUE}📄 Creating configuration files...${NC}"

# Root level configurations
cat > .env.example << 'EOF'
# Miranda Environment Configuration

# API Settings
OPENAI_API_KEY=your_openai_api_key_here
BACKEND_URL=http://localhost:8000
FRONTEND_URL=http://localhost:3000

# Database Settings
DATABASE_PATH=data/sample_projects
LIGHTRAG_STORAGE_PATH=data/lightrag_storage

# Development Settings
DEBUG=true
LOG_LEVEL=info

# Optional: Neo4j Integration
NEO4J_URI=bolt://localhost:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=password
EOF

cat > .gitignore << 'EOF'
# Dependencies
node_modules/
backend/venv/
backend/__pycache__/
backend/.pytest_cache/

# Environment files
.env
.env.local
.env.production

# Database files
*.db
*.sqlite
*.sqlite3

# LightRAG storage
data/*/lightrag_storage/
lightrag_storage/

# Logs
*.log
logs/

# Build artifacts
frontend/dist/
frontend/build/
backend/build/

# IDE files
.vscode/
.idea/
*.swp
*.swo

# OS files
.DS_Store
Thumbs.db

# Test coverage
coverage/
.coverage
.nyc_output

# Temporary files
tmp/
temp/
*.tmp
EOF

# Create professional README
cat > README.md << 'EOF'
# Miranda: AI-Assisted Writing Platform

> Transform your writing process with intelligent research, brainstorming, and content generation

## 🎯 Overview

Miranda is a comprehensive AI-assisted writing platform that combines structured data management, semantic document search, and intelligent content generation. Whether you're writing screenplays, academic papers, or business documents, Miranda provides the tools to research, organize, and create with unprecedented efficiency.

### ✨ Key Features

- **🏗️ Structured Projects**: Organize your work with templates for different writing domains
- **📚 Smart Document Management**: Upload and semantically search through research documents
- **📊 Data Integration**: Import and work with structured data (CSV, databases)
- **🧠 AI Brainstorming**: Generate insights by combining your documents and data
- **✍️ Intelligent Writing**: Create content that draws from all your research
- **📤 Multi-Format Export**: Export to PDF, HTML, DOCX, and more

## 🚀 Quick Start

```bash
# Clone the repository
git clone <repository-url>
cd miranda

# Set up the environment
./scripts/setup.sh

# Start the development servers
./scripts/start.sh
```

Visit http://localhost:3000 to access the Miranda interface.

## 📁 Project Templates

### 🎬 Screenplay Writing
- **Document Buckets**: `screenplay_examples`, `film_theory`, `character_guides`
- **Data Tables**: `character_types`, `scene_beats`, `story_structure`
- **Workflow**: Research → Structure → Brainstorm → Write → Export

### 📚 Academic Writing
- **Document Buckets**: `primary_sources`, `academic_papers`, `research_notes`
- **Data Tables**: `citations`, `timeline_data`, `key_concepts`
- **Workflow**: Research → Data → Analysis → Writing → Export

### 💼 Business Documents
- **Document Buckets**: `market_research`, `competitor_analysis`, `industry_reports`
- **Data Tables**: `metrics`, `strategies`, `benchmarks`
- **Workflow**: Research → Analysis → Planning → Writing → Export

## 🔧 Technology Stack

- **Backend**: FastAPI, Python, SQLite, LightRAG
- **Frontend**: React 19, TypeScript, Tailwind CSS
- **AI Integration**: OpenAI GPT-4, Custom prompt engineering
- **Storage**: SQLite (structured data), Vector storage (documents)

## 🧪 Development

```bash
# Run tests
./scripts/test.sh

# Clean build artifacts
./scripts/clean.sh

# Create backup
./scripts/backup.sh
```

## 📖 Documentation

- [Demo Script](DEMO_SCRIPT.md) - 5-minute investor walkthrough
- [Architecture](ARCHITECTURE.md) - Technical system design
- [User Guides](docs/guides/) - Step-by-step tutorials

## 🤝 Contributing

Miranda is designed for professional use and active development. See our contribution guidelines for details.

## 📄 License

[License information]

---

**Miranda**: Where research meets creativity, powered by AI.
EOF

echo -e "${GREEN}✅ Configuration files created${NC}"

# Create automation scripts
echo -e "${BLUE}🔧 Creating automation scripts...${NC}"

# Setup script
cat > scripts/setup.sh << 'EOF'
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
EOF

# Start script
cat > scripts/start.sh << 'EOF'
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
EOF

# Stop script
cat > scripts/stop.sh << 'EOF'
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
EOF

# Test script placeholder
cat > scripts/test.sh << 'EOF'
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
EOF

# Clean script
cat > scripts/clean.sh << 'EOF'
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
EOF

# Make scripts executable
chmod +x scripts/*.sh

echo -e "${GREEN}✅ Automation scripts created${NC}"

# Create placeholder files for key components
echo -e "${BLUE}📄 Creating placeholder files...${NC}"

# Backend main placeholder
cat > backend/main.py << 'EOF'
# Miranda FastAPI Backend
# This file will be implemented in Phase 2

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Miranda API", version="1.0.0")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
async def health_check():
    return {"status": "healthy", "message": "Miranda backend is running"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
EOF

# Backend requirements
cat > backend/requirements.txt << 'EOF'
fastapi==0.104.1
uvicorn[standard]==0.24.0
pydantic==2.4.2
lightrag==0.0.0a13
openai==1.3.5
pandas==2.1.3
aiofiles==23.2.1
python-multipart==0.0.6
python-dotenv==1.0.0
pytest==7.4.3
pytest-asyncio==0.21.1
sqlalchemy==2.0.23
sqlite3-utils==3.35.2
EOF

# Frontend package.json placeholder
cat > frontend/package.json << 'EOF'
{
  "name": "miranda-frontend",
  "version": "1.0.0",
  "description": "Miranda AI-Assisted Writing Platform Frontend",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "test": "vitest"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.18.0",
    "@tanstack/react-query": "^5.8.4",
    "lucide-react": "^0.292.0",
    "tailwindcss": "^3.3.5",
    "clsx": "^2.0.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.37",
    "@types/react-dom": "^18.2.15",
    "@vitejs/plugin-react": "^4.1.1",
    "typescript": "^5.2.2",
    "vite": "^4.5.0",
    "vitest": "^0.34.6",
    "@testing-library/react": "^13.4.0",
    "@testing-library/jest-dom": "^6.1.5",
    "autoprefixer": "^10.4.16",
    "postcss": "^8.4.31"
  }
}
EOF

# Frontend main placeholder
mkdir -p frontend/src
cat > frontend/src/main.tsx << 'EOF'
// Miranda Frontend Entry Point
// This file will be implemented in Phase 5

import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';

function App() {
  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center">
      <div className="text-center">
        <h1 className="text-4xl font-bold text-gray-900 mb-4">
          Miranda
        </h1>
        <p className="text-xl text-gray-600 mb-8">
          AI-Assisted Writing Platform
        </p>
        <div className="bg-blue-100 border border-blue-400 text-blue-700 px-4 py-3 rounded">
          <p className="font-bold">Phase 1 Complete!</p>
          <p>Frontend will be implemented in Phase 5</p>
        </div>
      </div>
    </div>
  );
}

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOF

cat > frontend/src/index.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
    'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
    sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
EOF

# Create index.html
cat > frontend/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Miranda - AI-Assisted Writing Platform</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
EOF

# Create Vite config
cat > frontend/vite.config.ts << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    proxy: {
      '/api': {
        target: 'http://localhost:8000',
        changeOrigin: true,
      }
    }
  }
})
EOF

# Create Tailwind config
cat > frontend/tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOF

cat > frontend/postcss.config.js << 'EOF'
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOF

echo -e "${GREEN}✅ Placeholder files created${NC}"

# Final summary
echo ""
echo -e "${PURPLE}🎉 Miranda Repository Foundation Complete!${NC}"
echo "========================================="
echo ""
echo -e "${GREEN}✅ Directory structure created${NC}"
echo -e "${GREEN}✅ Configuration files ready${NC}"
echo -e "${GREEN}✅ Automation scripts available${NC}"
echo -e "${GREEN}✅ Placeholder files in place${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Run './scripts/setup.sh' to install dependencies"
echo "2. Edit '.env' file with your OpenAI API key"
echo "3. Proceed to Phase 2: Backend Core Services"
echo ""
echo -e "${BLUE}Available commands:${NC}"
echo "• ./scripts/setup.sh   - Install dependencies"
echo "• ./scripts/start.sh   - Start development servers"
echo "• ./scripts/stop.sh    - Stop all servers"
echo "• ./scripts/test.sh    - Run test suite"
echo "• ./scripts/clean.sh   - Clean build artifacts"
echo ""
echo -e "${GREEN}🚀 Ready for Miranda development!${NC}"
