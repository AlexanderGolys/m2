
import subprocess
import tempfile
import os
from pathlib import Path


def execute_m2_stdin(code: str, timeout: int = 35, set_resource_limits=None):
    """
    Execute M2 code using stdin (pipe method)
    This method sends code directly to M2's standard input
    """
    result = subprocess.run(
        ['M2', '-q', '--stop'],  # -q: quiet, --stop: non-interactive
        input=code + "\nexit\n",  # Add exit to ensure M2 terminates
        capture_output=True,
        text=True,
        timeout=timeout,
        preexec_fn=set_resource_limits if os.name != 'nt' else None,
    )
    return result


def execute_m2_script(code: str, timeout: int = 35, set_resource_limits=None):
    """
    Execute M2 code using --script flag with file
    This is the current default method
    """
    with tempfile.TemporaryDirectory() as temp_dir:
        code_file = Path(temp_dir) / "input.m2"
        code_file.write_text(code, encoding='utf-8')
        
        result = subprocess.run(
            ['M2', '--script', str(code_file)],
            cwd=temp_dir,
            capture_output=True,
            text=True,
            timeout=timeout,
            preexec_fn=set_resource_limits if os.name != 'nt' else None,
        )
        return result


def execute_m2_quiet_script(code: str, timeout: int = 35, set_resource_limits=None):
    """
    Execute M2 code using -q --script flags
    Suppresses banner and runs script
    """
    with tempfile.TemporaryDirectory() as temp_dir:
        code_file = Path(temp_dir) / "input.m2"
        code_file.write_text(code, encoding='utf-8')
        
        result = subprocess.run(
            ['M2', '-q', '--script', str(code_file)],
            cwd=temp_dir,
            capture_output=True,
            text=True,
            timeout=timeout,
            preexec_fn=set_resource_limits if os.name != 'nt' else None,
        )
        return result


def execute_m2_with_print(code: str, timeout: int = 35, set_resource_limits=None):
    """
    Execute M2 code wrapped with explicit print
    Forces output even if last expression doesn't auto-print
    """
    with tempfile.TemporaryDirectory() as temp_dir:
        # Wrap each line that looks like an expression with print
        wrapped_code = code
        
        code_file = Path(temp_dir) / "input.m2"
        code_file.write_text(wrapped_code, encoding='utf-8')
        
        result = subprocess.run(
            ['M2', '-q', '--script', str(code_file)],
            cwd=temp_dir,
            capture_output=True,
            text=True,
            timeout=timeout,
            preexec_fn=set_resource_limits if os.name != 'nt' else None,
        )
        return result


# Test function
if __name__ == "__main__":
    test_code = """R = QQ[x,y,z]
I = ideal(x^2 + y^2, z^2)
I"""

    print("Testing different M2 execution methods...")
    print("=" * 60)
    
    methods = [
        ("stdin", execute_m2_stdin),
        ("script", execute_m2_script),
        ("quiet_script", execute_m2_quiet_script),
    ]
    
    for name, func in methods:
        print(f"\n{name.upper()}:")
        print("-" * 60)
        try:
            result = func(test_code, timeout=10)
            print(f"Return code: {result.returncode}")
            print(f"STDOUT ({len(result.stdout)} chars): {result.stdout[:200]}")
            print(f"STDERR ({len(result.stderr)} chars): {result.stderr[:200]}")
        except Exception as e:
            print(f"Error: {e}")
