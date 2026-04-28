#!/bin/bash

# Update system packages
sudo apt update && sudo apt upgrade -y

# Install system dependencies
sudo apt install -y python3-pip python3-dev libpq-dev postgresql postgresql-contrib nginx curl

# Install Python dependencies
pip3 install -r requirements.txt

# Create service file for Gunicorn
sudo bash -c 'cat > /etc/systemd/system/qengine.service << EOL
[Unit]
Description=qEngine FastAPI application
After=network.target

[Service]
User=ubuntu
Group=www-data
WorkingDirectory=/home/ubuntu/qEngine
Environment="PATH=/home/ubuntu/qEngine/venv/bin"
ExecStart=/home/ubuntu/qEngine/venv/bin/gunicorn src.app.main:app --workers 4 --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000

[Install]
WantedBy=multi-user.target
EOL'

# Configure Nginx
sudo bash -c 'cat > /etc/nginx/sites-available/qengine << EOL
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOL'

# Enable the Nginx site
sudo ln -s /etc/nginx/sites-available/qengine /etc/nginx/sites-enabled/

# Start and enable services
sudo systemctl start qengine
sudo systemctl enable qengine
sudo systemctl restart nginx

echo "Deployment complete! The API should be running on port 80." 