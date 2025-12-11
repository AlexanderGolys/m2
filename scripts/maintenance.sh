#!/usr/bin/env bash
set -euo pipefail

# Maintenance script: safe fast-forward pull and backend service restart.
# Usage: run on the server from the repository root (e.g., /var/www/m2-interface):
#   ./scripts/maintenance.sh
#
# This script will:
# - Check repo status and abort if there are uncommitted changes (unless CLEAN=1)
# - Pull with --ff-only
# - Optionally purge generated/untracked files
# - Optionally redeploy backend/frontend
# - Restart the m2-backend systemd service
#
# Flags:
#   CLEAN=1              discard local changes via hard reset to origin/<branch>
#   PURGE_IGNORED=1      remove ignored files (git clean -fdX) e.g., dist, node_modules, __pycache__, venv
#   PURGE_ALL=1          remove ALL untracked files (git clean -fdx) — destructive
#   REDEPLOY_BACKEND=1   run deploy/deploy_backend.sh after updating
#   REDEPLOY_FRONTEND=1  run deploy/deploy_frontend.sh after updating
#   SERVICE=m2-backend   override service name

CLEAN="${CLEAN:-0}"
PURGE_IGNORED="${PURGE_IGNORED:-0}"
PURGE_ALL="${PURGE_ALL:-0}"
REDEPLOY_BACKEND="${REDEPLOY_BACKEND:-0}"
REDEPLOY_FRONTEND="${REDEPLOY_FRONTEND:-0}"
SERVICE="${SERVICE:-m2-backend}"

# Ensure we are in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "Error: not inside a git repository. cd to your repo root (e.g., /var/www/m2-interface)." >&2
  exit 1
fi

# Check status
CHANGES=$(git status --porcelain)
if [ -n "$CHANGES" ]; then
  if [ "$CLEAN" = "1" ]; then
    echo "CLEAN=1 set. Discarding local changes with a hard reset to origin/<branch>..."
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
    git fetch --all --prune
    git reset --hard "origin/${BRANCH}"
  else
    echo "Working tree has local changes. Aborting. Set CLEAN=1 to discard local changes automatically." >&2
    git status
    exit 2
  fi
fi

# Fetch and fast-forward pull
git fetch --all --prune
if ! git pull --ff-only; then
  echo "Fast-forward pull failed. Resolve conflicts manually and re-run." >&2
  exit 3
fi

# Purge inconsistent generated artifacts if requested
if [ "$PURGE_ALL" = "1" ]; then
  echo "PURGE_ALL=1 set. Removing ALL untracked files (git clean -fdx)..."
  git clean -fdx
elif [ "$PURGE_IGNORED" = "1" ]; then
  echo "PURGE_IGNORED=1 set. Removing ignored files (git clean -fdX)..."
  git clean -fdX
fi

# Optional redeploy steps
if [ "$REDEPLOY_BACKEND" = "1" ]; then
  if [ -x "deploy/deploy_backend.sh" ]; then
    echo "Redeploying backend via deploy/deploy_backend.sh..."
    ./deploy/deploy_backend.sh
  elif [ -f "deploy/deploy_backend.sh" ]; then
    echo "Redeploying backend via deploy/deploy_backend.sh..."
    bash ./deploy/deploy_backend.sh
  else
    echo "deploy/deploy_backend.sh not found. Skipping backend redeploy." >&2
  fi
fi

if [ "$REDEPLOY_FRONTEND" = "1" ]; then
  if [ -x "deploy/deploy_frontend.sh" ]; then
    echo "Redeploying frontend via deploy/deploy_frontend.sh..."
    ./deploy/deploy_frontend.sh
  elif [ -f "deploy/deploy_frontend.sh" ]; then
    echo "Redeploying frontend via deploy/deploy_frontend.sh..."
    bash ./deploy/deploy_frontend.sh
  else
    echo "deploy/deploy_frontend.sh not found. Skipping frontend redeploy." >&2
  fi
fi

# Restart service
if command -v systemctl >/dev/null 2>&1; then
  echo "Restarting service: ${SERVICE}"
  sudo systemctl restart "${SERVICE}"
  sudo systemctl status "${SERVICE}" --no-pager || true
else
  echo "systemctl not found; skipping service restart." >&2
fi

echo "Maintenance completed successfully."
