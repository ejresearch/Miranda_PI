#!/bin/bash
# fix_lightrag.sh - Complete LightRAG fix for Miranda

echo "🔧 Fixing LightRAG import issues..."

# Stop any running servers
pkill -f "uvicorn"
pkill -f "npm run dev"

cd backend
source venv/bin/activate

echo "📦 Step 1: Clean install of LightRAG"
# Remove all lightrag packages
pip uninstall lightrag lightrag-hku -y

# Remove any conflicting directories
rm -rf LightRAG/

echo "📦 Step 2: Install correct LightRAG package"
# Install the working version from HKU
pip install git+https://github.com/HKUDS/LightRAG.git

echo "🧪 Step 3: Test imports"
python -c "
try:
    from lightrag import LightRAG, QueryParam
    from lightrag.llm.openai import gpt_4o_mini_complete, openai_embed
    print('✅ LightRAG imports successful!')
except ImportError as e:
    print(f'❌ Import failed: {e}')
    # Try alternative import structure
    try:
        import lightrag
        from lightrag.base import QueryParam
        print('✅ Alternative import successful!')
        print('Available modules:', dir(lightrag))
    except Exception as e2:
        print(f'❌ Alternative failed: {e2}')
"

echo "📝 Step 4: Create working backend"
cat > main.py << 'EOF'
from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from dotenv import load_dotenv
import os
import tempfile
import asyncio

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
        "lightrag_available": check_lightrag_availability()
    }

def check_lightrag_availability():
    """Check if LightRAG can be imported properly"""
    try:
        from lightrag import LightRAG, QueryParam
        return True
    except ImportError:
        try:
            import lightrag
            return True
        except ImportError:
            return False

@app.get("/api/projects")
async def get_projects():
    return {"projects": projects}

@app.post("/api/projects")
async def create_project(project: Project):
    projects.append(project.dict())
    return {"success": True, "project": project}

@app.post("/api/upload")
async def upload_file(file: UploadFile = File(...)):
    return {"filename": file.filename, "size": len(await file.read())}

@app.post("/api/lightrag-test")
async def test_lightrag(data: LightRAGTest):
    """Test LightRAG functionality with proper error handling"""
    if not os.getenv("OPENAI_API_KEY"):
        return {
            "success": False,
            "error": "OPENAI_API_KEY not set in environment",
            "note": "Add your OpenAI API key to .env file"
        }
    
    try:
        # Try primary import method
        from lightrag import LightRAG, QueryParam
        from lightrag.llm.openai import gpt_4o_mini_complete, openai_embed
        
        # Create temporary directory for this test
        with tempfile.TemporaryDirectory() as temp_dir:
            # Initialize LightRAG
            rag = LightRAG(
                working_dir=temp_dir,
                llm_model_func=gpt_4o_mini_complete,
                embedding_func=openai_embed,
            )
            
            # Insert document
            await rag.ainsert(data.text)
            
            # Query document
            result = await rag.aquery(data.query, param=QueryParam(mode="hybrid"))
            
            return {
                "success": True,
                "message": "LightRAG working perfectly!",
                "inserted_text": data.text,
                "query": data.query,
                "result": result[:200] + "..." if len(result) > 200 else result,
                "full_result_length": len(result)
            }
            
    except ImportError as e:
        return {
            "success": False,
            "error": f"LightRAG import failed: {str(e)}",
            "suggestion": "Try running: pip install git+https://github.com/HKUDS/LightRAG.git"
        }
    except Exception as e:
        return {
            "success": False,
            "error": f"LightRAG execution failed: {str(e)}",
            "type": type(e).__name__
        }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
EOF

echo "✅ Fixed backend created!"

cd ..

echo "🚀 Step 5: Test the fix"
echo "Starting servers in 3 seconds..."
sleep 3

./start.sh &
SERVER_PID=$!

# Wait a moment for servers to start
sleep 5

echo "🧪 Testing LightRAG endpoint..."
curl -X POST http://localhost:8000/api/lightrag-test \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Miranda is an AI-assisted writing platform that helps with screenplay and academic writing.",
    "query": "What is Miranda?"
  }' \
  | python -m json.tool

echo ""
echo "✅ Fix complete! Check the results above."
echo "If successful, both frontend and backend should be running."
echo "Press Ctrl+C to stop servers."

wait $SERVER_PID
