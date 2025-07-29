# Miranda: AI-Assisted Writing Platform

> Transform your writing process with intelligent research, brainstorming, and content generation

## 🎯 Overview

Miranda is a comprehensive AI-assisted writing platform that combines structured data management, semantic document search, and intelligent content generation. Whether you're writing screenplays, academic papers, or business documents, Miranda provides the tools to research, organize, and create with unprecedented efficiency.

### ✨ Key Features

- **🏗️ Structured Projects**: Organize your work with templates for different writing domains
- **📚 Smart Document Management**: Upload and semantically search through research documents
- **📊 Data Integration**: Import and work with structured data (CSV, databases)
- **🧠 AI Brainstorming**: Generate insights by combining your documents and data
- **✍️ Intelligent Writing**: Create content that draws from all your research
- **📤 Multi-Format Export**: Export to PDF, HTML, DOCX, and more

## 🚀 Quick Start

```bash
# Clone the repository
git clone <repository-url>
cd miranda

# Set up the environment
./scripts/setup.sh

# Start the development servers
./scripts/start.sh
```

Visit http://localhost:3000 to access the Miranda interface.

## 📁 Project Templates

### 🎬 Screenplay Writing
- **Document Buckets**: `screenplay_examples`, `film_theory`, `character_guides`
- **Data Tables**: `character_types`, `scene_beats`, `story_structure`
- **Workflow**: Research → Structure → Brainstorm → Write → Export

### 📚 Academic Writing
- **Document Buckets**: `primary_sources`, `academic_papers`, `research_notes`
- **Data Tables**: `citations`, `timeline_data`, `key_concepts`
- **Workflow**: Research → Data → Analysis → Writing → Export

### 💼 Business Documents
- **Document Buckets**: `market_research`, `competitor_analysis`, `industry_reports`
- **Data Tables**: `metrics`, `strategies`, `benchmarks`
- **Workflow**: Research → Analysis → Planning → Writing → Export

## 🔧 Technology Stack

- **Backend**: FastAPI, Python, SQLite, LightRAG
- **Frontend**: React 19, TypeScript, Tailwind CSS
- **AI Integration**: OpenAI GPT-4, Custom prompt engineering
- **Storage**: SQLite (structured data), Vector storage (documents)

## 🧪 Development

```bash
# Run tests
./scripts/test.sh

# Clean build artifacts
./scripts/clean.sh

# Create backup
./scripts/backup.sh
```

## 📖 Documentation

- [Demo Script](DEMO_SCRIPT.md) - 5-minute investor walkthrough
- [Architecture](ARCHITECTURE.md) - Technical system design
- [User Guides](docs/guides/) - Step-by-step tutorials

## 🤝 Contributing

Miranda is designed for professional use and active development. See our contribution guidelines for details.

## 📄 License

[License information]

---

**Miranda**: Where research meets creativity, powered by AI.
