# Backend - Language CLI API

FastAPI backend for executing code with resource limits.

## ⚠️ Linux Only

This backend uses Linux-specific resource limiting (`resource` module) and must run on Linux.

## Quick Start

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run server
python main.py
```

## Configuration

### Set Your Language CLI

Edit `main.py` line ~60:

```python
# Replace with your actual CLI command
cmd = ['your-language-cli']
```

Examples:
- `['python3', '-c']` - Python
- `['node', '-e']` - Node.js
- `['ruby', '-e']` - Ruby
- `['your-custom-lang']` - Your language

### Resource Limits

Configured in `set_resource_limits()` function:

```python
# Memory: 512MB
resource.setrlimit(resource.RLIMIT_AS, (512_000_000, 512_000_000))

# CPU Time: 30 seconds
resource.setrlimit(resource.RLIMIT_CPU, (30, 30))

# Process count: 10
resource.setrlimit(resource.RLIMIT_NPROC, (10, 10))
```

Adjust as needed for your use case.

## API Endpoints

### POST /execute
Execute code with resource limits.

**Request:**
```json
{
  "code": "print('Hello World')"
}
```

**Response:**
```json
{
  "stdout": "Hello World\n",
  "stderr": "",
  "success": true,
  "error_message": null
}
```

### GET /health
Health check endpoint.

**Response:**
```json
{
  "status": "healthy"
}
```

## Deployment

### Development
```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### Production

Use a process manager like systemd or supervisor:

```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4
```

### Docker (Recommended)

For better isolation:

```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## Security Notes

- Resource limits only work on Linux
- Use Docker for better isolation
- Add authentication for production
- Implement rate limiting
- Monitor for abuse
- Keep the system updated

## Testing

Test the API:

```bash
# Health check
curl http://localhost:8000/health

# Execute code
curl -X POST http://localhost:8000/execute \
  -H "Content-Type: application/json" \
  -d '{"code": "print(2 + 2)"}'
```
