#!/bin/bash

echo "=== Stopping all containers ==="
docker compose down

echo -e "\n=== Rebuilding backend & frontend ==="
docker compose build --no-cache backend frontend

echo -e "\n=== Starting all services ==="
docker compose up -d

echo -e "\n=== Waiting for services to start ==="
sleep 10

echo -e "\n=== Checking status ==="
docker compose ps

echo -e "\n=== Backend logs ==="
docker compose logs backend --tail 10

echo -e "\n=== Frontend logs ==="
docker compose logs frontend --tail 10

echo -e "\n=== Testing backend API ==="
curl -s http://localhost:5001/api || echo "Backend not responding"

echo -e "\n=== Access URLs ==="
echo "Backend API: http://localhost:5001/api"
echo "Frontend: http://localhost:3001"
echo "PostgreSQL: localhost:5432"
