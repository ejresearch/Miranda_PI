import React, { useState, useEffect } from 'react'
import axios from 'axios'
import { FileText, Plus, Zap } from 'lucide-react'

interface Project {
  name: string
  template: string
}

function App() {
  const [projects, setProjects] = useState<Project[]>([])
  const [newProject, setNewProject] = useState({ name: '', template: 'screenplay' })

  useEffect(() => {
    fetchProjects()
  }, [])

  const fetchProjects = async () => {
    try {
      const response = await axios.get('/api/projects')
      setProjects(response.data.projects)
    } catch (error) {
      console.error('Error fetching projects:', error)
    }
  }

  const createProject = async () => {
    if (!newProject.name) return
    
    try {
      await axios.post('/api/projects', newProject)
      setNewProject({ name: '', template: 'screenplay' })
      fetchProjects()
    } catch (error) {
      console.error('Error creating project:', error)
    }
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 py-4">
          <div className="flex items-center gap-3">
            <Zap className="h-8 w-8 text-blue-600" />
            <h1 className="text-2xl font-bold text-gray-900">Miranda</h1>
            <span className="text-gray-500">AI-Assisted Writing Platform</span>
          </div>
        </div>
      </header>

      <div className="max-w-7xl mx-auto px-4 py-8">
        {/* Create Project */}
        <div className="bg-white rounded-lg shadow-sm border p-6 mb-8">
          <h2 className="text-xl font-semibold mb-4 flex items-center gap-2">
            <Plus className="h-5 w-5" />
            Create New Project
          </h2>
          
          <div className="flex gap-4 items-end">
            <div className="flex-1">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Project Name
              </label>
              <input
                type="text"
                value={newProject.name}
                onChange={(e) => setNewProject({...newProject, name: e.target.value})}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="My Screenplay Project"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Template
              </label>
              <select
                value={newProject.template}
                onChange={(e) => setNewProject({...newProject, template: e.target.value})}
                className="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="screenplay">🎬 Screenplay</option>
                <option value="academic">📚 Academic</option>
                <option value="business">💼 Business</option>
              </select>
            </div>
            
            <button
              onClick={createProject}
              className="px-6 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              Create
            </button>
          </div>
        </div>

        {/* Projects List */}
        <div className="bg-white rounded-lg shadow-sm border">
          <div className="p-6 border-b">
            <h2 className="text-xl font-semibold flex items-center gap-2">
              <FileText className="h-5 w-5" />
              Your Projects ({projects.length})
            </h2>
          </div>
          
          <div className="p-6">
            {projects.length === 0 ? (
              <div className="text-center py-8 text-gray-500">
                <FileText className="h-12 w-12 mx-auto mb-4 text-gray-300" />
                <p>No projects yet. Create your first project above!</p>
              </div>
            ) : (
              <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
                {projects.map((project, index) => (
                  <div key={index} className="p-4 border border-gray-200 rounded-lg hover:border-blue-300 transition-colors">
                    <div className="flex items-start justify-between mb-2">
                      <h3 className="font-medium text-gray-900">{project.name}</h3>
                      <span className="text-xs bg-gray-100 px-2 py-1 rounded">
                        {project.template}
                      </span>
                    </div>
                    <p className="text-sm text-gray-600 mb-3">
                      {project.template === 'screenplay' && '🎬 Screenplay writing workflow'}
                      {project.template === 'academic' && '📚 Academic writing workflow'}
                      {project.template === 'business' && '💼 Business document workflow'}
                    </p>
                    <button className="text-sm text-blue-600 hover:text-blue-700 font-medium">
                      Open Project →
                    </button>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}

export default App
