# Commands to Run on Your Server

## After Deploying the Changes

### 1. Deploy
```bash
cd /var/www/m2-interface
git pull
bash deploy/quick_deploy.sh
```

### 2. Test M2 Execution
```bash
cd /var/www/m2-interface/backend
python3 test_m2.py
```

### 3. Test Backend Endpoints
```bash
# Health check
curl http://localhost:8000/health | python3 -m json.tool

# Test different M2 methods
curl http://localhost:8000/test-m2 | python3 -m json.tool

# Test actual execution
curl -X POST http://localhost:8000/execute \
  -H "Content-Type: application/json" \
  -d '{"code": "2+2"}' | python3 -m json.tool
```

### 4. Watch Logs (Keep Running in Separate Terminal)
```bash
sudo journalctl -u m2-backend -f
```

### 5. Test Through Nginx (Public URL)
```bash
# Health check
curl https://macaulay2.fun/api/health | python3 -m json.tool

# Execute code
curl -X POST https://macaulay2.fun/api/execute \
  -H "Content-Type: application/json" \
  -d '{"code": "2+2"}' | python3 -m json.tool
```

### 6. If Output is Empty, Check Which Method Works

From the output of `test_m2.py`, identify which method produces output (stdin, script, or quiet_script).

Then edit `/var/www/m2-interface/backend/main.py`:

**For stdin method** (around line 100), replace:
```python
# Method 1: Try with --script
cmd = ['M2', '--script', str(code_file)]

logger.info(f"Executing Macaulay2 code ({len(request.code)} bytes)")
logger.info(f"Command: {' '.join(cmd)}")

result = subprocess.run(
    cmd,
    cwd=temp_dir,  # Run in isolated directory
    capture_output=True,
    text=True,
    timeout=35,  # Wall-clock timeout
    preexec_fn=set_resource_limits if os.name != 'nt' else None,  # Skip on Windows
)
```

With:
```python
# Use stdin method for better output capture
logger.info(f"Executing Macaulay2 code ({len(request.code)} bytes)")
logger.info(f"Command: M2 -q --stop (stdin)")

result = subprocess.run(
    ['M2', '-q', '--stop'],
    input=request.code + "\nexit\n",
    cwd=temp_dir,
    capture_output=True,
    text=True,
    timeout=35,
    preexec_fn=set_resource_limits if os.name != 'nt' else None,
)
```

Then restart:
```bash
sudo systemctl restart m2-backend
```

### 7. Make Scripts Executable (if needed)
```bash
cd /var/www/m2-interface
chmod +x deploy/*.sh
chmod +x backend/*.sh
chmod +x backend/*.py
```

## Troubleshooting Commands

```bash
# Check if M2 is installed
which M2
M2 --version

# Test M2 directly
echo "2+2" | M2 -q --stop

# Check backend service status
sudo systemctl status m2-backend

# View recent logs
sudo journalctl -u m2-backend -n 100 --no-pager

# Restart backend
sudo systemctl restart m2-backend

# Check nginx status
sudo systemctl status nginx
sudo nginx -t

# Check nginx config
cat /etc/nginx/sites-enabled/m2-interface
```
