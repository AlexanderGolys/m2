#!/bin/bash
# This script is deprecated - use deploy_backend.sh instead
# It handles both frontend and backend deployments

echo "This script is no longer needed"
echo "Use: bash deploy_backend.sh --frontend instead"
exec bash "$(dirname "$0")/deploy_backend.sh" --frontend
