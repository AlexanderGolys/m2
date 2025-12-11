export type ThemeKey = 'theme-dark' | 'theme-slate' | 'theme-emerald' | 'theme-amber';

export function RightPanel(
  props: {
    theme?: ThemeKey;
    onChangeTheme?: (next: ThemeKey) => void;
  }
) {
  const { theme = 'theme-dark', onChangeTheme } = props;

  return (
    <div className="flex flex-col gap-3">
      <div className="text-sm font-semibold">Tools</div>
      <div className="text-sm opacity-70">
        This is a placeholder for tools, actions, and configuration. Plan space for run controls,
        session management, environment settings, and outputs.
      </div>
      {/* Theme switcher moved to right panel */}
      <div className="flex items-center gap-2">
        <label className="text-xs opacity-70" htmlFor="theme-select">Theme:</label>
        <select
          id="theme-select"
          className="px-2 py-1 text-sm rounded bg-background border"
          value={theme}
          onChange={(e) => onChangeTheme?.(e.target.value as ThemeKey)}
        >
          <option value="theme-dark">Dark</option>
          <option value="theme-slate">Slate</option>
          <option value="theme-emerald">Emerald</option>
          <option value="theme-amber">Amber</option>
        </select>
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
