import React from 'react';

export function LeftPanel() {
  return (
    <div className="flex flex-col gap-3">
      <div className="text-sm font-semibold">Documentation</div>
      <div className="text-sm opacity-70">
        This is a placeholder for the docs navigation and content. Use this space to plan the
        structure: table of contents, search, and topic sections.
      </div>
      <ul className="text-sm list-disc pl-5 space-y-1">
        <li>Intro</li>
        <li>Getting Started</li>
        <li>API Reference</li>
        <li>Examples</li>
      </ul>
    </div>
  );
}
