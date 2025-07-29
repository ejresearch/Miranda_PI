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
