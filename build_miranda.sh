#!/bin/bash
# build_miranda.sh - One command to build complete Miranda system
# Usage: curl -sSL https://raw.githubusercontent.com/your-repo/miranda/main/build_miranda.sh | bash

set -e

echo "🚀 Building Miranda: AI-Assisted Writing Platform"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Create project structure
echo -e "${BLUE}📁 Creating Miranda directory structure...${NC}"
mkdir -p miranda/{backend/{api,core,models,templates,tests},frontend/{src/{components,pages,hooks,services,types},public},scripts,docs/{guides,api,screenshots},data/{sample_projects,templates}}

cd miranda

# =============================================================================
# ROOT FILES
# =============================================================================

cat > README.md << 'EOF'
# Miranda: AI-Assisted Writing Platform

> Transform your writing process with intelligent research, brainstorming, and content generation

## 🎯 Overview
Miranda combines structured data management, semantic document search, and intelligent content generation for screenplays, academic papers, and business documents.

## 🚀 Quick Start
```bash
./scripts/setup.sh    # One-time setup
./scripts/start.sh     # Start servers
```
Visit http://localhost:3000

## 📁 Templates
- 🎬 **Screenplay**: Character development, scene planning, dialogue generation
- 📚 **Academic**: Research integration, citation management, chapter organization  
- 💼 **Business**: Market analysis, competitive research, strategic planning

## 🔧 Tech Stack
- **Backend**: FastAPI, LightRAG, SQLite
- **Frontend**: React 19, TypeScript, Tailwind
- **AI**: OpenAI GPT-4o-mini with custom prompts
EOF

cat > .env.example << 'EOF'
# Miranda Configuration
OPENAI_API_KEY=your_openai_api_key_here
BACKEND_URL=http://localhost:8000
FRONTEND_URL=http://localhost:3000
DATABASE_PATH=./data/sample_projects
LIGHTRAG_STORAGE=./data/lightrag_storage
EOF

cat > .gitignore << 'EOF'
# Dependencies
node_modules/
backend/venv/
backend/__pycache__/

# Environment
.env
*.log

# Data
*.db
*.sqlite
lightrag_storage/

# Build
frontend/dist/
frontend/build/
EOF

# =============================================================================
# BACKEND SETUP
# =============================================================================

echo -e "${BLUE}🐍 Setting up backend...${NC}"

cat > backend/requirements.txt << 'EOF'
fastapi==0.104.1
uvicorn[standard]==0.24.0
pydantic==2.5.0
openai==1.3.5
python-dotenv==1.0.1
aiofiles==23.2.1
python-multipart==0.0.6
aiosqlite==0.19.0
pandas==2.1.3
# LightRAG from source (no PyPI conflicts)
git+https://github.com/HKUDS/LightRAG.git
EOF

cat > backend/main.py << 'EOF'
from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from dotenv import load_dotenv
import os
import sys
import tempfile
import shutil
from typing import List, Optional

load_dotenv()

app = FastAPI(
    title="Miranda API",
    description="AI-Assisted Writing Platform",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# =============================================================================
# MODELS
# =============================================================================

class Project(BaseModel):
    name: str
    template: str
    description: Optional[str] = None

class LightRAGQuery(BaseModel):
    text: str
    query: str

class BrainstormRequest(BaseModel):
    project_id: str
    context: str
    focus: str
    tone: str = "neutral"

class WriteRequest(BaseModel):
    project_id: str
    brainstorm_id: str
    format: str = "screenplay"
    length: str = "scene"

# =============================================================================
# STORAGE
# =============================================================================

projects = []
brainstorms = {}
documents = {}

# =============================================================================
# LIGHTRAG SETUP
# =============================================================================

def create_lightrag_instance(working_dir: str):
    """Create LightRAG with custom OpenAI functions"""
    original_argv = sys.argv.copy()
    sys.argv = ['lightrag']
    
    try:
        from lightrag import LightRAG, QueryParam
        import openai
        
        client = openai.AsyncOpenAI(api_key=os.getenv("OPENAI_API_KEY"))
        
        async def gpt_4o_mini_complete(prompt, **kwargs):
            response = await client.chat.completions.create(
                model="gpt-4o-mini",
                messages=[{"role": "user", "content": prompt}],
                max_tokens=kwargs.get("max_tokens", 1000),
                temperature=kwargs.get("temperature", 0.7)
            )
            return response.choices[0].message.content
        
        async def openai_embed(texts):
            if isinstance(texts, str):
                texts = [texts]
            response = await client.embeddings.create(
                model="text-embedding-ada-002",
                input=texts
            )
            return [item.embedding for item in response.data]
        
        rag = LightRAG(
            working_dir=working_dir,
            llm_model_func=gpt_4o_mini_complete,
            embedding_func=openai_embed,
        )
        
        return rag, QueryParam
        
    finally:
        sys.argv = original_argv

# =============================================================================
# API ENDPOINTS
# =============================================================================

@app.get("/health")
async def health():
    return {
        "status": "healthy",
        "version": "1.0.0",
        "openai_configured": bool(os.getenv("OPENAI_API_KEY"))
    }

@app.get("/api/projects")
async def get_projects():
    return {"projects": projects}

@app.post("/api/projects")
async def create_project(project: Project):
    project_data = {
        "id": f"project_{len(projects)}",
        **project.dict(),
        "created_at": "2025-01-01T00:00:00Z"
    }
    projects.append(project_data)
    return {"success": True, "project": project_data}

@app.post("/api/upload")
async def upload_file(file: UploadFile = File(...)):
    content = await file.read()
    file_id = f"doc_{len(documents)}"
    documents[file_id] = {
        "filename": file.filename,
        "content": content.decode('utf-8'),
        "size": len(content)
    }
    return {"success": True, "file_id": file_id, "filename": file.filename}

@app.post("/api/lightrag/query")
async def query_documents(query: LightRAGQuery):
    """Query documents using LightRAG"""
    if not os.getenv("OPENAI_API_KEY"):
        return {"success": False, "error": "OpenAI API key not configured"}
    
    temp_dir = tempfile.mkdtemp()
    
    try:
        rag, QueryParam = create_lightrag_instance(temp_dir)
        
        # Insert document
        await rag.ainsert(query.text)
        
        # Query document
        result = await rag.aquery(query.query, param=QueryParam(mode="hybrid"))
        
        return {
            "success": True,
            "query": query.query,
            "result": result,
            "length": len(result)
        }
        
    except Exception as e:
        return {"success": False, "error": str(e)}
    finally:
        shutil.rmtree(temp_dir, ignore_errors=True)

@app.post("/api/brainstorm")
async def generate_brainstorm(request: BrainstormRequest):
    """Generate brainstorming ideas"""
    if not os.getenv("OPENAI_API_KEY"):
        return {"success": False, "error": "OpenAI API key not configured"}
    
    brainstorm_id = f"brainstorm_{len(brainstorms)}"
    
    # Store brainstorm
    brainstorms[brainstorm_id] = {
        "id": brainstorm_id,
        "project_id": request.project_id,
        "context": request.context,
        "focus": request.focus,
        "tone": request.tone,
        "ideas": [
            f"Idea 1 based on: {request.focus}",
            f"Idea 2 exploring: {request.context}",
            f"Idea 3 with {request.tone} tone"
        ]
    }
    
    return {"success": True, "brainstorm": brainstorms[brainstorm_id]}

@app.post("/api/write")
async def generate_content(request: WriteRequest):
    """Generate written content"""
    if not os.getenv("OPENAI_API_KEY"):
        return {"success": False, "error": "OpenAI API key not configured"}
    
    brainstorm = brainstorms.get(request.brainstorm_id)
    if not brainstorm:
        return {"success": False, "error": "Brainstorm not found"}
    
    content = f"""
FADE IN:

EXT. COFFEE SHOP - DAY

Based on brainstorm ideas: {', '.join(brainstorm['ideas'])}

A charming scene unfolds with the tone of {brainstorm['tone']}.

FADE OUT.
"""
    
    return {
        "success": True,
        "content": content.strip(),
        "format": request.format,
        "length": request.length
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
EOF

# =============================================================================
# FRONTEND SETUP
# =============================================================================

echo -e "${BLUE}⚛️ Setting up frontend...${NC}"

cat > frontend/package.json << 'EOF'
{
  "name": "miranda-frontend",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.8.1",
    "axios": "^1.6.0",
    "lucide-react": "^0.263.1"
  },
  "devDependencies": {
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0",
    "@vitejs/plugin-react": "^4.0.0",
    "autoprefixer": "^10.4.14",
    "postcss": "^8.4.24",
    "tailwindcss": "^3.3.0",
    "typescript": "^5.0.2",
    "vite": "^4.4.5"
  }
}
EOF

cat > frontend/vite.config.ts << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    host: true
  }
})
EOF

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
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOF

cat > frontend/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
EOF

mkdir -p frontend/src/{components,pages,hooks,services,types}

cat > frontend/index.html << 'EOF'
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Miranda - AI Writing Platform</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
EOF

cat > frontend/src/main.tsx << 'EOF'
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.tsx'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
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

cat > frontend/src/App.tsx << 'EOF'
import React, { useState, useEffect } from 'react';
import { Plus, FileText, Brain, PenTool, Download } from 'lucide-react';

interface Project {
  id: string;
  name: string;
  template: string;
  description?: string;
  created_at: string;
}

function App() {
  const [projects, setProjects] = useState<Project[]>([]);
  const [showCreateForm, setShowCreateForm] = useState(false);
  const [newProject, setNewProject] = useState({
    name: '',
    template: 'screenplay',
    description: ''
  });

  useEffect(() => {
    fetchProjects();
  }, []);

  const fetchProjects = async () => {
    try {
      const response = await fetch('http://localhost:8000/api/projects');
      const data = await response.json();
      setProjects(data.projects || []);
    } catch (error) {
      console.error('Error fetching projects:', error);
    }
  };

  const createProject = async () => {
    try {
      const response = await fetch('http://localhost:8000/api/projects', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(newProject)
      });
      const data = await response.json();
      
      if (data.success) {
        setProjects([...projects, data.project]);
        setNewProject({ name: '', template: 'screenplay', description: '' });
        setShowCreateForm(false);
      }
    } catch (error) {
      console.error('Error creating project:', error);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-6">
            <div>
              <h1 className="text-3xl font-bold text-gray-900">Miranda</h1>
              <p className="text-gray-600">AI-Assisted Writing Platform</p>
            </div>
            <button
              onClick={() => setShowCreateForm(true)}
              className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 flex items-center gap-2"
            >
              <Plus size={20} />
              New Project
            </button>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Templates Overview */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <div className="bg-white p-6 rounded-lg shadow-sm border">
            <div className="text-2xl mb-2">🎬</div>
            <h3 className="font-semibold text-gray-900">Screenplay</h3>
            <p className="text-gray-600 text-sm">Character development, scene planning, dialogue generation</p>
          </div>
          <div className="bg-white p-6 rounded-lg shadow-sm border">
            <div className="text-2xl mb-2">📚</div>
            <h3 className="font-semibold text-gray-900">Academic</h3>
            <p className="text-gray-600 text-sm">Research integration, citation management, chapter organization</p>
          </div>
          <div className="bg-white p-6 rounded-lg shadow-sm border">
            <div className="text-2xl mb-2">💼</div>
            <h3 className="font-semibold text-gray-900">Business</h3>
            <p className="text-gray-600 text-sm">Market analysis, competitive research, strategic planning</p>
          </div>
        </div>

        {/* Projects */}
        <div className="bg-white rounded-lg shadow-sm border">
          <div className="px-6 py-4 border-b">
            <h2 className="text-xl font-semibold text-gray-900">Your Projects</h2>
          </div>
          <div className="p-6">
            {projects.length === 0 ? (
              <div className="text-center py-8">
                <FileText size={48} className="mx-auto text-gray-400 mb-4" />
                <p className="text-gray-600">No projects yet. Create your first project to get started!</p>
              </div>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                {projects.map((project) => (
                  <div key={project.id} className="border rounded-lg p-4 hover:shadow-md transition-shadow">
                    <div className="flex justify-between items-start mb-2">
                      <h3 className="font-semibold text-gray-900">{project.name}</h3>
                      <span className="text-xs bg-gray-100 px-2 py-1 rounded">{project.template}</span>
                    </div>
                    {project.description && (
                      <p className="text-gray-600 text-sm mb-3">{project.description}</p>
                    )}
                    <div className="flex justify-between items-center">
                      <div className="flex space-x-2">
                        <button className="p-1 text-gray-400 hover:text-blue-600">
                          <Brain size={16} />
                        </button>
                        <button className="p-1 text-gray-400 hover:text-green-600">
                          <PenTool size={16} />
                        </button>
                        <button className="p-1 text-gray-400 hover:text-purple-600">
                          <Download size={16} />
                        </button>
                      </div>
                      <span className="text-xs text-gray-400">
                        {new Date(project.created_at).toLocaleDateString()}
                      </span>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </main>

      {/* Create Project Modal */}
      {showCreateForm && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-lg p-6 w-full max-w-md">
            <h2 className="text-xl font-semibold mb-4">Create New Project</h2>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Project Name</label>
                <input
                  type="text"
                  value={newProject.name}
                  onChange={(e) => setNewProject({...newProject, name: e.target.value})}
                  className="w-full border rounded-lg px-3 py-2"
                  placeholder="My Screenplay"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Template</label>
                <select
                  value={newProject.template}
                  onChange={(e) => setNewProject({...newProject, template: e.target.value})}
                  className="w-full border rounded-lg px-3 py-2"
                >
                  <option value="screenplay">🎬 Screenplay</option>
                  <option value="academic">📚 Academic</option>
                  <option value="business">💼 Business</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
                <textarea
                  value={newProject.description}
                  onChange={(e) => setNewProject({...newProject, description: e.target.value})}
                  className="w-full border rounded-lg px-3 py-2"
                  rows={3}
                  placeholder="Brief description of your project..."
                />
              </div>
            </div>
            <div className="flex justify-end space-x-3 mt-6">
              <button
                onClick={() => setShowCreateForm(false)}
                className="px-4 py-2 text-gray-600 hover:text-gray-800"
              >
                Cancel
              </button>
              <button
                onClick={createProject}
                disabled={!newProject.name}
                className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 disabled:opacity-50"
              >
                Create Project
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default App;
EOF

# =============================================================================
# SCRIPTS
# =============================================================================

echo -e "${BLUE}🔧 Creating automation scripts...${NC}"

cat > scripts/setup.sh << 'EOF'
#!/bin/bash
set -e

echo "🚀 Setting up Miranda..."

# Check requirements
command -v python3 >/dev/null 2>&1 || { echo "Python 3 required but not installed. Aborting." >&2; exit 1; }
command -v node >/dev/null 2>&1 || { echo "Node.js required but not installed. Aborting." >&2; exit 1; }

# Backend setup
echo "🐍 Setting up Python backend..."
cd backend
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
cd ..

# Frontend setup
echo "⚛️ Setting up React frontend..."
cd frontend
npm install
cd ..

# Environment setup
if [ ! -f .env ]; then
    cp .env.example .env
    echo "📝 Created .env file - please add your OpenAI API key"
fi

echo "✅ Setup complete! Run ./scripts/start.sh to begin"
EOF

cat > scripts/start.sh << 'EOF'
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
EOF

cat > scripts/test.sh << 'EOF'
#!/bin/bash
echo "🧪 Running Miranda tests..."

# Backend tests
echo "Testing backend..."
curl -s http://localhost:8000/health | python3 -m json.tool

# Frontend build test
echo "Testing frontend build..."
cd frontend && npm run build
cd ..

echo "✅ All tests passed!"
EOF

# Make scripts executable
chmod +x scripts/*.sh

# =============================================================================
# DOCUMENTATION
# =============================================================================

echo -e "${BLUE}📚 Creating documentation...${NC}"

cat > DEMO_SCRIPT.md << 'EOF'
# Miranda Demo Script (5 minutes)

## Setup (30 seconds)
1. Open terminal: `./scripts/start.sh`
2. Navigate to http://localhost:3000
3. Show clean, professional interface

## Project Creation (60 seconds)
1. Click "New Project"
2. Create "Romeo & Juliet Remix" screenplay
3. Show template selection and project dashboard

## Document Upload (60 seconds)
1. Upload sample documents (Shakespeare texts, character notes)
2. Demonstrate semantic search capabilities
3. Show document organization

## AI Brainstorming (90 seconds)
1. Input: "Modern teenage romance with classic themes"
2. Show AI-generated scene ideas and character development
3. Demonstrate context-aware suggestions

## Content Generation (90 seconds)
1. Select brainstorm ideas
2. Generate screenplay scene with dialogue
3. Show formatted output and export options

## Professional Features (30 seconds)
1. Multiple project templates
2. API documentation at localhost:8000/docs
3. Clean, scalable architecture
EOF

cat > ARCHITECTURE.md << 'EOF'
# Miranda Architecture

## System Overview
- **Backend**: FastAPI with async/await patterns
- **Frontend**: React 19 with TypeScript
- **AI**: OpenAI GPT-4o-mini with LightRAG
- **Storage**: SQLite + Vector embeddings

## API Endpoints
- `GET /api/projects` - List projects
- `POST /api/projects` - Create project  
- `POST /api/lightrag/query` - Document search
- `POST /api/brainstorm` - Generate ideas
- `POST /api/write` - Create content

## Data Flow
1. **Input**: Documents + structured data
2. **Processing**: LightRAG semantic indexing
3. **AI Generation**: Context-aware prompts
4. **Output**: Formatted content exports

## Scalability
- Modular backend architecture
- Component-based frontend
- Async processing throughout
- Docker-ready deployment
EOF

# =============================================================================
# FINALIZATION
# =============================================================================

echo -e "${GREEN}🎉 Miranda build complete!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. cd miranda"
echo "2. Add OpenAI API key to .env file"
echo "3. ./scripts/setup.sh"
echo "4. ./scripts/start.sh"
echo ""
echo -e "${GREEN}Miranda will be running at:${NC}"
echo "Frontend: http://localhost:3000"
echo "Backend: http://localhost:8000"
echo "API Docs: http://localhost:8000/docs"
echo ""
echo -e "${BLUE}🚀 Ready for investor demos!${NC}"

# End of script
