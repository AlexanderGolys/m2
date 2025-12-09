set -e  # Exit on error

export DEBIAN_FRONTEND=noninteractive

sudo apt update
sudo apt upgrade -y

sudo apt install -y macaulay2
sudo M2 --version

sudo apt install -y python3 python3-pip python3-venv

# Install Node.js and npm (for frontend build)
echo "Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
``
sudo apt install -y nginx
sudo apt install -y certbot python3-certbot-nginx

# Create application directory
echo "Creating application directory..."
sudo mkdir -p /var/www/m2-interface
sudo chown $USER:$USER /var/www/m2-interface

# Install UFW firewall
echo "Setting up firewall..."
sudo apt install -y ufw
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw --force enable

echo "==================================="
echo "Base setup complete!"
echo "==================================="
