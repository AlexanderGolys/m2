# Debugging the "No Output" Issue - Quick Guide

## What We Fixed

1. **CORS Configuration**: Added `macaulay2.fun` domain to allowed origins in backend
2. **Enhanced Logging**: Backend now logs M2 command execution details
3. **Test Endpoint**: Added `/test-m2` to test different execution methods
4. **Debug Scripts**: Created scripts to test M2 directly on server

## Steps to Fix (On Your Server)

### 1. Commit and Push Changes

On your local machine (Windows):
```powershell
cd c:\Users\shitstem\Desktop\webProjects\m2
git add -A
git commit -m "Fix CORS, add debugging, enhance logging"
git push
```

### 2. Deploy to Server

SSH into your server, then:

```bash
# Quick deploy
cd /var/www/m2-interface
bash deploy/quick_deploy.sh
```

Or manually:
```bash
cd /var/www/m2-interface
git pull
cd backend
source venv/bin/activate
pip install -r requirements.txt
sudo systemctl restart m2-backend
```

### 3. Test M2 Execution

```bash
# Test M2 directly
cd /var/www/m2-interface/backend
python3 test_m2.py
```

This will show you which M2 invocation method produces output.

### 4. Test Backend API

```bash
# Test the new debug endpoint
curl http://localhost:8000/test-m2 | python3 -m json.tool

# Test actual execution
curl -X POST http://localhost:8000/execute \
  -H "Content-Type: application/json" \
  -d '{"code": "2+2"}' | python3 -m json.tool
```

### 5. Watch Logs While Testing

```bash
sudo journalctl -u m2-backend -f
```

Keep this running, then test from the website. You'll see:
- The command being executed
- Length of stdout/stderr
- Preview of the output

### 6. If Still No Output

Based on the `test_m2.py` results, you may need to change the execution method.

#### If stdin method works best:

Edit `/var/www/m2-interface/backend/main.py`, find this section (around line 100):

```python
# Method 1: Try with --script
cmd = ['M2', '--script', str(code_file)]
```

Replace the entire execution block with:

```python
# Use stdin method (better output capture)
result = subprocess.run(
    ['M2', '-q', '--stop'],
    input=request.code + "\nexit\n",
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

## Common Issues and Solutions

### Issue 1: CORS Error in Browser Console

**Symptom**: Browser console shows CORS error, request fails

**Solution**: Make sure you deployed the updated backend with CORS fix

**Verify**:
```bash
cd /var/www/m2-interface/backend
grep -A 5 "macaulay2.fun" main.py
```

Should show the domain in the allowed origins list.

### Issue 2: Backend Not Running

**Check**:
```bash
sudo systemctl status m2-backend
```

**Fix**:
```bash
sudo systemctl start m2-backend
sudo journalctl -u m2-backend -n 50
```

### Issue 3: M2 Not Installed

**Check**:
```bash
which M2
M2 --version
```

**Fix**:
```bash
sudo apt-get update
sudo apt-get install macaulay2
```

### Issue 4: Nginx Not Proxying

**Check nginx config**:
```bash
sudo nginx -t
cat /etc/nginx/sites-enabled/m2-interface
```

**Verify proxy is working**:
```bash
# Test backend directly
curl http://localhost:8000/health

# Test through nginx
curl https://macaulay2.fun/api/health
```

If nginx isn't proxying, check the `location /api/` block exists in nginx config.

## Browser Testing

1. Open https://macaulay2.fun
2. Open DevTools (F12) → Network tab
3. Enter code: `2+2`
4. Click Execute
5. Look at the `/api/execute` request:
   - **Status**: Should be 200
   - **Response**: Check the JSON, look at `stdout` and `stderr` fields

If `stdout` is empty in the browser but has content when testing with curl on the server, it's likely a CORS issue.

## Quick Test Commands

```bash
# On the server:

# 1. Check M2 works
echo "2+2" | M2 -q --stop

# 2. Check backend health
curl http://localhost:8000/health

# 3. Test M2 execution methods
curl http://localhost:8000/test-m2

# 4. Test actual execution
curl -X POST http://localhost:8000/execute \
  -H "Content-Type: application/json" \
  -d '{"code": "2+2"}'

# 5. Test through nginx
curl https://macaulay2.fun/api/health

# 6. Test full execution through nginx
curl -X POST https://macaulay2.fun/api/execute \
  -H "Content-Type: application/json" \
  -d '{"code": "2+2"}'
```

## Expected Output

When working correctly:

```json
{
  "stdout": "4",
  "stderr": "",
  "success": true,
  "error_message": null
}
```

## Files Changed

- `backend/main.py` - CORS fix, enhanced logging, test endpoint
- `backend/test_m2.py` - Test script for M2 execution
- `backend/test_server.sh` - Bash test script
- `backend/m2_execution_methods.py` - Alternative execution methods
- `deploy/quick_deploy.sh` - Quick deployment script
- `TROUBLESHOOTING.md` - Detailed troubleshooting guide
- `DEBUG_GUIDE.md` - This file

## Next Steps

1. Push changes to GitHub
2. Pull on server and deploy
3. Run `test_m2.py` to see which method works
4. Check logs while testing from browser
5. If needed, switch to better execution method
6. Report back with results!
