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
