#!/bin/bash

# Update system packages
sudo apt update && sudo apt upgrade -y

# Install system dependencies
sudo apt install -y python3-pip python3-dev libpq-dev postgresql postgresql-contrib nginx curl

# Create a Python virtual environment
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Configure PostgreSQL
sudo -u postgres psql -c "CREATE DATABASE qengine;"
sudo -u postgres psql -c "CREATE USER qengineuser WITH PASSWORD 'your_password';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE qengine TO qengineuser;"

# Update .env file with PostgreSQL credentials
cat > .env << EOL
APP_NAME=qEngine
DEBUG=False
DATABASE_URL=postgresql://qengineuser:your_password@localhost:5432/qengine
JWT_SECRET_KEY=$(openssl rand -hex 32)
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
EOL

# Create service file for Gunicorn
sudo bash -c 'cat > /etc/systemd/system/qengine.service << EOL
[Unit]
Description=qEngine FastAPI application
After=network.target

[Service]
User=$USER
Group=www-data
WorkingDirectory=$PWD
Environment="PATH=$PWD/venv/bin"
ExecStart=$PWD/venv/bin/gunicorn src.app.main:app --workers 2 --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000

[Install]
WantedBy=multi-user.target
EOL'

# Configure Nginx with rate limiting and security headers
sudo bash -c 'cat > /etc/nginx/sites-available/qengine << EOL
limit_req_zone $binary_remote_addr zone=one:10m rate=30r/m;

server {
    listen 80;
    server_name _;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    location / {
        limit_req zone=one burst=5;
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Deny access to .git and other sensitive directories
    location ~ /\. {
        deny all;
    }
}
EOL'

# Enable the Nginx site and remove default
sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/qengine /etc/nginx/sites-enabled/

# Start and enable services
sudo systemctl daemon-reload
sudo systemctl start qengine
sudo systemctl enable qengine
sudo systemctl restart nginx

# Set up automatic backups (create a backup script)
cat > backup.sh << EOL
#!/bin/bash
BACKUP_DIR="/home/$USER/backups"
TIMESTAMP=\$(date +"%Y%m%d_%H%M%S")

# Create backup directory if it doesn't exist
mkdir -p \$BACKUP_DIR

# Backup PostgreSQL database
pg_dump -U qengineuser qengine > \$BACKUP_DIR/qengine_\${TIMESTAMP}.sql

# Compress backup
gzip \$BACKUP_DIR/qengine_\${TIMESTAMP}.sql

# Keep only last 7 days of backups
find \$BACKUP_DIR -name "qengine_*.sql.gz" -mtime +7 -delete
EOL

chmod +x backup.sh

# Add backup cron job
(crontab -l 2>/dev/null; echo "0 0 * * * $PWD/backup.sh") | crontab -

echo "Deployment complete! The API should be running on port 80."
echo "Please make sure to:"
echo "1. Configure your Lightsail firewall to allow HTTP (port 80) traffic"
echo "2. Update the PostgreSQL password in .env"
echo "3. Consider setting up HTTPS using Lightsail's load balancer or Certbot" 