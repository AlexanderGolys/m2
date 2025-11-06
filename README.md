# Macaulay2 Web Interface

A modern web application that provides an interactive interface to execute Macaulay2 code in your browser. Features a React + TypeScript frontend with shadcn/ui components and a FastAPI backend with resource-limited execution.

## 🎯 Overview

This project allows users to write and execute Macaulay2 code through a web interface, with real-time results displayed in an intuitive UI. The backend runs Macaulay2 on a Linux server with strict resource limits to ensure safe execution.

## ✨ Features

- 🎨 Modern React UI with shadcn/ui components and TailwindCSS
- ⚡ Real-time Macaulay2 code execution
- 🔒 Resource-limited execution (CPU, memory, time limits)
- 📝 Syntax-highlighted output display
- ⌨️ Keyboard shortcuts (Ctrl+Enter to execute)
- 🌙 Dark mode support
- 🚀 Fast development with Vite
- 🛡️ Secure execution in isolated environment
- ⏱️ 35-second timeout protection
- 💾 512MB memory limit per execution

## 📋 Project Structure

```
m2/
├── frontend/              # React + TypeScript + Vite frontend
│   ├── src/
│   │   ├── components/
│   │   │   ├── ui/        # shadcn/ui components
│   │   │   └── CodeEditor.tsx
│   │   ├── lib/
│   │   │   ├── api.ts     # API client
│   │   │   └── utils.ts   # Utilities
│   │   ├── App.tsx
│   │   ├── main.tsx
│   │   └── index.css
│   ├── .env.development
│   ├── .env.production
│   ├── package.json
│   ├── vite.config.ts
│   └── tailwind.config.js
│
├── backend/               # FastAPI backend
│   ├── main.py           # API server with M2 execution
│   └── requirements.txt
│
├── deploy/               # Deployment scripts
│   ├── setup_server.sh   # Initial server setup
│   ├── deploy_backend.sh # Deploy backend
│   ├── deploy_frontend.sh # Deploy frontend
│   ├── setup_nginx.sh    # Configure Nginx
│   └── setup_ssl.sh      # Setup SSL/HTTPS
│
├── DEPLOYMENT.md         # Detailed deployment guide
└── README.md            # This file
```

## � Quick Start

### Prerequisites

**For Local Development (Windows):**
- Node.js 18+ and npm
- (Optional) WSL2 for testing backend locally

**For Production Deployment:**
- Ubuntu 20.04+ server
- Domain name
- SSH access to server

### Local Development on Windows

⚠️ **IMPORTANT**: Macaulay2 only runs on Linux, so you **cannot run the full application locally on Windows**.

You have two development approaches:

#### Approach 1: Frontend Development Only (Recommended)

Develop the frontend UI on Windows and connect to your deployed backend server:

```powershell
cd frontend
npm install

# Edit .env.development to point to your server
# VITE_API_URL=https://your-domain.com/api

npm run dev
```

Frontend runs on http://localhost:5173, but connects to your Linux server's backend.

**Pros:**
- ✅ Fast UI development on Windows
- ✅ Test against real Macaulay2 environment
- ✅ No need for WSL2

**Cons:**
- ❌ Requires deployed backend on server
- ❌ Need internet connection

#### Approach 2: Full Local Development with WSL2

If you want to test everything locally:

```powershell
# 1. Install WSL2 (one-time setup)
wsl --install

# 2. Restart your computer

# 3. Open WSL2
wsl

# Inside WSL2:
cd /mnt/c/Users/shitstem/Desktop/webProjects/m2/backend

# Install Macaulay2
sudo apt update
sudo apt install macaulay2

# Setup Python backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Run backend
python main.py
```

Backend runs on http://localhost:8000

Then in a new PowerShell window:
```powershell
cd frontend
npm run dev
```

**Pros:**
- ✅ Full offline development
- ✅ Test everything locally

**Cons:**
- ❌ Requires WSL2 setup
- ❌ More complex environment

### Testing the Application

#### Option 1: Frontend on Windows → Backend on Server

1. **Deploy backend to your server first** (see [DEPLOYMENT.md](DEPLOYMENT.md))

2. **Update frontend config** to point to your server:

   Create/edit `frontend/.env.development`:
   ```env
   VITE_API_URL=https://your-domain.com/api
   ```

3. **Run frontend on Windows**:
   ```powershell
   cd frontend
   npm run dev
   ```

4. **Open browser** to http://localhost:5173

Now your local frontend will send code execution requests to your Linux server!

#### Option 2: Full Local Testing (WSL2)

If you set up WSL2 with Macaulay2:

1. **Start backend in WSL2**:
   ```bash
   cd /mnt/c/Users/shitstem/Desktop/webProjects/m2/backend
   source venv/bin/activate
   python main.py
   ```

2. **Start frontend in PowerShell**:
   ```powershell
   cd frontend
   npm run dev
   ```

3. **Open browser** to http://localhost:5173

#### Try Example Code

Once connected, try this Macaulay2 code:
```macaulay2
-- Define a polynomial ring
R = QQ[x,y,z]

-- Create an ideal
I = ideal(x^2 + y^2, z^2)

-- Compute Groebner basis
gens gb I
```

## 🌐 Production Deployment

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed deployment instructions.

**Quick deployment:**

```bash
# 1. SSH into your server
ssh user@your-server

# 2. Clone the repository
git clone <your-repo> /var/www/m2-interface
cd /var/www/m2-interface/deploy

# 3. Make scripts executable
chmod +x *.sh

# 4. Run setup scripts in order
./setup_server.sh      # Install dependencies
./deploy_backend.sh    # Deploy backend
./deploy_frontend.sh   # Build and deploy frontend
./setup_nginx.sh       # Configure web server
./setup_ssl.sh         # Enable HTTPS (optional but recommended)
```

## 🏗️ Architecture

```
User Browser
    ↓
React Frontend (Vite)
    ↓ HTTP POST /api/execute
FastAPI Backend
    ↓ subprocess with limits
Macaulay2 CLI
    ↓ output
Backend captures & returns
    ↓ JSON response
Frontend displays results
```

### Resource Limits

- **Execution Timeout**: 35 seconds wall-clock time
- **CPU Time**: 30 seconds max
- **Memory**: 512MB per execution
- **Max Processes**: 10
- **File Size**: 10MB output limit
- **Code Size**: 100KB input limit

## 🔧 API Reference

### POST /execute

Execute Macaulay2 code.

**Request:**
```json
{
  "code": "R = QQ[x,y,z]\nI = ideal(x^2, y^2)\nI"
}
```

**Response (Success):**
```json
{
  "stdout": "ideal (x^2, y^2)",
  "stderr": "",
  "success": true,
  "error_message": null
}
```

**Response (Error):**
```json
{
  "stdout": "",
  "stderr": "error message...",
  "success": false,
  "error_message": "Process exited with code 1"
}
```

### GET /health

Health check endpoint.

**Response:**
```json
{
  "status": "healthy",
  "macaulay2_available": true,
  "macaulay2_version": "Macaulay2, version 1.21",
  "resource_limits": {
    "timeout_seconds": 35,
    "memory_limit_mb": 512,
    "cpu_time_limit_seconds": 30
  }
}
```

## 🛠️ Development

### Frontend Commands (Windows PowerShell)

```powershell
# Install dependencies
.\install-frontend.ps1

# Start development server
cd frontend
npm run dev

# Build for production
.\build-frontend.ps1

# Lint code
cd frontend
npm run lint

# Preview production build
npm run preview
```

### Backend Commands (Linux/WSL or Server)

```bash
# Activate virtual environment
cd backend
source venv/bin/activate

# Run development server
python main.py

# Run with auto-reload
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### Deploying to Your Server from Windows

You can deploy using SCP or SFTP clients:

**Using SCP (in PowerShell with OpenSSH):**
```powershell
# Build frontend first
.\build-frontend.ps1

# Upload to server
scp -r frontend\dist\* user@your-server:/var/www/m2-interface/frontend/dist/
scp -r backend\* user@your-server:/var/www/m2-interface/backend/
```

**Using WinSCP or FileZilla:**
1. Install [WinSCP](https://winscp.net/) or [FileZilla](https://filezilla-project.org/)
2. Connect to your server via SFTP
3. Upload project files to `/var/www/m2-interface`
4. SSH into server and run deployment scripts

### Adding shadcn/ui Components

```bash
cd frontend
npx shadcn@latest add <component-name>
```

## 🔒 Security Considerations

### Current Protections

✅ Execution timeouts  
✅ Memory limits  
✅ CPU time limits  
✅ Process isolation  
✅ Isolated temporary directories  
✅ File size limits  

### Recommended Additional Security

For production use, consider:

1. **Rate Limiting**: Limit requests per IP
2. **Authentication**: Add user accounts
3. **Input Sanitization**: Additional code validation
4. **Logging**: Monitor for abuse
5. **Firewall Rules**: Restrict access to backend
6. **HTTPS Only**: Enforce SSL/TLS

See DEPLOYMENT.md for implementation details.

## 📝 Example Macaulay2 Code

```macaulay2
-- Polynomial rings
R = QQ[x,y,z]

-- Ideals
I = ideal(x^2 - y*z, x*y - z^2)

-- Groebner bases
gens gb I

-- Homology calculations
S = QQ[a,b,c,d]
M = coker matrix {{a,b},{c,d}}
HH_0(M)

-- Resolutions
resolution I
```

## 🐛 Troubleshooting

### Backend Issues

**Macaulay2 not found:**
```bash
# Install on Ubuntu/Debian
sudo apt install macaulay2

# Verify installation
M2 --version
```

**Port 8000 already in use:**
```bash
# Find process
lsof -i :8000

# Kill process or change port in main.py
```

### Frontend Issues

**Build fails:**
```bash
rm -rf node_modules package-lock.json
npm install
npm run build
```

**API connection errors:**
Check `.env.development` has correct backend URL:
```
VITE_API_URL=http://localhost:8000
```

## 📚 Tech Stack

### Frontend
- **React 18** - UI framework
- **TypeScript** - Type safety
- **Vite** - Build tool
- **TailwindCSS** - Styling
- **shadcn/ui** - UI components
- **Lucide React** - Icons

### Backend
- **FastAPI** - Web framework
- **Pydantic** - Data validation
- **Uvicorn** - ASGI server
- **Macaulay2** - Computer algebra system

### Infrastructure
- **Nginx** - Web server & reverse proxy
- **Let's Encrypt** - SSL certificates
- **systemd** - Service management
- **UFW** - Firewall

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- [Macaulay2](http://www2.macaulay2.com/) - Computer algebra system
- [shadcn/ui](https://ui.shadcn.com/) - UI components
- [FastAPI](https://fastapi.tiangolo.com/) - Backend framework

## 📞 Support

For issues and questions:
- Check [DEPLOYMENT.md](DEPLOYMENT.md) for deployment help
- Review logs: `sudo journalctl -u m2-backend -f`
- Test API: `curl http://localhost:8000/health`

---

Built with ❤️ for the Macaulay2 community
   npm run dev
   ```

4. **Open browser:**
   Navigate to `http://localhost:5173`

### Backend Setup (Linux only - required for execution)

The backend uses Linux-specific resource limiting and must run on a Linux server.

1. **Navigate to backend directory:**
   ```bash
   cd backend
   ```

2. **Create virtual environment:**
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Configure your language CLI:**
   Edit `backend/main.py` and replace the placeholder command:
   ```python
   # Line ~60: Replace this with your actual CLI command
   cmd = ['your-language-cli']  # e.g., ['my-lang', '--interactive']
   ```

5. **Run the server:**
   ```bash
   python main.py
   ```
   Or with uvicorn:
   ```bash
   uvicorn main:app --reload --host 0.0.0.0 --port 8000
   ```

## Configuration

### Frontend Environment Variables

Create `.env` file in `frontend/` directory:
```bash
VITE_API_URL=http://localhost:8000
```

### Backend Configuration

The backend has resource limits configured in `main.py`:
- **Execution timeout**: 35 seconds (wall-clock time)
- **CPU time limit**: 30 seconds
- **Memory limit**: 512 MB
- **Process limit**: 10 processes

Adjust these in the `set_resource_limits()` function as needed.

## Development

### Frontend Development
```bash
cd frontend
npm run dev          # Start dev server
npm run build        # Build for production
npm run preview      # Preview production build
npm run lint         # Run ESLint
```

### Backend Development (Linux)
```bash
cd backend
# Activate virtual environment first
python main.py                                    # Run server
uvicorn main:app --reload                        # Run with auto-reload
```

## Deployment

### Frontend Deployment
Build the frontend and deploy to any static hosting:
```bash
cd frontend
npm run build
# Deploy the 'dist' folder to Netlify, Vercel, etc.
```

### Backend Deployment (Linux Server)
Deploy to a Linux cloud server (AWS EC2, DigitalOcean, etc.):

1. **Install Python and dependencies**
2. **Configure firewall to allow port 8000**
3. **Use a process manager** (systemd, supervisor, or PM2)
4. **Consider using nginx as reverse proxy**
5. **Enable HTTPS** with Let's Encrypt

Example systemd service (`/etc/systemd/system/lane-api.service`):
```ini
[Unit]
Description=Lane API Service
After=network.target

[Service]
User=www-data
WorkingDirectory=/path/to/lane/backend
Environment="PATH=/path/to/lane/backend/venv/bin"
ExecStart=/path/to/lane/backend/venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000

[Install]
WantedBy=multi-user.target
```

## Security Considerations

- ⚠️ **User code execution is inherently risky** - only deploy in controlled environments
- 🔒 Resource limits are enforced but can be bypassed in some scenarios
- 🐳 **Recommended**: Run backend in Docker containers for better isolation
- 🔐 Add authentication and rate limiting for production use
- 🌐 Configure CORS appropriately for your domain

## Tech Stack

**Frontend:**
- React 18
- TypeScript
- Vite
- TailwindCSS
- shadcn/ui
- Lucide React (icons)

**Backend:**
- FastAPI
- Uvicorn
- Python 3.8+
- Resource limits (Linux `resource` module)

## License

MIT

## Contributing

Pull requests are welcome! Please ensure your code follows the existing style.
