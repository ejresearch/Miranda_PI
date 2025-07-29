# backend/main.py - Fixed version that bypasses LightRAG CLI issues

from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from dotenv import load_dotenv
import os
import sys
import tempfile
import shutil  

load_dotenv()

app = FastAPI(title="Miranda API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class Project(BaseModel):
    name: str
    template: str

class LightRAGTest(BaseModel):
    text: str
    query: str

projects = []

@app.get("/health")
async def health():
    return {
        "status": "healthy",
        "openai_key_set": bool(os.getenv("OPENAI_API_KEY")),
        "lightrag_test": "available"
    }

@app.get("/api/projects")
async def get_projects():
    return {"projects": projects}

@app.post("/api/projects")
async def create_project(project: Project):
    projects.append(project.dict())
    return {"success": True, "project": project}

@app.post("/api/upload")
async def upload_file(file: UploadFile = File(...)):
    content = await file.read()
    return {"filename": file.filename, "size": len(content)}

@app.post("/api/lightrag-test")
async def test_lightrag(data: LightRAGTest):
    """Test LightRAG with CLI argument bypass and proper async handling"""
    if not os.getenv("OPENAI_API_KEY"):
        return {
            "success": False,
            "error": "OPENAI_API_KEY not set in environment",
            "note": "Add your OpenAI API key to .env file"
        }
    
    try:
        # CRITICAL FIX: Temporarily override sys.argv to bypass CLI parsing
        original_argv = sys.argv.copy()
        sys.argv = ['lightrag']  # Minimal argv that won't cause parsing errors
        
        try:
            from lightrag import LightRAG, QueryParam
            from lightrag.llm.openai import gpt_4o_mini_complete, openai_embed
            
            # Create temporary directory for this test
            temp_dir = tempfile.mkdtemp()
            
            try:
                # Initialize LightRAG with minimal config
                rag = LightRAG(
                    working_dir=temp_dir,
                    llm_model_func=gpt_4o_mini_complete,
                    embedding_func=openai_embed,
                )
                
                # Insert document (using synchronous method if async fails)
                try:
                    await rag.ainsert(data.text)
                except AttributeError:
                    # Fallback to sync method if async not available
                    rag.insert(data.text)
                
                # Query document (using synchronous method if async fails)
                try:
                    result = await rag.aquery(data.query, param=QueryParam(mode="hybrid"))
                except AttributeError:
                    # Fallback to sync method if async not available
                    result = rag.query(data.query, param=QueryParam(mode="hybrid"))
                
                return {
                    "success": True,
                    "message": "LightRAG working perfectly!",
                    "inserted_text": data.text,
                    "query": data.query,
                    "result": result[:300] + "..." if len(result) > 300 else result,
                    "full_result_length": len(result)
                }
                
            finally:
                # Clean up temp directory
                import shutil
                shutil.rmtree(temp_dir, ignore_errors=True)
                
        finally:
            # CRITICAL: Restore original sys.argv
            sys.argv = original_argv
            
    except ImportError as e:
        return {
            "success": False,
            "error": f"LightRAG import failed: {str(e)}",
            "suggestion": "Try: pip uninstall lightrag -y && pip install git+https://github.com/HKUDS/LightRAG.git"
        }
    except Exception as e:
        return {
            "success": False,
            "error": f"LightRAG execution failed: {str(e)}",
            "type": type(e).__name__,
            "note": "Check if OpenAI API key is valid and has credits"
        }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
