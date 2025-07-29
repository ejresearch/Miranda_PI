#!/bin/bash

echo "🔧 Miranda Backend Debug & Fix Script"
echo "===================================="

# Check current working directory
echo "📁 Current directory: $(pwd)"
echo "📂 Directory contents:"
ls -la

# Check if we're in the right place
if [ ! -f "backend/main.py" ]; then
    echo "❌ Error: Not in Miranda project root directory"
    echo "Please run this script from the Miranda project root where backend/main.py exists"
    exit 1
fi

# 1. Environment Check
echo ""
echo "🔍 Environment Diagnostics"
echo "=========================="

# Check Python virtual environment
if [ -z "$VIRTUAL_ENV" ]; then
    echo "❌ Virtual environment not activated"
    echo "Run: cd backend && source venv/bin/activate"
else
    echo "✅ Virtual environment active: $VIRTUAL_ENV"
fi

# Check OpenAI API Key
if [ -z "$OPENAI_API_KEY" ]; then
    echo "❌ OPENAI_API_KEY not set in environment"
    echo "Run: export OPENAI_API_KEY='your-key-here'"
else
    echo "✅ OPENAI_API_KEY set (length: ${#OPENAI_API_KEY})"
    # Test if key is valid format
    if [[ $OPENAI_API_KEY =~ ^sk-proj-.{97}$ ]]; then
        echo "✅ API key format looks correct"
    else
        echo "⚠️  API key format may be incorrect (should start with sk-proj- and be ~100 chars)"
    fi
fi

# Check if backend process is running
echo ""
echo "🔍 Process Check"
echo "==============="
if pgrep -f "uvicorn.*main:app" > /dev/null; then
    echo "✅ Backend process is running"
    echo "📊 Process details:"
    pgrep -f "uvicorn.*main:app" | xargs ps -p
else
    echo "❌ Backend process not running"
    echo "Starting backend..."
    cd backend
    if [ ! -d "venv" ]; then
        echo "❌ Virtual environment not found. Creating..."
        python -m venv venv
        source venv/bin/activate
        pip install -r requirements.txt
    else
        source venv/bin/activate
    fi
    
    # Start backend in background
    uvicorn main:app --reload --port 8000 &
    BACKEND_PID=$!
    echo "✅ Backend started with PID: $BACKEND_PID"
    cd ..
    
    # Wait for backend to start
    echo "⏳ Waiting for backend to initialize..."
    sleep 3
fi

# 2. Test basic connectivity
echo ""
echo "🔍 Connectivity Tests"
echo "===================="

# Test health endpoint
echo "Testing health endpoint..."
HEALTH_RESPONSE=$(curl -s -w "HTTPSTATUS:%{http_code}" http://localhost:8000/health 2>/dev/null)
HTTP_STATUS=$(echo $HEALTH_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
RESPONSE_BODY=$(echo $HEALTH_RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')

if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "✅ Health endpoint responding"
    echo "Response: $RESPONSE_BODY"
else
    echo "❌ Health endpoint failed (Status: $HTTP_STATUS)"
    echo "Response: $RESPONSE_BODY"
fi

# Test CORS headers
echo ""
echo "Testing CORS headers..."
CORS_RESPONSE=$(curl -s -I -H "Origin: http://localhost:3000" http://localhost:8000/health 2>/dev/null)
if echo "$CORS_RESPONSE" | grep -q "Access-Control-Allow-Origin"; then
    echo "✅ CORS headers present"
else
    echo "❌ CORS headers missing"
    echo "Need to check FastAPI CORS middleware configuration"
fi

# 3. Test LightRAG integration
echo ""
echo "🔍 LightRAG Integration Test"
echo "==========================="

# Test the custom LightRAG endpoint
echo "Testing LightRAG endpoint..."
LIGHTRAG_TEST=$(curl -s -w "HTTPSTATUS:%{http_code}" \
    -X POST http://localhost:8000/api/lightrag-test \
    -H "Content-Type: application/json" \
    -d '{
        "text": "Miranda is an AI-assisted writing platform.",
        "query": "What is Miranda?"
    }' 2>/dev/null)

LIGHTRAG_STATUS=$(echo $LIGHTRAG_TEST | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
LIGHTRAG_BODY=$(echo $LIGHTRAG_TEST | sed -e 's/HTTPSTATUS\:.*//g')

if [ "$LIGHTRAG_STATUS" -eq 200 ]; then
    echo "✅ LightRAG endpoint responding"
    echo "Response: $LIGHTRAG_BODY"
else
    echo "❌ LightRAG endpoint failed (Status: $LIGHTRAG_STATUS)"
    echo "Response: $LIGHTRAG_BODY"
    
    # Try to identify the specific error
    if echo "$LIGHTRAG_BODY" | grep -q "NoneType.*async.*context"; then
        echo "🔍 Identified: LightRAG async context manager error"
        echo "💡 Fix: Need to update LightRAG initialization in backend code"
    fi
    
    if echo "$LIGHTRAG_BODY" | grep -q "OpenAI.*API.*key"; then
        echo "🔍 Identified: OpenAI API key issue"
        echo "💡 Fix: Check API key validity and credits"
    fi
fi

# 4. Database checks
echo ""
echo "🔍 Database Diagnostics"
echo "======================"

# Check if projects directory exists
if [ -d "projects" ]; then
    echo "✅ Projects directory exists"
    echo "📊 Project count: $(find projects -maxdepth 1 -type d | wc -l)"
    echo "📂 Project directories:"
    ls -la projects/ | head -10
else
    echo "❌ Projects directory missing"
    echo "Creating projects directory..."
    mkdir -p projects
fi

# Test project creation
echo ""
echo "Testing project creation..."
PROJECT_TEST=$(curl -s -w "HTTPSTATUS:%{http_code}" \
    -X POST http://localhost:8000/projects/ \
    -H "Content-Type: application/json" \
    -d '{
        "name": "Debug Test Project",
        "template": "screenplay",
        "description": "Test project for debugging"
    }' 2>/dev/null)

PROJECT_STATUS=$(echo $PROJECT_TEST | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
PROJECT_BODY=$(echo $PROJECT_TEST | sed -e 's/HTTPSTATUS\:.*//g')

if [ "$PROJECT_STATUS" -eq 200 ]; then
    echo "✅ Project creation works"
    echo "Response: $PROJECT_BODY"
else
    echo "❌ Project creation failed (Status: $PROJECT_STATUS)"
    echo "Response: $PROJECT_BODY"
fi

# Test project listing
echo ""
echo "Testing project listing..."
LIST_TEST=$(curl -s -w "HTTPSTATUS:%{http_code}" http://localhost:8000/projects/ 2>/dev/null)
LIST_STATUS=$(echo $LIST_TEST | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
LIST_BODY=$(echo $LIST_TEST | sed -e 's/HTTPSTATUS\:.*//g')

if [ "$LIST_STATUS" -eq 200 ]; then
    echo "✅ Project listing works"
    echo "Response: $LIST_BODY"
else
    echo "❌ Project listing failed (Status: $LIST_STATUS)"
    echo "Response: $LIST_BODY"
fi

# 5. Fix recommendations
echo ""
echo "🔧 Fix Recommendations"
echo "====================="

echo "Based on the diagnostics above, here are the recommended fixes:"
echo ""

if [ "$HTTP_STATUS" -ne 200 ]; then
    echo "1. ❌ Backend Health Issue:"
    echo "   - Check if backend is running: uvicorn main:app --reload --port 8000"
    echo "   - Check for port conflicts: lsof -i :8000"
    echo "   - Check backend logs for errors"
    echo ""
fi

if ! echo "$CORS_RESPONSE" | grep -q "Access-Control-Allow-Origin"; then
    echo "2. ❌ CORS Issue:"
    echo "   - Add CORS middleware to FastAPI app"
    echo "   - Ensure allow_origins includes http://localhost:3000"
    echo ""
fi

if [ "$LIGHTRAG_STATUS" -ne 200 ]; then
    echo "3. ❌ LightRAG Integration Issue:"
    echo "   - Update LightRAG initialization code"
    echo "   - Fix async context manager setup"
    echo "   - Verify OpenAI API key and credits"
    echo ""
fi

if [ "$PROJECT_STATUS" -ne 200 ] || [ "$LIST_STATUS" -ne 200 ]; then
    echo "4. ❌ Database/Project Issue:"
    echo "   - Check database connection"
    echo "   - Verify project model validation"
    echo "   - Check file permissions on projects directory"
    echo ""
fi

echo "💡 Next Steps:"
echo "1. Fix the issues identified above"
echo "2. Run the test suite again: ./test_miranda_backend.sh"
echo "3. Check backend logs for detailed error messages"
echo "4. If issues persist, check individual backend modules"

echo ""
echo "🏁 Diagnostic Complete"
echo "====================="
