import { useEffect, useState } from 'react';
import './index.css';
import { CodeEditor } from './components/CodeEditor';
import { StatsDashboard } from './components/StatsDashboard';
import { DocsLayout } from './components/layout/DocsLayout';
import { LeftPanel } from './components/docs/LeftPanel';
import { RightPanel, ThemeKey } from './components/tools/RightPanel';

function App() {
  const [path, setPath] = useState(window.location.pathname);

  useEffect(() => {
    const handlePopState = () => setPath(window.location.pathname);
    window.addEventListener('popstate', handlePopState);
    return () => window.removeEventListener('popstate', handlePopState);
  }, []);

  return (
    <DocsLayout
      left={<LeftPanel />}
      right={<RightPanel />}
    >
      <div className="min-h-screen bg-background relative">
        {path === '/admin/stats' ? <StatsDashboard /> : <CodeEditor />}
      </div>
    </DocsLayout>
  );
}

export default App;
