# Docker Observium for Swarm with Portainer

This repository contains Docker Compose configurations for deploying Observium in a Docker Swarm environment using Portainer. The setup includes persistent volumes for data integrity and has been optimized for stability in a Swarm environment.

## Features

- Docker Swarm compatible configurations
- Persistent volumes for database, logs, and RRD files
- Portainer-friendly environment variables
- Support for both AMD64 and ARM32v7 architectures
- Database stability optimizations
- Health checks for service monitoring
- Labeled services and networks for easier management

## Prerequisites

- Docker Swarm cluster
- Portainer installed on your Swarm
- Node with sufficient resources for Observium

## Deployment Instructions

### Option 1: Deploy using Portainer UI

1. Log into your Portainer instance
2. Navigate to Stacks → Add stack
3. Give your stack a name (e.g., "observium")
4. Select "Web editor" and paste the contents of `docker-compose.yml`
5. Enable "Environment variables" and upload the `.env` file or add variables manually
6. Click "Deploy the stack"
7. Copy `observium-db-init.sql` to the initialization volume:
   ```bash
   docker cp observium-db-init.sql observium_observium_mysql_init:/docker-entrypoint-initdb.d/
   ```

### Option 2: Deploy using Docker CLI

1. Clone this repository to your Swarm manager node
2. Deploy the stack:
   ```bash
   docker stack deploy -c docker-compose.yml observium
   ```
3. Copy the initialization script to the volume:
   ```bash
   docker cp observium-db-init.sql observium_observium_mysql_init:/docker-entrypoint-initdb.d/
   ```

## Architecture-Specific Deployments

### For AMD64 (x86_64) Systems

Use the `amd64/docker-compose.yml` file and set `STACK_NAME=observium-amd64` in the environment variables.

### For ARM32v7 Systems (Raspberry Pi, etc.)

Use the `arm32v7/docker-compose.yml` file and set `STACK_NAME=observium-arm32v7` in the environment variables.
Also, set `OBSERVIUM_DB_HOST=observiumdb` in the environment variables.

## Persistent Volumes

The stack creates and uses the following volumes for data persistence:

- `observium_mysql_data`: MySQL/MariaDB database files
- `observium_mysql_init`: Initialization scripts for the database
- `observium_logs`: Observium application logs
- `observium_rrd`: RRD files for metrics and graphs

## Database Stability Improvements

The configurations include several improvements to enhance database stability:

1. Optimized MariaDB parameters
2. Extended startup grace periods
3. More robust restart policies
4. Simplified health checks
5. Initialization script for consistent database setup

## Accessing Observium

Once deployed, access Observium at:
```
http://your-swarm-node:8888
```

Default login credentials:
- Username: admin
- Password: passw0rd

Change these credentials in the `.env` file before deployment for security.

## Troubleshooting

### Database Connection Issues

If the app service cannot connect to the database:

1. Check the database service logs:
   ```bash
   docker service logs observium_db
   ```

2. Verify the database container is running:
   ```bash
   docker service ps observium_db
   ```

3. Ensure the initialization script was properly copied to the volume.

### Architecture Mismatch

If you see errors about architecture compatibility:

1. Make sure you're using the correct docker-compose file for your architecture
2. Verify your node architecture with:
   ```bash
   docker node inspect self --format '{{.Description.Platform.Architecture}}'
   ```

## Maintenance

### Database Optimization

The database includes a stored procedure for optimization:

```sql
CALL observium.optimize_tables();
```

You can run this periodically to maintain database performance.

## License

See the [LICENSE](LICENSE) file for licensing information.