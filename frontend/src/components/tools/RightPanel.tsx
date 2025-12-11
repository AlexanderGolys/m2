
// Right tools panel with placeholder actions and a theme switcher
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

      {/* Theme Switcher */}
      <div className="mt-4">
        <label htmlFor="theme-switcher" className="block text-xs opacity-70 mb-1">Theme</label>
        <select
          id="theme-switcher"
          className="w-full px-2 py-1 text-sm rounded bg-background border"
          defaultValue={document.documentElement.classList.contains('theme-blue')
            ? 'theme-blue'
            : document.documentElement.classList.contains('theme-light')
            ? 'theme-light'
            : 'theme-dark'}
          onChange={(e) => {
            const next = e.target.value as 'theme-dark' | 'theme-blue' | 'theme-light';
            const root = document.documentElement;
            root.classList.remove('theme-dark', 'theme-blue', 'theme-light');
            root.classList.add(next);
          }}
        >
          <option value="theme-dark">Dark (Default)</option>
          <option value="theme-blue">Blue (VS Code)</option>
          <option value="theme-light">Light</option>
        </select>
      </div>
    </div>
  );
}

