import { useState, useRef, useEffect } from 'react';
import Editor from '@monaco-editor/react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { executeCode, ApiError } from '@/lib/api';
import { Play, Loader2, Terminal } from 'lucide-react';

export function CodeEditor() {
  const [code, setCode] = useState('-- Macaulay2 example\nR = QQ[x,y,z]\nI = ideal(x^2 + y^2, z^2)\nI');
  const [output, setOutput] = useState('');
  const [error, setError] = useState('');
  const [isExecuting, setIsExecuting] = useState(false);
  const outputRef = useRef<HTMLPreElement>(null);

  useEffect(() => {
    if (outputRef.current) {
      outputRef.current.scrollTop = outputRef.current.scrollHeight;
    }
  }, [output]);

  const handleExecute = async () => {
    if (!code.trim()) {
      setError('Please enter some code to execute');
      return;
    }

    setIsExecuting(true);
    setOutput('');
    setError('');

    try {
      const result = await executeCode(code);
      
      if (result.success) {
        setOutput(result.stdout || '(No output)');
        if (result.stderr) {
          setError(result.stderr);
        }
      } else {
        setError(result.error_message || result.stderr || 'Execution failed');
        setOutput(result.stdout || '');
      }
    } catch (err) {
      if (err instanceof ApiError) {
        setError(`Error ${err.status || ''}: ${err.message}`);
      } else {
        setError('Failed to connect to server. Make sure the backend is running.');
      }
    } finally {
      setIsExecuting(false);
    }
  };

  return (
    <div className="container mx-auto p-4 max-w-6xl">
      <div className="mb-6">
        <h1 className="text-4xl font-bold mb-2">Macaulay2 Web Interface</h1>
        <p className="text-muted-foreground">
          Execute Macaulay2 code in your browser with real-time results
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        {/* Code Input */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Terminal className="h-5 w-5" />
              Macaulay2 Code Editor
            </CardTitle>
            <CardDescription>
              Enter Macaulay2 code (Ctrl+Enter to execute)
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="border rounded-md overflow-hidden" style={{ height: '400px' }}>
              <Editor
                height="100%"
                defaultLanguage="macaulay2"
                value={code}
                onChange={(value: string | undefined) => setCode(value || '')}
                theme="vs-dark"
                options={{
                  minimap: { enabled: false },
                  fontSize: 16,
                  fontFamily: 'monospace',
                  wordWrap: 'on',
                  automaticLayout: true,
                  scrollBeyondLastLine: false,
                  scrollbar: {
                    vertical: 'auto',
                    horizontal: 'auto',
                  },
                  overviewRulerLanes: 0,
                  hideCursorInOverviewRuler: true,
                  renderLineHighlight: 'gutter',
                }}
                onMount={() => {
                  const monaco = (window as any).monaco;
                  if (monaco) {
                    monaco.editor.defineTheme('custom-dark', {
                      base: 'vs-dark',
                      inherit: true,
                      rules: [],
                      colors: {
                        'editor.background': '#0c1219',
                        'editor.foreground': '#e2e8f0',
                        'editor.lineNumbersColumn.background': '#111827',
                        'editorLineNumber.foreground': '#6b7280',
                        'editorLineNumber.activeForeground': '#d1d5db',
                        'editor.lineHighlightBackground': 'rgba(255, 255, 255, 0.05)',
                      },
                    });
                    monaco.editor.setTheme('custom-dark');
                  }
                }}
              />
            </div>
            <div className="mt-4">
              <Button 
                onClick={handleExecute} 
                disabled={isExecuting || !code.trim()}
                className="w-full"
              >
                {isExecuting ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                    Executing...
                  </>
                ) : (
                  <>
                    <Play className="mr-2 h-4 w-4" />
                    Execute Code
                  </>
                )}
              </Button>
            </div>
          </CardContent>
        </Card>

        {/* Output Display */}
        <Card>
          <CardHeader>
            <CardTitle>Output</CardTitle>
            <CardDescription>
              Execution results will appear here
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {/* Standard Output */}
              {output && (
                <pre ref={outputRef} className="overflow-auto max-h-[400px] text-sm font-mono whitespace-pre-wrap">
                  {output}
                </pre>
              )}

              {/* Error Output */}
              {error && (
                <div>
                  <h3 className="text-sm font-semibold mb-2 text-red-600 dark:text-red-400">
                    Error:
                  </h3>
                  <pre className="text-red-600 dark:text-red-400 overflow-auto max-h-[300px] text-sm font-mono whitespace-pre-wrap">
                    {error}
                  </pre>
                </div>
              )}

              {/* Empty state */}
              {!output && !error && !isExecuting && (
                <div className="text-center text-muted-foreground py-20">
                  <Terminal className="h-12 w-12 mx-auto mb-4 opacity-20" />
                  <p>Execute code to see output here</p>
                </div>
              )}

              {/* Loading state */}
              {isExecuting && (
                <div className="text-center text-muted-foreground py-20">
                  <Loader2 className="h-12 w-12 mx-auto mb-4 animate-spin" />
                  <p>Executing code...</p>
                </div>
              )}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
