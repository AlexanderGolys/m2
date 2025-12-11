import React, { ReactNode, useState } from 'react';

// High-level layout with a navbar, left docs panel (~1/3), main content, right tools panel,
// and a footer. Panels are currently empty placeholders to plan visual space.
// Supports a navbar toggle to collapse/expand panels when needed.

interface DocsLayoutProps {
  left?: ReactNode;
  right?: ReactNode;
  children: ReactNode;
}

export function DocsLayout({ left, right, children }: DocsLayoutProps) {
  const [showLeft, setShowLeft] = useState(true);
  const [showRight, setShowRight] = useState(true);

  return (
    <div className="min-h-screen bg-background text-foreground flex flex-col">
      {/* Navbar */}
      <header className="border-b bg-card text-card-foreground">
        <div className="container mx-auto px-4 py-2 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <span className="font-semibold">M2 Interface</span>
            <span className="text-xs opacity-70">Notebook & Docs</span>
          </div>
          <div className="flex items-center gap-2">
            <button
              className="px-2 py-1 text-sm rounded hover:bg-muted"
              onClick={() => setShowLeft((v) => !v)}
              aria-label="Toggle left panel"
            >
              {showLeft ? 'Hide Docs' : 'Show Docs'}
            </button>
            <button
              className="px-2 py-1 text-sm rounded hover:bg-muted"
              onClick={() => setShowRight((v) => !v)}
              aria-label="Toggle right panel"
            >
              {showRight ? 'Hide Tools' : 'Show Tools'}
            </button>
          </div>
        </div>
      </header>

      {/* Main content area */}
      <div className="flex-1 container mx-auto px-4 py-4 grid grid-cols-12 gap-4">
        {/* Left docs panel (~1/3 width on desktop) */}
        {showLeft && (
          <aside className="col-span-12 md:col-span-4 lg:col-span-3">
            <div className="h-full border rounded-lg bg-card text-card-foreground p-3">
              {left ?? <div className="text-sm opacity-70">Docs panel (empty)</div>}
            </div>
          </aside>
        )}

        {/* Center content */}
        <main
          className={
            showLeft && showRight
              ? 'col-span-12 md:col-span-4 lg:col-span-6'
              : showLeft || showRight
              ? 'col-span-12 md:col-span-8 lg:col-span-9'
              : 'col-span-12'
          }
        >
          <div className="h-full border rounded-lg bg-card text-card-foreground">
            {children}
          </div>
        </main>

        {/* Right tools panel (~1/3 width on desktop) */}
        {showRight && (
          <aside className="col-span-12 md:col-span-4 lg:col-span-3">
            <div className="h-full border rounded-lg bg-card text-card-foreground p-3">
              {right ?? <div className="text-sm opacity-70">Tools panel (empty)</div>}
            </div>
          </aside>
        )}
      </div>

      {/* Footer */}
      <footer className="border-t bg-card text-card-foreground">
        <div className="container mx-auto px-4 py-3 text-sm opacity-70">
          © {new Date().getFullYear()} M2 Interface — Space planning preview
        </div>
      </footer>
    </div>
  );
}
