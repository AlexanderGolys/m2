# Frontend - Language CLI Interface

React + TypeScript + Vite frontend for the Language CLI web interface.

## Quick Start

```bash
npm install
npm run dev
```

Open `http://localhost:5173` in your browser.

## Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run lint` - Run ESLint

## Environment Variables

Create a `.env` file:

```
VITE_API_URL=http://localhost:8000
```

## Project Structure

```
src/
├── components/
│   ├── ui/              # shadcn/ui components
│   │   ├── button.tsx
│   │   ├── textarea.tsx
│   │   └── card.tsx
│   └── CodeEditor.tsx   # Main editor component
├── lib/
│   ├── api.ts          # API client
│   └── utils.ts        # Utility functions
├── App.tsx             # Root component
├── main.tsx            # Entry point
└── index.css           # Global styles
```

## Features

- Code editor with syntax highlighting
- Real-time execution results
- Error handling and display
- Keyboard shortcuts (Ctrl+Enter)
- Responsive design
- Dark mode support

## Customization

### Changing Theme

Edit `tailwind.config.js` to customize colors and theme.

### Adding Components

Add new shadcn/ui components:
```bash
npx shadcn-ui@latest add [component-name]
```

## Building for Production

```bash
npm run build
```

Output will be in the `dist/` directory. Deploy to any static hosting service.
