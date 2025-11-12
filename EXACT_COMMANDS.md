# EXACT COMMANDS TO RUN

## On Windows (Your Machine)

```powershell
cd c:\Users\shitstem\Desktop\webProjects\m2
git add -A
git commit -m "Fix: Use M2 stdin method for output"
git push
```

## On Server (via SSH)

### Option 1: Use the deploy script
```bash
cd /var/www/m2-interface
bash deploy/deploy_fix.sh
```

### Option 2: Manual commands
```bash
cd /var/www/m2-interface
git pull
sudo systemctl restart m2-backend
```

### Test it works:
```bash
curl -X POST http://localhost:8000/execute \
  -H "Content-Type: application/json" \
  -d '{"code": "2+2"}' | python3 -m json.tool
```

Expected output:
```json
{
  "stdout": "\ni1 : 2+2\n\no1 = 4\n\ni2 : exit\n\n",
  "stderr": "",
  "success": true,
  "error_message": null
}
```

## Test in Browser

1. Open: https://macaulay2.fun
2. Enter: `2+2`
3. Click: Execute
4. See: Output with "o1 = 4" ✅

Done! 🎉
