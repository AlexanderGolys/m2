import React from 'react';

export function RightPanel() {
  return (
    <div className="flex flex-col gap-3">
      <div className="text-sm font-semibold">Tools</div>
      <div className="text-sm opacity-70">
        This is a placeholder for tools, actions, and configuration. Plan space for run controls,
        session management, environment settings, and outputs.
      </div>
      <div className="grid grid-cols-2 gap-2">
        <button className="px-3 py-2 text-sm border rounded hover:bg-muted">Run</button>
        <button className="px-3 py-2 text-sm border rounded hover:bg-muted">Interrupt</button>
        <button className="px-3 py-2 text-sm border rounded hover:bg-muted">New Session</button>
        <button className="px-3 py-2 text-sm border rounded hover:bg-muted">Save</button>
      </div>
    </div>
  );
}
