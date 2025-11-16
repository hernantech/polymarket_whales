# Polymarket Whales - Deployment Guide

This project uses Docker Compose to orchestrate three containers:
- **Frontend**: React app served via Nginx
- **Backend**: Flask API server
- **Database**: PostgreSQL database

## Prerequisites

- Docker (v20.10+)
- Docker Compose (v2.0+)

## Quick Start

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd polymarket_whales
   ```

2. **Set up environment variables (optional)**
   Create a `.env` file in the root directory:
   ```env
   DB_PASSWORD=your_secure_password
   FLASK_ENV=production
   ```

3. **Start all services**
   ```bash
   docker-compose up -d
   ```

4. **Check service status**
   ```bash
   docker-compose ps
   ```

5. **View logs**
   ```bash
   # All services
   docker-compose logs -f

   # Specific service
   docker-compose logs -f backend
   ```

## Service Details

### Frontend
- **Port**: 80
- **URL**: http://localhost
- **Technology**: React + Nginx
- **Build**: Multi-stage build for optimized production image

### Backend
- **Port**: 5000
- **URL**: http://localhost:5000
- **Technology**: Flask + Gunicorn
- **Workers**: 4 (configurable in Dockerfile)
- **Endpoints**:
  - `GET /` - API info
  - `GET /health` - Health check
  - `GET /ready` - Readiness check
  - `GET /api/whales` - Whale data

### Database
- **Port**: 5432
- **Technology**: PostgreSQL 15 (Alpine)
- **Database Name**: polymarket_whales
- **Default User**: postgres
- **Volume**: Persistent storage via Docker volume

## Common Commands

### Start services
```bash
docker-compose up -d
```

### Stop services
```bash
docker-compose down
```

### Stop and remove volumes (⚠️ deletes data)
```bash
docker-compose down -v
```

### Rebuild containers
```bash
docker-compose up -d --build
```

### Access database
```bash
docker-compose exec database psql -U postgres -d polymarket_whales
```

### Access backend shell
```bash
docker-compose exec backend bash
```

### View real-time logs
```bash
docker-compose logs -f
```

## Development Mode

For development with hot-reload:

1. **Backend**: Modify `docker-compose.yaml` to set `FLASK_ENV=development`
2. **Frontend**: Run development server outside Docker or modify Dockerfile

## Production Deployment

1. **Set secure passwords**: Update `.env` with strong passwords
2. **Update image registry**: Modify `docker-compose.yaml` to use your container registry
3. **Configure reverse proxy**: Set up Nginx/Traefik for SSL termination
4. **Enable monitoring**: Add health check monitoring
5. **Backup database**: Set up automated backup for postgres_data volume

## Database Initialization

The database automatically runs scripts from `database/init/` on first startup:
- `01-init.sql` - Creates tables, indexes, and sample data

To reset the database:
```bash
docker-compose down -v
docker-compose up -d
```

## Troubleshooting

### Database connection errors
```bash
# Check if database is healthy
docker-compose ps database

# View database logs
docker-compose logs database

# Verify connection from backend
docker-compose exec backend python -c "from app import get_db_connection; print(get_db_connection())"
```

### Frontend not loading
```bash
# Check nginx logs
docker-compose logs frontend

# Verify nginx config
docker-compose exec frontend nginx -t
```

### Port conflicts
If ports 80, 5000, or 5432 are already in use, modify the port mappings in `docker-compose.yaml`:
```yaml
ports:
  - "8080:80"  # Frontend on port 8080
```

## Architecture

```
┌─────────────┐
│   Browser   │
└──────┬──────┘
       │
       │ HTTP :80
       ▼
┌─────────────────┐
│    Frontend     │
│  (Nginx:80)     │
└────────┬────────┘
         │
         │ /api → :5000
         ▼
┌─────────────────┐
│     Backend     │
│  (Flask:5000)   │
└────────┬────────┘
         │
         │ :5432
         ▼
┌─────────────────┐
│    Database     │
│ (Postgres:5432) │
└─────────────────┘
```

## File Structure

```
polymarket_whales/
├── docker-compose.yaml       # Orchestration configuration
├── frontend/
│   ├── Dockerfile            # Frontend container definition
│   ├── nginx.conf            # Nginx configuration
│   └── package.json          # Node.js dependencies
├── backend/
│   ├── Dockerfile            # Backend container definition
│   ├── requirements.txt      # Python dependencies
│   └── app.py                # Flask application
└── database/
    └── init/
        └── 01-init.sql       # Database initialization script
```

## Security Notes

⚠️ **Important**: This setup is for development. For production:
- Use secrets management (Docker Secrets, Kubernetes Secrets)
- Enable SSL/TLS
- Configure firewall rules
- Use non-default passwords
- Implement rate limiting
- Enable CORS properly
- Keep images updated
