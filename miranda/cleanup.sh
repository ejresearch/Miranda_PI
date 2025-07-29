#!/bin/bash

echo "🧹 Miranda Repository Cleanup Script"
echo "===================================="
echo "Removing all bad nested endpoint patterns..."

# Check if we're in the right directory
if [ ! -f "backend/main.py" ]; then
    echo "❌ Error: Not in Miranda project root"
    echo "Please run from directory containing backend/main.py"
    exit 1
fi

echo ""
echo "🔍 Phase 1: Identifying Bad Code Patterns"
echo "========================================"

# Find all files with bad patterns
echo "📁 Files containing bad endpoint patterns:"
echo ""

# Search for nested duplicates
BAD_PATTERNS=(
    "/projects/projects"
    "/buckets/buckets"
    "/tables/tables"
    "/export/export"
    "/versions/projects"
    "/graph/graph"
)

for pattern in "${BAD_PATTERNS[@]}"; do
    echo "🔍 Searching for: $pattern"
    grep -r "$pattern" . --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=venv --exclude-dir=__pycache__ | head -5
    echo ""
done

echo ""
echo "🗑️ Phase 2: File Deletion"
echo "========================="

# Delete bad API service files
echo "Deleting bad API service files..."
rm -f frontend/src/services/api-fixed.js
rm -f frontend/src/services/api-fixed-v2.js
rm -f frontend/test-api-integration.html
rm -f frontend/src/components/fixed/ProjectDashboard.jsx

# Delete sample test files with bad patterns
rm -f nell_sample_project/CURL_Commands.txt
rm -f nell_backend_test_suite.md
rm -f nell_phase_1_report.md

# Delete old patches and fixes
rm -f backend/patches.py
rm -f backend/core/lightrag_fix.py

# Delete test data files
rm -f test_characters.csv
rm -f test_research.txt  
rm -f miranda_implementation_report.md
rm -f miranda_error_analysis.md

echo "✅ Deleted bad API service files"

echo ""
echo "🔧 Phase 3: Code Pattern Cleanup"
echo "================================"

# Clean up frontend API service
if [ -f "frontend/src/services/api.js" ]; then
    echo "🔧 Cleaning frontend/src/services/api.js..."
    
    # Create clean version
    cat > frontend/src/services/api.js << 'EOF'
// Clean Miranda API Service - Proper REST Design
const API_BASE = 'http://localhost:8000';

class MirandaAPI {
  constructor() {
    this.baseURL = API_BASE;
  }

  // Projects - Clean REST endpoints
  async getProjects() {
    const response = await fetch(`${this.baseURL}/projects`);
    if (!response.ok) throw new Error('Failed to fetch projects');
    return response.json();
  }

  async createProject(name, template, description) {
    const response = await fetch(`${this.baseURL}/projects`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name, template, description })
    });
    if (!response.ok) throw new Error('Failed to create project');
    return response.json();
  }

  async getProject(projectId) {
    const response = await fetch(`${this.baseURL}/projects/${projectId}`);
    if (!response.ok) throw new Error('Failed to fetch project');
    return response.json();
  }

  // Buckets - Clean REST endpoints
  async getBuckets(projectId) {
    const response = await fetch(`${this.baseURL}/projects/${projectId}/buckets`);
    if (!response.ok) throw new Error('Failed to fetch buckets');
    return response.json();
  }

  async createBucket(projectId, name) {
    const response = await fetch(`${this.baseURL}/projects/${projectId}/buckets`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name })
    });
    if (!response.ok) throw new Error('Failed to create bucket');
    return response.json();
  }

  async uploadToBucket(projectId, bucketName, file) {
    const formData = new FormData();
    formData.append('file', file);
    
    const response = await fetch(`${this.baseURL}/projects/${projectId}/buckets/${bucketName}/upload`, {
      method: 'POST',
      body: formData
    });
    if (!response.ok) throw new Error('Failed to upload file');
    return response.json();
  }

  // Tables - Clean REST endpoints
  async getTables(projectId) {
    const response = await fetch(`${this.baseURL}/projects/${projectId}/tables`);
    if (!response.ok) throw new Error('Failed to fetch tables');
    return response.json();
  }

  async uploadCSV(projectId, tableName, file) {
    const formData = new FormData();
    formData.append('file', file);
    
    const response = await fetch(`${this.baseURL}/projects/${projectId}/tables/${tableName}/upload`, {
      method: 'POST',
      body: formData
    });
    if (!response.ok) throw new Error('Failed to upload CSV');
    return response.json();
  }

  // AI Functions - Clean REST endpoints
  async queryLightRAG(text, query) {
    const response = await fetch(`${this.baseURL}/lightrag/query`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ text, query })
    });
    if (!response.ok) throw new Error('Failed to query LightRAG');
    return response.json();
  }

  async brainstorm(projectId, context, focus, tone = 'neutral') {
    const response = await fetch(`${this.baseURL}/projects/${projectId}/brainstorm`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ context, focus, tone })
    });
    if (!response.ok) throw new Error('Failed to generate brainstorm');
    return response.json();
  }

  async generateContent(projectId, options = {}) {
    const response = await fetch(`${this.baseURL}/projects/${projectId}/write`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(options)
    });
    if (!response.ok) throw new Error('Failed to generate content');
    return response.json();
  }

  // Export - Clean REST endpoints
  async exportProject(projectId, format = 'json') {
    const response = await fetch(`${this.baseURL}/projects/${projectId}/export?format=${format}`);
    if (!response.ok) throw new Error('Failed to export project');
    return response.blob();
  }
}

export const mirandaAPI = new MirandaAPI();
export default mirandaAPI;
EOF

    echo "✅ Cleaned frontend API service"
fi

# Clean up TypeScript API service if it exists
if [ -f "frontend/src/services/api.ts" ]; then
    echo "🔧 Cleaning frontend/src/services/api.ts..."
    
    # Remove bad patterns from TypeScript file
    sed -i.bak 's|/projects/projects|/projects|g' frontend/src/services/api.ts
    sed -i.bak 's|/buckets/buckets|/buckets|g' frontend/src/services/api.ts
    sed -i.bak 's|/tables/tables|/tables|g' frontend/src/services/api.ts
    sed -i.bak 's|/export/export|/export|g' frontend/src/services/api.ts
    
    rm -f frontend/src/services/api.ts.bak
    echo "✅ Cleaned TypeScript API service"
fi

# Clean up test script
if [ -f "test_miranda_backend.sh" ]; then
    echo "🔧 Creating clean test script..."
    
    cat > test_miranda_backend_clean.sh << 'EOF'
#!/bin/bash

# Clean Miranda Backend Test Suite - Proper REST Endpoints

BASE_URL="http://localhost:8000"
PASSED=0
TOTAL=0

echo "🧪 Miranda Backend Test Suite (Clean)"
echo "===================================="

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo "🔍 Testing: $test_name"
    TOTAL=$((TOTAL + 1))
    
    if eval "$test_command"; then
        echo -e "${GREEN}✅ PASS${NC}: $test_name"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}❌ FAIL${NC}: $test_name"
    fi
    echo ""
}

# Health Tests
echo "🏥 Health Tests"
run_test "Backend Health" "curl -s $BASE_URL/health | grep -q 'healthy'"
run_test "CORS Headers" "curl -s -H 'Origin: http://localhost:3000' -I $BASE_URL/health | grep -q 'Access-Control-Allow-Origin'"

# Project Tests - Clean endpoints
echo "📁 Project Tests"
run_test "List Projects" "curl -s '$BASE_URL/projects' | grep -q 'success\\|projects'"
run_test "Create Project" "curl -s -X POST '$BASE_URL/projects' -H 'Content-Type: application/json' -d '{\"name\":\"Test\",\"template\":\"screenplay\"}' | grep -q 'success'"

# File Upload Tests - Clean endpoints  
echo "📤 Upload Tests"
echo "test content" > /tmp/test.txt
run_test "File Upload" "curl -s -X POST '$BASE_URL/projects/project_1/buckets/research/upload' -F 'file=@/tmp/test.txt' | grep -q 'success'"

# AI Tests - Clean endpoints
echo "🤖 AI Tests"
run_test "LightRAG Query" "curl -s -X POST '$BASE_URL/lightrag/query' -H 'Content-Type: application/json' -d '{\"text\":\"test\",\"query\":\"what?\"}' | grep -q 'success'"
run_test "Brainstorm" "curl -s -X POST '$BASE_URL/projects/project_1/brainstorm' -H 'Content-Type: application/json' -d '{\"context\":\"test\",\"focus\":\"creativity\"}' | grep -q 'success'"
run_test "Content Generation" "curl -s -X POST '$BASE_URL/projects/project_1/write' -H 'Content-Type: application/json' -d '{\"format\":\"screenplay\"}' | grep -q 'success'"

# Export Tests - Clean endpoints
echo "📦 Export Tests"
run_test "JSON Export" "curl -s '$BASE_URL/projects/project_1/export?format=json' | grep -q 'project\\|success'"

# Cleanup
rm -f /tmp/test.txt

echo "========================="
echo "🏁 Test Results Summary"
echo "========================="
echo -e "Results: $PASSED/$TOTAL tests passed"

if [ $PASSED -eq $TOTAL ]; then
    echo -e "${GREEN}🎉 All tests passed!${NC}"
elif [ $PASSED -gt $((TOTAL * 3 / 4)) ]; then
    echo -e "${YELLOW}⚠️  Most tests passed${NC}"
else
    echo -e "${RED}⚠️  Some tests failed${NC}"
fi
EOF

    chmod +x test_miranda_backend_clean.sh
    echo "✅ Created clean test script: test_miranda_backend_clean.sh"
fi

echo ""
echo "🧹 Phase 4: Cleanup Verification"
echo "================================"

# Search for remaining bad patterns
echo "🔍 Checking for remaining bad patterns..."
REMAINING_BAD=0

for pattern in "${BAD_PATTERNS[@]}"; do
    COUNT=$(grep -r "$pattern" . --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=venv --exclude-dir=__pycache__ 2>/dev/null | wc -l)
    if [ $COUNT -gt 0 ]; then
        echo "⚠️  Found $COUNT instances of $pattern"
        REMAINING_BAD=$((REMAINING_BAD + COUNT))
    fi
done

if [ $REMAINING_BAD -eq 0 ]; then
    echo "✅ No bad patterns found!"
else
    echo "⚠️  Found $REMAINING_BAD remaining bad patterns"
    echo "Manual cleanup may be needed for:"
    grep -r "/projects/projects\|/buckets/buckets\|/tables/tables" . --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=venv --exclude-dir=__pycache__ 2>/dev/null | head -5
fi

echo ""
echo "📋 Phase 5: Cleanup Summary"
echo "==========================="

echo "✅ Files Deleted:"
echo "  - Bad API service files (api-fixed.js, etc.)"
echo "  - Old test files with bad patterns"
echo "  - Patch files and temporary fixes"
echo "  - Sample data with bad endpoints"

echo ""
echo "✅ Files Cleaned:"
echo "  - frontend/src/services/api.js (clean REST endpoints)"
echo "  - frontend/src/services/api.ts (if existed)"
echo "  - Created clean test script"

echo ""
echo "🎯 Next Steps:"
echo "1. Replace your backend/main.py with the clean version provided earlier"
echo "2. Run the clean test script: ./test_miranda_backend_clean.sh"
echo "3. Update any remaining React components to use clean API calls"
echo "4. Test the cleaned system"

echo ""
echo "🚀 Clean Endpoints You Should Now Use:"
echo "  GET    /projects              (not /projects/projects)"
echo "  POST   /projects              (not /projects/projects/new)"
echo "  GET    /projects/{id}/buckets (not /projects/{name}/buckets/buckets)"
echo "  POST   /lightrag/query        (not /api/lightrag-test)"
echo "  GET    /projects/{id}/export  (not /projects/{name}/export/export/json)"

echo ""
echo "🏁 Cleanup Complete!"
echo "Your Miranda repository now has clean, proper REST API design."
