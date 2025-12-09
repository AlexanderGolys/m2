import { useEffect, useState } from 'react';
import './index.css';
import { CodeEditor } from './components/CodeEditor';
import { StatsDashboard } from './components/StatsDashboard';

function App() {
  const [path, setPath] = useState(window.location.pathname);

  useEffect(() => {
    const handlePopState = () => setPath(window.location.pathname);
    window.addEventListener('popstate', handlePopState);
    return () => window.removeEventListener('popstate', handlePopState);
  }, []);

  return (
    <div className="min-h-screen bg-background relative">
      {path === '/admin/stats' ? <StatsDashboard /> : <CodeEditor />}
    </div>
  );
}

export default App;
