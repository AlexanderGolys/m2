import { ReactNode, useState } from 'react';

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

      {/* Side panels overlay and main content */}
      <div className="flex-1 relative">
        {/* Left sliding docs panel */}
        <aside
          className={
            `fixed top-[var(--navbar-height,56px)] left-0 bottom-0 w-[40rem] max-w-[80vw] border-r bg-card text-card-foreground shadow-xl z-30 transition-transform duration-300 ease-out ` +
            (showLeft ? 'translate-x-0' : '-translate-x-full')
          }
        >
          <div className="h-full overflow-y-auto p-4">
            {left ?? <div className="text-sm opacity-70">Docs panel (empty)</div>}
          </div>
        </aside>

        {/* Right sliding tools panel */}
        <aside
          className={
            `fixed top-[var(--navbar-height,56px)] right-0 bottom-0 w-64 max-w-[70vw] border-l bg-card text-card-foreground shadow-xl z-30 transition-transform duration-300 ease-out ` +
            (showRight ? 'translate-x-0' : 'translate-x-full')
          }
        >
          <div className="h-full overflow-y-auto p-4">
            {right ?? <div className="text-sm opacity-70">Tools panel (empty)</div>}
          </div>
        </aside>

        {/* Main content occupies full width; add padding when panels visible on large screens */}
        <main
          className={
            `container mx-auto px-4 py-4 transition-[padding] duration-300 ease-out ` +
            (showLeft ? 'lg:pl-[40rem]' : '') + ' ' + (showRight ? 'lg:pr-64' : '')
          }
        >
          <div className="min-h-[calc(100vh-56px)] rounded-lg bg-card text-card-foreground border">
            {children}
          </div>
        </main>
      </div>

      {/* Footer */}
      <footer className="border-t bg-card text-card-foreground mt-auto">
        <div className="container mx-auto px-4 py-6 flex flex-col md:flex-row justify-between items-center gap-4 text-sm opacity-80">
          <div className="flex flex-col gap-1 text-center md:text-left">
            <span className="font-medium">&copy; {new Date().getFullYear()} M2 Interface. All rights reserved.</span>
            <span>
              Questions? Contact us at <a href="mailto:support@m2interface.com" className="hover:text-primary transition-colors">support@m2interface.com</a>
            </span>
          </div>
        </div>
      </footer>
    </div>
  );
}
