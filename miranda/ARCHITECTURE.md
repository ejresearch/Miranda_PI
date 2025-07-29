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
