#!/bin/bash
set -e

echo "🚀 Setting up Miranda..."

# Backend setup
echo "Setting up Python backend..."
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cd ..

# Frontend setup  
echo "Setting up React frontend..."
cd frontend
npm install
cd ..

# Environment
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo "✅ Created .env file - add your OpenAI API key!"
fi

echo "🎉 Setup complete! Run ./start.sh to begin"
