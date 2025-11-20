# Example Nginx config for macaulay2.fun
# Edit as needed for your environment

server {
    listen 80;
    server_name macaulay2.fun www.macaulay2.fun;

    root /var/www/html/m2-interface/frontend/dist;
    index index.html;

    # Proxy API requests to backend
    location /api {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Proxy admin stats to backend
    location /admin/stats {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Serve static files and fallback to index.html for SPA
    location / {
        try_files $uri $uri/ /index.html;
    }
}
