# Docker + Nginx + Flask + CertBot

This setup is very similar to what is described in

https://medium.com/@yusufkaratoprak/setting-up-a-flask-application-with-docker-nginx-and-lets-encrypt-1a2f33f86867

The first couple of steps:

1. Install docker

```
sudo apt update -y
sudo apt upgrade -y
curl -sSL https://get.docker.com | sh
sudo usermod -aG docker $USER
```

2. Clone this repo

3. Pick your domain name, and point it at your server with an A record

4. Run certbot with nginx setup

```
sudo apt install -y nginx python3-certbot-nginx 
sudo certbot --nginx -d example.com -d www.example.com
```

5. Modify the generated nginx file to do reverse proxy to flask

 - Remove lines that mention `index.xxx` and serving files directly under the 443 server section.
 - Add a appserver section.
 - Change the location section under the server 443 to do all the proxy calls.
 - See the sample below
```
upstream app_servers {
    server 127.0.0.1:8000;
}

server {
    listen 80;
    server_name example.com www.example.com;
    
    location / {
        return 301 https://$server_name$request_uri;
    }
}

server {
    listen 443 ssl;
    server_name dev-ops.sample www.dev-ops.sample;

    ssl_certificate /etc/letsencrypt/live/www.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/www.example.com/privkey.pem;

    location / {
        proxy_pass http://app_servers;
        include proxy_params;
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

6. Restart nginx
```
nginx -t
systemctl restart nginx.service
```

7. Build and run the Dockerfile

```
./run.py
```

8. Test certbot renewal

```
certbot renew --dry-run
systemctl list-timers
```

And that's it!  Now you have https for free and it should refresh in perpeturity.  Also consider having system updates happen in the background with something like:

```
sudo apt-get install unattended-upgrades -y
sudo dpkg-reconfigure --priority=low unattended-upgrades
```
