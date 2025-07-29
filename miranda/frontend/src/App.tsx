import React, { useState, useEffect } from 'react';
import { Plus, FileText, Brain, PenTool, Download } from 'lucide-react';

interface Project {
  id: string;
  name: string;
  template: string;
  description?: string;
  created_at: string;
}

function App() {
  const [projects, setProjects] = useState<Project[]>([]);
  const [showCreateForm, setShowCreateForm] = useState(false);
  const [newProject, setNewProject] = useState({
    name: '',
    template: 'screenplay',
    description: ''
  });

  useEffect(() => {
    fetchProjects();
  }, []);

  const fetchProjects = async () => {
    try {
      const response = await fetch('http://localhost:8000/api/projects');
      const data = await response.json();
      setProjects(data.projects || []);
    } catch (error) {
      console.error('Error fetching projects:', error);
    }
  };

  const createProject = async () => {
    try {
      const response = await fetch('http://localhost:8000/api/projects', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(newProject)
      });
      const data = await response.json();
      
      if (data.success) {
        setProjects([...projects, data.project]);
        setNewProject({ name: '', template: 'screenplay', description: '' });
        setShowCreateForm(false);
      }
    } catch (error) {
      console.error('Error creating project:', error);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-6">
            <div>
              <h1 className="text-3xl font-bold text-gray-900">Miranda</h1>
              <p className="text-gray-600">AI-Assisted Writing Platform</p>
            </div>
            <button
              onClick={() => setShowCreateForm(true)}
              className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 flex items-center gap-2"
            >
              <Plus size={20} />
              New Project
            </button>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Templates Overview */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <div className="bg-white p-6 rounded-lg shadow-sm border">
            <div className="text-2xl mb-2">🎬</div>
            <h3 className="font-semibold text-gray-900">Screenplay</h3>
            <p className="text-gray-600 text-sm">Character development, scene planning, dialogue generation</p>
          </div>
          <div className="bg-white p-6 rounded-lg shadow-sm border">
            <div className="text-2xl mb-2">📚</div>
            <h3 className="font-semibold text-gray-900">Academic</h3>
            <p className="text-gray-600 text-sm">Research integration, citation management, chapter organization</p>
          </div>
          <div className="bg-white p-6 rounded-lg shadow-sm border">
            <div className="text-2xl mb-2">💼</div>
            <h3 className="font-semibold text-gray-900">Business</h3>
            <p className="text-gray-600 text-sm">Market analysis, competitive research, strategic planning</p>
          </div>
        </div>

        {/* Projects */}
        <div className="bg-white rounded-lg shadow-sm border">
          <div className="px-6 py-4 border-b">
            <h2 className="text-xl font-semibold text-gray-900">Your Projects</h2>
          </div>
          <div className="p-6">
            {projects.length === 0 ? (
              <div className="text-center py-8">
                <FileText size={48} className="mx-auto text-gray-400 mb-4" />
                <p className="text-gray-600">No projects yet. Create your first project to get started!</p>
              </div>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                {projects.map((project) => (
                  <div key={project.id} className="border rounded-lg p-4 hover:shadow-md transition-shadow">
                    <div className="flex justify-between items-start mb-2">
                      <h3 className="font-semibold text-gray-900">{project.name}</h3>
                      <span className="text-xs bg-gray-100 px-2 py-1 rounded">{project.template}</span>
                    </div>
                    {project.description && (
                      <p className="text-gray-600 text-sm mb-3">{project.description}</p>
                    )}
                    <div className="flex justify-between items-center">
                      <div className="flex space-x-2">
                        <button className="p-1 text-gray-400 hover:text-blue-600">
                          <Brain size={16} />
                        </button>
                        <button className="p-1 text-gray-400 hover:text-green-600">
                          <PenTool size={16} />
                        </button>
                        <button className="p-1 text-gray-400 hover:text-purple-600">
                          <Download size={16} />
                        </button>
                      </div>
                      <span className="text-xs text-gray-400">
                        {new Date(project.created_at).toLocaleDateString()}
                      </span>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </main>

      {/* Create Project Modal */}
      {showCreateForm && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-lg p-6 w-full max-w-md">
            <h2 className="text-xl font-semibold mb-4">Create New Project</h2>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Project Name</label>
                <input
                  type="text"
                  value={newProject.name}
                  onChange={(e) => setNewProject({...newProject, name: e.target.value})}
                  className="w-full border rounded-lg px-3 py-2"
                  placeholder="My Screenplay"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Template</label>
                <select
                  value={newProject.template}
                  onChange={(e) => setNewProject({...newProject, template: e.target.value})}
                  className="w-full border rounded-lg px-3 py-2"
                >
                  <option value="screenplay">🎬 Screenplay</option>
                  <option value="academic">📚 Academic</option>
                  <option value="business">💼 Business</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
                <textarea
                  value={newProject.description}
                  onChange={(e) => setNewProject({...newProject, description: e.target.value})}
                  className="w-full border rounded-lg px-3 py-2"
                  rows={3}
                  placeholder="Brief description of your project..."
                />
              </div>
            </div>
            <div className="flex justify-end space-x-3 mt-6">
              <button
                onClick={() => setShowCreateForm(false)}
                className="px-4 py-2 text-gray-600 hover:text-gray-800"
              >
                Cancel
              </button>
              <button
                onClick={createProject}
                disabled={!newProject.name}
                className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 disabled:opacity-50"
              >
                Create Project
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default App;
