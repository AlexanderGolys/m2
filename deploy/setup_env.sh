#!/bin/bash
# Usage: ./setup_env.sh [prod|dev]
# Example: ./setup_env.sh dev

set -e

if [ "$1" == "prod" ]; then
  DIR="/var/www/m2-interface"
  BRANCH="main"
elif [ "$1" == "dev" ]; then
  DIR="/var/www/m2-dev-interface"
  BRANCH="dev"
else
  echo "Usage: $0 [prod|dev]"
  exit 1
fi

REPO="https://github.com/AlexanderGolys/m2.git"

echo "Cloning $BRANCH branch into $DIR"
git clone "$REPO" "$DIR"
cd "$DIR"
git checkout "$BRANCH"

# Backend setup
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
deactivate
cd ..

# Frontend setup
cd frontend
npm install
cd ..

echo "========================================="
echo "Environment setup complete!"
echo "Directory: $DIR"
echo "Branch:    $BRANCH"
echo "========================================="
