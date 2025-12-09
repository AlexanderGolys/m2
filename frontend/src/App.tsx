import { useState } from 'react';
import './index.css';
import { CodeEditor } from './components/CodeEditor';
import { StatsDashboard } from './components/StatsDashboard';
import { Button } from './components/ui/button';

function App() {
  const [showStats, setShowStats] = useState(false);

  return (
    <div className="min-h-screen bg-background relative">
      <div className="absolute top-4 right-4 z-10">
        <Button 
          variant="outline" 
          size="sm" 
          onClick={() => setShowStats(!showStats)}
          className="bg-slate-800 text-white border-slate-700 hover:bg-slate-700"
        >
          {showStats ? 'Back to Editor' : 'Admin Stats'}
        </Button>
      </div>
      
      {showStats ? <StatsDashboard /> : <CodeEditor />}
    </div>
  );
}

export default App;
