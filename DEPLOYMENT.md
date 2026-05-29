# AWS Deployment Guide

This project is a Django website. The recommended production setup is:

- GitHub for source control
- GitHub Actions for CI tests
- AWS EC2 Ubuntu server
- Nginx as reverse proxy
- Gunicorn as Django application server
- PostgreSQL/RDS for a professional production database
- S3 for media uploads when the site grows

## 1. Server Setup

Create an Ubuntu EC2 instance, open ports `22`, `80`, and `443`, then SSH into it.

```bash
sudo apt update
sudo apt install -y python3-venv python3-pip nginx git
```

## 2. Clone Code

```bash
cd /var/www
sudo git clone https://github.com/anshul1504/shreerudrabullions.git
sudo chown -R $USER:$USER shreerudrabullions
cd shreerudrabullions
```

## 3. Python Environment

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

## 4. Environment Variables

Create `.env` on the server from `.env.example`. Use a real secret key and production domain.

```bash
cp .env.example .env
nano .env
```

For systemd, load these values in the service file or an environment file.

## 5. Django Commands

```bash
source .venv/bin/activate
python manage.py migrate
python manage.py collectstatic --noinput
python manage.py createsuperuser
python manage.py check --deploy
```

## 6. Gunicorn systemd Service

Create `/etc/systemd/system/shreerudra.service`:

```ini
[Unit]
Description=Shree Rudra Bullion Django app
After=network.target

[Service]
User=ubuntu
Group=www-data
WorkingDirectory=/var/www/shreerudrabullions
EnvironmentFile=/var/www/shreerudrabullions/.env
ExecStart=/var/www/shreerudrabullions/.venv/bin/gunicorn config.wsgi:application --bind unix:/run/shreerudra.sock
Restart=always

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now shreerudra
sudo systemctl status shreerudra
```

## 7. Nginx

Create `/etc/nginx/sites-available/shreerudra`:

```nginx
server {
    listen 80;
    server_name example.com www.example.com;

    location /static/ {
        alias /var/www/shreerudrabullions/staticfiles/;
    }

    location /media/ {
        alias /var/www/shreerudrabullions/media/;
    }

    location / {
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_pass http://unix:/run/shreerudra.sock;
    }
}
```

```bash
sudo ln -s /etc/nginx/sites-available/shreerudra /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## 8. HTTPS

```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d example.com -d www.example.com
```

## 9. CI/CD Flow

CI is included in `.github/workflows/ci.yml`. Every push to `main` runs:

- dependency install
- `python manage.py check`
- Django smoke tests

For CD, add GitHub repository secrets:

- `AWS_HOST`
- `AWS_USER`
- `AWS_SSH_KEY`

Then add a deploy workflow that SSHs into EC2 and runs:

```bash
cd /var/www/shreerudrabullions
git pull origin main
source .venv/bin/activate
pip install -r requirements.txt
python manage.py migrate
python manage.py collectstatic --noinput
sudo systemctl restart shreerudra
```

## 10. Future Development Workflow

Use this process:

1. Create a feature branch.
2. Make changes locally.
3. Run `python manage.py check` and tests.
4. Push branch and open PR.
5. Merge only after CI passes.
6. Deploy from `main`.
