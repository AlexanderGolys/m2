#!/usr/bin/env python3
"""
Test script to debug Macaulay2 execution
Run this on the server to see what M2 actually outputs
"""

import subprocess
import tempfile
from pathlib import Path

# Test code
test_code = """-- Macaulay2 example
R = QQ[x,y,z]
I = ideal(x^2 + y^2, z^2)
I"""

print("=" * 60)
print("Testing Macaulay2 Execution")
print("=" * 60)

# Create temp directory
with tempfile.TemporaryDirectory() as temp_dir:
    code_file = Path(temp_dir) / "input.m2"
    code_file.write_text(test_code, encoding='utf-8')
    
    print(f"\nTest code written to: {code_file}")
    print(f"Code content:\n{test_code}\n")
    
    # Test 1: With --script flag
    print("\n" + "=" * 60)
    print("Test 1: M2 --script input.m2")
    print("=" * 60)
    
    try:
        result = subprocess.run(
            ['M2', '--script', str(code_file)],
            cwd=temp_dir,
            capture_output=True,
            text=True,
            timeout=10
        )
        
        print(f"Return code: {result.returncode}")
        print(f"\nSTDOUT ({len(result.stdout)} chars):")
        print("-" * 60)
        print(result.stdout if result.stdout else "(empty)")
        print("-" * 60)
        
        print(f"\nSTDERR ({len(result.stderr)} chars):")
        print("-" * 60)
        print(result.stderr if result.stderr else "(empty)")
        print("-" * 60)
        
    except FileNotFoundError:
        print("ERROR: M2 command not found!")
    except Exception as e:
        print(f"ERROR: {e}")
    
    # Test 2: With -q (quiet) flag
    print("\n" + "=" * 60)
    print("Test 2: M2 -q --script input.m2")
    print("=" * 60)
    
    try:
        result = subprocess.run(
            ['M2', '-q', '--script', str(code_file)],
            cwd=temp_dir,
            capture_output=True,
            text=True,
            timeout=10
        )
        
        print(f"Return code: {result.returncode}")
        print(f"\nSTDOUT ({len(result.stdout)} chars):")
        print("-" * 60)
        print(result.stdout if result.stdout else "(empty)")
        print("-" * 60)
        
        print(f"\nSTDERR ({len(result.stderr)} chars):")
        print("-" * 60)
        print(result.stderr if result.stderr else "(empty)")
        print("-" * 60)
        
    except FileNotFoundError:
        print("ERROR: M2 command not found!")
    except Exception as e:
        print(f"ERROR: {e}")
    
    # Test 3: Using stdin
    print("\n" + "=" * 60)
    print("Test 3: echo 'code' | M2 --stop")
    print("=" * 60)
    
    try:
        result = subprocess.run(
            ['M2', '--stop'],
            input=test_code + "\nexit\n",
            capture_output=True,
            text=True,
            cwd=temp_dir,
            timeout=10
        )
        
        print(f"Return code: {result.returncode}")
        print(f"\nSTDOUT ({len(result.stdout)} chars):")
        print("-" * 60)
        print(result.stdout if result.stdout else "(empty)")
        print("-" * 60)
        
        print(f"\nSTDERR ({len(result.stderr)} chars):")
        print("-" * 60)
        print(result.stderr if result.stderr else "(empty)")
        print("-" * 60)
        
    except FileNotFoundError:
        print("ERROR: M2 command not found!")
    except Exception as e:
        print(f"ERROR: {e}")

    # Test 4: Check M2 version
    print("\n" + "=" * 60)
    print("Test 4: M2 --version")
    print("=" * 60)
    
    try:
        result = subprocess.run(
            ['M2', '--version'],
            capture_output=True,
            text=True,
            timeout=5
        )
        
        print(f"Return code: {result.returncode}")
        print(f"\nSTDOUT:")
        print(result.stdout)
        print(f"\nSTDERR:")
        print(result.stderr)
        
    except FileNotFoundError:
        print("ERROR: M2 command not found!")
    except Exception as e:
        print(f"ERROR: {e}")

print("\n" + "=" * 60)
print("Testing complete!")
print("=" * 60)
