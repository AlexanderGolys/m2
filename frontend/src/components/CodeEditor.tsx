import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Textarea } from '@/components/ui/textarea';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { executeCode, ApiError } from '@/lib/api';
import { Play, Loader2, Terminal } from 'lucide-react';

export function CodeEditor() {
  const [code, setCode] = useState('-- Macaulay2 example\nR = QQ[x,y,z]\nI = ideal(x^2 + y^2, z^2)\nI');
  const [output, setOutput] = useState('');
  const [error, setError] = useState('');
  const [isExecuting, setIsExecuting] = useState(false);

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

  const handleKeyDown = (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
    // Ctrl+Enter or Cmd+Enter to execute
    if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') {
      e.preventDefault();
      handleExecute();
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
            <Textarea
              value={code}
              onChange={(e) => setCode(e.target.value)}
              onKeyDown={handleKeyDown}
              placeholder="-- Enter Macaulay2 code here...
-- Example:
R = QQ[x,y,z]
I = ideal(x^2 + y^2, z^2)
gens gb I"
              className="min-h-[400px] font-mono text-sm"
              disabled={isExecuting}
            />
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
                <div>
                  <h3 className="text-sm font-semibold mb-2 text-green-600 dark:text-green-400">
                    Standard Output:
                  </h3>
                  <pre className="bg-muted p-4 rounded-md overflow-auto max-h-[300px] text-sm font-mono whitespace-pre-wrap">
                    {output}
                  </pre>
                </div>
              )}

              {/* Error Output */}
              {error && (
                <div>
                  <h3 className="text-sm font-semibold mb-2 text-destructive">
                    Error:
                  </h3>
                  <pre className="bg-destructive/10 text-destructive p-4 rounded-md overflow-auto max-h-[300px] text-sm font-mono whitespace-pre-wrap border border-destructive/20">
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

      {/* Tips */}
      <Card className="mt-4">
        <CardHeader>
          <CardTitle className="text-lg">Tips</CardTitle>
        </CardHeader>
        <CardContent className="text-sm text-muted-foreground space-y-1">
          <p>• Press <kbd className="px-2 py-1 bg-muted rounded">Ctrl+Enter</kbd> to execute code quickly</p>
          <p>• Code execution is limited to 35 seconds with 512MB memory</p>
          <p>• The backend must be running on <code className="px-1 bg-muted rounded">http://localhost:8000</code></p>
        </CardContent>
      </Card>
    </div>
  );
}
