# Troubleshooting: "No Output" Issue

## Problem
The website displays "(No output)" for all Macaulay2 code executions.

## Possible Causes and Solutions

### 1. CORS Issues (FIXED)
**Problem**: Backend doesn't allow requests from macaulay2.fun domain.

**Solution**: Updated `backend/main.py` to include production domain in CORS origins:
```python
allow_origins=[
    "http://localhost:5173",
    "http://localhost:3000",
    "https://macaulay2.fun",
    "http://macaulay2.fun",
    "https://www.macaulay2.fun",
    "http://www.macaulay2.fun",
]
```

**Action Required**: Deploy updated backend to server.

### 2. Macaulay2 Output Behavior
**Problem**: M2 might not produce stdout output with `--script` flag, or output goes to stderr.

**Current Code**: Uses `M2 --script input.m2`

**Debugging Steps**:

1. **SSH into your server** and run the test script:
   ```bash
   cd /var/www/m2-interface/backend
   python3 test_m2.py
   ```

2. **Or use the bash test script**:
   ```bash
   cd /var/www/m2-interface/backend
   bash test_server.sh
   ```

3. **Check the backend logs**:
   ```bash
   sudo journalctl -u m2-backend -f
   ```
   
   Then try submitting code through the website and watch the logs.

### 3. Potential M2 Invocation Issues

The `--script` flag might not be the right approach. Here are alternatives:

#### Option A: Use `-q --stop` with stdin
```python
result = subprocess.run(
    ['M2', '-q', '--stop'],
    input=request.code + "\nexit\n",
    capture_output=True,
    text=True,
    timeout=35,
    cwd=temp_dir,
    preexec_fn=set_resource_limits if os.name != 'nt' else None,
)
```

#### Option B: Wrap code with print
Modify the code before execution to ensure output:
```python
wrapped_code = f"print({request.code})"
```

#### Option C: Use `-e` flag for evaluation
```python
cmd = ['M2', '-q', '-e', request.code]
```

### 4. API Environment Variable
**Problem**: Frontend might be calling wrong API URL.

**Check**:
1. Verify `.env.production` has `VITE_API_URL=/api`
2. Verify nginx is proxying `/api/` to `http://localhost:8000/`
3. Check browser DevTools Network tab:
   - Is the request going to `https://macaulay2.fun/api/execute`?
   - What's the response status code?
   - What's the response body?

### 5. Backend Service Issues
**Problem**: Backend service might not be running or might be crashing.

**Check**:
```bash
# Check if service is running
sudo systemctl status m2-backend

# View logs
sudo journalctl -u m2-backend -n 50

# Restart service
sudo systemctl restart m2-backend
```

## Step-by-Step Debugging Process

### On the Server:

1. **Check M2 is installed**:
   ```bash
   M2 --version
   ```

2. **Test M2 directly**:
   ```bash
   echo "2+2" | M2 -q --stop
   ```

3. **Run the test script**:
   ```bash
   cd /var/www/m2-interface/backend
   python3 test_m2.py
   ```

4. **Check backend service**:
   ```bash
   sudo systemctl status m2-backend
   curl http://localhost:8000/health
   ```

5. **Test backend API directly**:
   ```bash
   curl -X POST http://localhost:8000/execute \
     -H "Content-Type: application/json" \
     -d '{"code": "2+2"}'
   ```

6. **Check nginx configuration**:
   ```bash
   sudo nginx -t
   sudo systemctl status nginx
   ```

7. **Test through nginx**:
   ```bash
   curl -X POST https://macaulay2.fun/api/execute \
     -H "Content-Type: application/json" \
     -d '{"code": "2+2"}'
   ```

### In the Browser:

1. Open DevTools (F12)
2. Go to Network tab
3. Submit code
4. Look at the `/api/execute` request:
   - Request payload
   - Response status
   - Response body
5. Check Console tab for errors

## Quick Fixes to Try

### Fix 1: Deploy Updated Backend (CORS Fix)
```bash
cd /var/www/m2-interface
git pull
cd backend
source venv/bin/activate
pip install -r requirements.txt
sudo systemctl restart m2-backend
```

### Fix 2: Check Backend Logs for Actual M2 Output
The updated backend now logs:
- Command being run
- Output lengths
- Preview of stdout/stderr

```bash
sudo journalctl -u m2-backend -f
```

Then try executing code and see what the logs show.

### Fix 3: Alternative M2 Invocation
If logs show empty stdout, try modifying the backend to use stdin method instead:

In `backend/main.py`, replace the execution code with:
```python
result = subprocess.run(
    ['M2', '-q', '--stop'],
    input=request.code + "\nexit\n",
    capture_output=True,
    text=True,
    timeout=35,
    cwd=temp_dir,
    preexec_fn=set_resource_limits if os.name != 'nt' else None,
)
```

## Expected Behavior

When working correctly:
- User submits code
- Frontend sends POST to `/api/execute`
- Backend runs M2 with the code
- M2 produces output to stdout
- Backend returns JSON: `{"stdout": "...", "stderr": "...", "success": true}`
- Frontend displays stdout

## Files Modified

1. `backend/main.py` - Added CORS origins, enhanced logging
2. `backend/test_m2.py` - New test script
3. `backend/test_server.sh` - New bash test script

## Next Steps

1. Deploy the updated backend with CORS fix
2. Run test scripts to understand M2 behavior
3. Check logs while testing from browser
4. If stdout is still empty, try alternative M2 invocation methods
