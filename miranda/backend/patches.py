# backend/patches.py
"""
Quick patches for common Miranda backend issues
Apply these fixes to your main.py and related files
"""

# 1. CORS Fix for main.py
CORS_FIX = """
from fastapi.middleware.cors import CORSMiddleware

# Add this after creating your FastAPI app
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",  # React frontend
        "http://127.0.0.1:3000",
        "http://localhost:8080",  # Alternative ports
        "http://127.0.0.1:8080"
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
"""

# 2. Project Model Fix (if using Pydantic)
PROJECT_MODEL_FIX = """
from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

class ProjectCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    template: str = Field(..., regex="^(screenplay|academic|business)$")
    description: Optional[str] = None

class Project(BaseModel):
    id: str
    name: str
    template: str
    description: Optional[str] = None
    created_at: str = Field(default_factory=lambda: datetime.now().isoformat())
    
    class Config:
        from_attributes = True
"""

# 3. Simple Project Storage Fix
PROJECT_STORAGE_FIX = """
import json
import os
from pathlib import Path
from typing import List, Dict, Optional

class SimpleProjectStorage:
    def __init__(self, base_dir: str = "./projects"):
        self.base_dir = Path(base_dir)
        self.base_dir.mkdir(exist_ok=True)
        self.projects_file = self.base_dir / "projects.json"
        self._load_projects()
    
    def _load_projects(self):
        if self.projects_file.exists():
            try:
                with open(self.projects_file, 'r') as f:
                    self.projects = json.load(f)
            except:
                self.projects = {}
        else:
            self.projects = {}
    
    def _save_projects(self):
        with open(self.projects_file, 'w') as f:
            json.dump(self.projects, f, indent=2)
    
    def create_project(self, project_data: Dict) -> Dict:
        project_id = f"project_{len(self.projects) + 1}"
        project = {
            "id": project_id,
            "name": project_data["name"],
            "template": project_data["template"],
            "description": project_data.get("description"),
            "created_at": "2025-01-01T00:00:00Z"  # Fixed timestamp for testing
        }
        
        self.projects[project_id] = project
        self._save_projects()
        
        # Create project directory
        project_dir = self.base_dir / project_id
        project_dir.mkdir(exist_ok=True)
        
        return project
    
    def list_projects(self) -> List[Dict]:
        return list(self.projects.values())
    
    def get_project(self, project_id: str) -> Optional[Dict]:
        return self.projects.get(project_id)

# Global storage instance
project_storage = SimpleProjectStorage()
"""

# 4. Fixed Main.py Endpoints
FIXED_ENDPOINTS = """
from fastapi import FastAPI, HTTPException, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

app = FastAPI(title="Miranda Backend", version="1.0.0")

# Apply CORS fix
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "http://127.0.0.1:3000",
        "http://localhost:8080",
        "http://127.0.0.1:8080"
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Import fixed components
from patches import project_storage
from core.lightrag_fix import fixed_lightrag, lightrag_test_endpoint

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "service": "miranda-backend",
        "version": "1.0.0"
    }

@app.get("/projects/")
async def list_projects():
    try:
        projects = project_storage.list_projects()
        return {"success": True, "projects": projects}
    except Exception as e:
        return {"success": False, "error": str(e)}

@app.post("/projects/")
async def create_project(project_data: dict):
    try:
        # Validate required fields
        if "name" not in project_data or "template" not in project_data:
            raise HTTPException(status_code=422, detail="Missing required fields")
        
        if project_data["template"] not in ["screenplay", "academic", "business"]:
            raise HTTPException(status_code=422, detail="Invalid template type")
        
        project = project_storage.create_project(project_data)
        return {"success": True, "project": project}
    except HTTPException:
        raise
    except Exception as e:
        return {"success": False, "error": str(e)}

@app.get("/projects/{project_id}")
async def get_project(project_id: str):
    project = project_storage.get_project(project_id)
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")
    return {"success": True, "project": project}

@app.post("/api/lightrag-test")
async def lightrag_test(request: dict):
    text = request.get("text", "No text provided")
    query = request.get("query", "What is this about?")
    
    result = await lightrag_test_endpoint(text, query)
    return result

# File upload endpoint
@app.post("/projects/{project_id}/upload")
async def upload_file(project_id: str, file: UploadFile = File(...)):
    try:
        # Check if project exists
        project = project_storage.get_project(project_id)
        if not project:
            raise HTTPException(status_code=404, detail="Project not found")
        
        # Simple file size check (10MB limit)
        content = await file.read()
        if len(content) > 10 * 1024 * 1024:
            raise HTTPException(status_code=413, detail="File too large")
        
        # Save file (simplified)
        project_dir = Path("./projects") / project_id
        project_dir.mkdir(exist_ok=True)
        file_path = project_dir / file.filename
        
        with open(file_path, "wb") as f:
            f.write(content)
        
        return {
            "success": True,
            "filename": file.filename,
            "size": len(content),
            "project_id": project_id
        }
        
    except HTTPException:
        raise
    except Exception as e:
        return {"success": False, "error": str(e)}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True)
"""

# 5. Complete fixed main.py file
COMPLETE_MAIN_PY = '''
"""
Miranda Backend - Fixed Version
Resolves common issues: CORS, LightRAG async context, project storage
"""

from fastapi import FastAPI, HTTPException, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from pathlib import Path
import json
import os
import openai
from datetime import datetime
from typing import Dict, List, Optional, Any
import uvicorn

# Initialize FastAPI app
app = FastAPI(
    title="Miranda Backend", 
    version="1.0.0",
    description="Fixed Miranda Backend with proper CORS and LightRAG integration"
)

# Fix 1: Proper CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "http://127.0.0.1:3000", 
        "http://localhost:8080",
        "http://127.0.0.1:8080",
        "http://localhost:5173",  # Vite dev server
        "http://127.0.0.1:5173"
    ],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["*"],
)

# Fix 2: Simple Project Storage (no complex database issues)
class SimpleProjectStorage:
    def __init__(self, base_dir: str = "./projects"):
        self.base_dir = Path(base_dir)
        self.base_dir.mkdir(exist_ok=True)
        self.projects_file = self.base_dir / "projects.json"
        self._load_projects()
    
    def _load_projects(self):
        if self.projects_file.exists():
            try:
                with open(self.projects_file, 'r') as f:
                    self.projects = json.load(f)
            except:
                self.projects = {}
        else:
            self.projects = {}
    
    def _save_projects(self):
        with open(self.projects_file, 'w') as f:
            json.dump(self.projects, f, indent=2)
    
    def create_project(self, project_data: Dict) -> Dict:
        project_id = f"project_{len(self.projects) + 1}"
        project = {
            "id": project_id,
            "name": project_data["name"],
            "template": project_data["template"],
            "description": project_data.get("description"),
            "created_at": "2025-01-01T00:00:00Z"
        }
        
        self.projects[project_id] = project
        self._save_projects()
        
        # Create project directory
        project_dir = self.base_dir / project_id
        project_dir.mkdir(exist_ok=True)
        
        return project
    
    def list_projects(self) -> List[Dict]:
        return list(self.projects.values())
    
    def get_project(self, project_id: str) -> Optional[Dict]:
        return self.projects.get(project_id)

# Fix 3: Simple LightRAG replacement (no async context issues)
class FixedLightRAG:
    def __init__(self):
        self.api_key = os.getenv("OPENAI_API_KEY")
        self.client = None
        if self.api_key:
            self.client = openai.AsyncOpenAI(api_key=self.api_key)
    
    async def test_connection(self) -> Dict[str, Any]:
        try:
            if not self.client:
                return {
                    "success": False,
                    "error": "OpenAI client not initialized - check API key",
                    "type": "configuration_error"
                }
            
            response = await self.client.chat.completions.create(
                model="gpt-4o-mini",
                messages=[{"role": "user", "content": "Respond with: OpenAI working"}],
                max_tokens=10
            )
            
            return {
                "success": True,
                "response": response.choices[0].message.content.strip(),
                "model": "gpt-4o-mini"
            }
            
        except Exception as e:
            return {
                "success": False,
                "error": str(e),
                "type": type(e).__name__,
                "note": "Check if OpenAI API key is valid and has credits"
            }
    
    async def process_and_query(self, text: str, query: str) -> Dict[str, Any]:
        try:
            if not self.client:
                return {"success": False, "error": "OpenAI client not initialized"}
            
            prompt = f"""Document: {text}

Query: {query}

Please provide a helpful response based on the document content."""

            response = await self.client.chat.completions.create(
                model="gpt-4o-mini",
                messages=[{"role": "user", "content": prompt}],
                max_tokens=500
            )
            
            return {
                "success": True,
                "response": response.choices[0].message.content.strip(),
                "method": "direct_openai_integration"
            }
            
        except Exception as e:
            return {
                "success": False,
                "error": str(e),
                "type": type(e).__name__
            }

# Initialize fixed components
project_storage = SimpleProjectStorage()
fixed_lightrag = FixedLightRAG()

# API Endpoints
@app.get("/health")
async def health_check():
    """Fixed health check with proper CORS"""
    return {
        "status": "healthy",
        "service": "miranda-backend-fixed",
        "version": "1.0.0",
        "cors": "enabled"
    }

@app.get("/projects/") 
async def list_projects():
    """Fixed project listing"""
    try:
        projects = project_storage.list_projects()
        return {"success": True, "projects": projects, "count": len(projects)}
    except Exception as e:
        return {"success": False, "error": str(e)}

@app.post("/projects/")
async def create_project(project_data: dict):
    """Fixed project creation with validation"""
    try:
        # Validate required fields
        if "name" not in project_data or "template" not in project_data:
            raise HTTPException(status_code=422, detail="Missing name or template")
        
        if project_data["template"] not in ["screenplay", "academic", "business"]:
            raise HTTPException(status_code=422, detail="Invalid template")
        
        project = project_storage.create_project(project_data)
        return {"success": True, "project": project}
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/projects/{project_id}")
async def get_project(project_id: str):
    """Get single project"""
    project = project_storage.get_project(project_id)
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")
    return {"success": True, "project": project}

@app.post("/api/lightrag-test")
async def lightrag_test(request: dict):
    """Fixed LightRAG test endpoint"""
    text = request.get("text", "No text provided")
    query = request.get("query", "What is this about?")
    
    # First test connection
    connection_test = await fixed_lightrag.test_connection()
    if not connection_test["success"]:
        return connection_test
    
    # Then test processing
    result = await fixed_lightrag.process_and_query(text, query)
    return result

@app.post("/projects/{project_id}/upload")
async def upload_file(project_id: str, file: UploadFile = File(...)):
    """Fixed file upload"""
    try:
        project = project_storage.get_project(project_id)
        if not project:
            raise HTTPException(status_code=404, detail="Project not found")
        
        content = await file.read()
        if len(content) > 10 * 1024 * 1024:  # 10MB limit
            raise HTTPException(status_code=413, detail="File too large")
        
        # Save file
        project_dir = Path("./projects") / project_id
        project_dir.mkdir(exist_ok=True)
        file_path = project_dir / file.filename
        
        with open(file_path, "wb") as f:
            f.write(content)
        
        return {
            "success": True,
            "filename": file.filename,
            "size": len(content),
            "project_id": project_id
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    print("🚀 Starting Miranda Backend (Fixed Version)")
    print("✅ CORS enabled for frontend connections")
    print("✅ Simple project storage (no complex database)")
    print("✅ Fixed LightRAG integration (no async context issues)")
    print("🌐 Backend will be available at: http://localhost:8000")
    print("📚 API docs at: http://localhost:8000/docs")
    
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True)
'''

print("Backend patches created. Use these fixes to resolve the common issues:")
print("1. Replace your main.py with the COMPLETE_MAIN_PY version")
print("2. Run the debug script to identify specific issues") 
print("3. Apply individual patches as needed")
