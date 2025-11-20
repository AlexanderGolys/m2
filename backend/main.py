# Statistics endpoint
from fastapi.responses import JSONResponse

@app.get("/admin/stats")
async def get_stats():
    with stats_lock:
        # Convert sets to list for JSON serialization
        stats_copy = {
            'requests_per_day': dict(stats['requests_per_day']),
            'unique_users_per_day': {k: list(v) for k, v in stats['unique_users_per_day'].items()}
        }
    return JSONResponse(content=stats_copy)
from fastapi import Request
# Middleware to track statistics
@app.middleware("http")
async def stats_middleware(request: Request, call_next):
    date_str = datetime.utcnow().strftime('%Y-%m-%d')
    ip = request.client.host if request.client else 'unknown'
    with stats_lock:
        # Increment requests per day
        stats['requests_per_day'].setdefault(date_str, 0)
        stats['requests_per_day'][date_str] += 1
        # Track unique users per day
        stats['unique_users_per_day'].setdefault(date_str, set())
        stats['unique_users_per_day'][date_str].add(ip)
    response = await call_next(request)
    return response
import resource
import subprocess
import tempfile
import os
from pathlib import Path
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

import threading
from datetime import datetime
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


# In-memory statistics (thread-safe)
stats_lock = threading.Lock()
stats = {
    'requests_per_day': {},  # {date_str: int}
    'unique_users_per_day': {},  # {date_str: set(ip)}
}

app = FastAPI(
    title="Macaulay2 Web Interface API",
    description="Execute Macaulay2 code with resource limits",
    version="1.0.0"
)

# CORS configuration - adjust origins for production
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",  # Vite dev server
        "http://localhost:3000",  # Alternative dev port
        "https://macaulay2.fun",  # Production domain
        "http://macaulay2.fun",   # Production domain (HTTP)
        "https://www.macaulay2.fun",  # Production domain with www
        "http://www.macaulay2.fun",   # Production domain with www (HTTP)
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class CodeRequest(BaseModel):
    code: str


class CodeResponse(BaseModel):
    stdout: str
    stderr: str
    success: bool
    error_message: str | None = None


def set_resource_limits():
    """Set resource limits for child process (Linux/Unix only)"""
    try:
        # 512MB memory limit (soft and hard)
        re
        source.setrlimit(resource.RLIMIT_AS, (512_000_000, 512_000_000))
        # 30 second CPU time limit
        resource.setrlimit(resource.RLIMIT_CPU, (30, 30))
        # Limit number of processes
        resource.setrlimit(resource.RLIMIT_NPROC, (10, 10))
        # Limit file size to 10MB
        resource.setrlimit(resource.RLIMIT_FSIZE, (10_000_000, 10_000_000))
    except (ValueError, OSError, AttributeError) as e:
        # On Windows or if limits can't be set, just log warning
        logger.warning(f"Could not set resource limits (this is normal on Windows): {e}")


@app.post("/execute", response_model=CodeResponse)
async def execute_code(request: CodeRequest):
    """
    Execute Macaulay2 code with resource limits and security measures.
    
    Resource limits:
    - 30 seconds CPU time
    - 512MB memory
    - 35 seconds wall-clock timeout
    - Isolated temporary directory
    """
    if not request.code.strip():
        raise HTTPException(status_code=400, detail="Code cannot be empty")
    
    # Basic input validation
    if len(request.code) > 100000:  # 100KB limit
        raise HTTPException(status_code=400, detail="Code too long (max 100KB)")
    
    # Create isolated temporary directory for execution
    with tempfile.TemporaryDirectory() as temp_dir:
        try:
            # Macaulay2 command using stdin method
            # This is the only method that produces output reliably
            # --stop: non-interactive mode, exit after processing
            # We send code via stdin and add "exit" to ensure clean termination
            
            logger.info(f"Executing Macaulay2 code ({len(request.code)} bytes)")
            logger.info(f"Command: M2 --stop (via stdin)")
            
            result = subprocess.run(
                ['M2', '--stop'],
                input=request.code + "\nexit\n",
                cwd=temp_dir,  # Run in isolated directory
                capture_output=True,
                text=True,
                timeout=35,  # Wall-clock timeout
                preexec_fn=set_resource_limits if os.name != 'nt' else None,  # Skip on Windows
            )
            
            logger.info(f"Execution completed with return code {result.returncode}")
            logger.info(f"STDOUT length: {len(result.stdout)}, STDERR length: {len(result.stderr)}")
            
            # Log first 500 chars of output for debugging
            if result.stdout:
                logger.info(f"STDOUT preview: {result.stdout[:500]}")
            if result.stderr:
                logger.info(f"STDERR preview: {result.stderr[:500]}")
            
            # M2 --stop outputs banner to stderr, which is not an error
            # Only keep stderr if there's an actual error (non-zero return code)
            stderr_output = result.stderr if result.returncode != 0 else ""
            
            return CodeResponse(
                stdout=result.stdout,
                stderr=stderr_output,
                success=result.returncode == 0,
                error_message=None if result.returncode == 0 else f"Process exited with code {result.returncode}"
            )
        
        except subprocess.TimeoutExpired:
            logger.warning("Code execution timeout")
            return CodeResponse(
                stdout="",
                stderr="Execution timeout: Code took longer than 35 seconds to execute",
                success=False,
                error_message="Timeout after 35 seconds"
            )
        
        except FileNotFoundError:
            logger.error("M2 command not found")
            raise HTTPException(
                status_code=500, 
                detail="Macaulay2 not found. Please ensure M2 is installed and in PATH."
            )
        
        except Exception as e:
            logger.error(f"Execution error: {e}")
            raise HTTPException(status_code=500, detail=f"Execution error: {str(e)}")


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    # Check if Macaulay2 is available
    try:
        result = subprocess.run(
            ['M2', '--version'],
            capture_output=True,
            text=True,
            timeout=5
        )
        m2_available = result.returncode == 0
        m2_version = result.stdout.strip().split('\n')[0] if m2_available else None
    except (FileNotFoundError, subprocess.TimeoutExpired):
        m2_available = False
        m2_version = None
    
    return {
        "status": "healthy",
        "macaulay2_available": m2_available,
        "macaulay2_version": m2_version,
        "resource_limits": {
            "timeout_seconds": 35,
            "memory_limit_mb": 512,
            "cpu_time_limit_seconds": 30
        }
    }


@app.post("/test-m2")
async def test_m2():
    """
    Test endpoint to verify M2 execution with simple code
    Tries multiple execution methods
    """
    test_code = "2+2"
    results = {}
    
    # Method 1: stdin
    try:
        result = subprocess.run(
            ['M2', '-q', '--stop'],
            input=test_code + "\nexit\n",
            capture_output=True,
            text=True,
            timeout=5
        )
        results["stdin_method"] = {
            "returncode": result.returncode,
            "stdout": result.stdout,
            "stderr": result.stderr,
            "stdout_length": len(result.stdout),
            "stderr_length": len(result.stderr),
        }
    except Exception as e:
        results["stdin_method"] = {"error": str(e)}
    
    # Method 2: script file
    try:
        with tempfile.TemporaryDirectory() as temp_dir:
            code_file = Path(temp_dir) / "test.m2"
            code_file.write_text(test_code, encoding='utf-8')
            
            result = subprocess.run(
                ['M2', '--script', str(code_file)],
                cwd=temp_dir,
                capture_output=True,
                text=True,
                timeout=5
            )
            results["script_method"] = {
                "returncode": result.returncode,
                "stdout": result.stdout,
                "stderr": result.stderr,
                "stdout_length": len(result.stdout),
                "stderr_length": len(result.stderr),
            }
    except Exception as e:
        results["script_method"] = {"error": str(e)}
    
    # Method 3: quiet script
    try:
        with tempfile.TemporaryDirectory() as temp_dir:
            code_file = Path(temp_dir) / "test.m2"
            code_file.write_text(test_code, encoding='utf-8')
            
            result = subprocess.run(
                ['M2', '-q', '--script', str(code_file)],
                cwd=temp_dir,
                capture_output=True,
                text=True,
                timeout=5
            )
            results["quiet_script_method"] = {
                "returncode": result.returncode,
                "stdout": result.stdout,
                "stderr": result.stderr,
                "stdout_length": len(result.stdout),
                "stderr_length": len(result.stderr),
            }
    except Exception as e:
        results["quiet_script_method"] = {"error": str(e)}
    
    return results



if __name__ == "__main__":
    import uvicorn
    import argparse
    parser = argparse.ArgumentParser(description="Run Macaulay2 Web Interface API server.")
    parser.add_argument('--port', type=int, default=8000, help='Port to run the server on (default: 8000)')
    args = parser.parse_args()
    uvicorn.run(app, host="0.0.0.0", port=args.port)
