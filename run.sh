#/bin/bash
docker rm -f flask-app
docker build -t flask-app .
docker run -d -p 8000:8000 flask-app
