#!/bin/bash

# 1. Update system and install dependencies
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y nodejs npm nginx mysql-client git

# 2. Clone repo safely as ubuntu user
cd /home/ubuntu
sudo -u ubuntu git clone https://github.com/pravinmishraaws/theepicbook.git
cd /home/ubuntu/theepicbook

# 3. Install node dependencies safely as ubuntu user
sudo -u ubuntu npm install

# 4. Overwrite config.json dynamically with Terraform variables
cat << 'JSON' > /home/ubuntu/theepicbook/config/config.json
{
  "development": {
    "username": "${db_user}",
    "password": "${db_password}",
    "database": "${db_name}",
    "host": "${db_host}",
    "dialect": "mysql",
    "dialectOptions": {
      "ssl": {
        "require": true,
        "rejectUnauthorized": false
      }
    }
  }
}
JSON

# 5. Ensure correct ownership
chown ubuntu:ubuntu /home/ubuntu/theepicbook/config/config.json

# 6. Wait for RDS to be fully available
until mysql -h ${db_host} -u ${db_user} -p${db_password} -e "SELECT 1" >/dev/null 2>&1; do
  sleep 10
done

# 7. Import schema & seed data
mysql -h ${db_host} -u ${db_user} -p${db_password} ${db_name} < db/BuyTheBook_Schema.sql
mysql -h ${db_host} -u ${db_user} -p${db_password} ${db_name} < db/author_seed.sql
mysql -h ${db_host} -u ${db_user} -p${db_password} ${db_name} < db/books_seed.sql

# 8. Install PM2 and Start App
npm install -g pm2
sudo -u ubuntu bash -c 'cd /home/ubuntu/theepicbook && pm2 start server.js && pm2 save'

# 9. Enable PM2 Auto Start
env PATH=$PATH:/usr/bin pm2 startup systemd -u ubuntu --hp /home/ubuntu
systemctl enable pm2-ubuntu

# 10. Nginx Config (Safe Escaping)
cat << 'NGINX' > /etc/nginx/sites-available/default
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
NGINX

# 11. Restart Nginx
nginx -t && systemctl restart nginx
