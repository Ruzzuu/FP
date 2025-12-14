#!/bin/bash

# Quick Start Script untuk Azure VM
# Run on Azure VM: bash start-azure.sh

echo "=== FP-PBKK Azure Deployment ==="
echo "Current directory: $(pwd)"
echo "Current user: $(whoami)"

# Check if docker is installed
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker not installed!"
    exit 1
fi

echo -e "\n=== 1. Copy Azure environment file ==="
cp .env.azure .env
echo "✓ Using .env.azure configuration"

echo -e "\n=== 2. Stop old containers ==="
docker compose down

echo -e "\n=== 3. Pull latest images ==="
docker compose pull postgres || echo "Will build from Dockerfile"

echo -e "\n=== 4. Build containers ==="
docker compose build

echo -e "\n=== 5. Start all services ==="
docker compose up -d

echo -e "\n=== 6. Waiting 30 seconds for startup ==="
for i in {30..1}; do
    echo -ne "  $i seconds remaining...\r"
    sleep 1
done
echo -e "\n"

echo -e "=== 7. Check container status ==="
docker compose ps

echo -e "\n=== 8. Test Backend API ==="
sleep 5
BACKEND_RESPONSE=$(curl -s http://localhost:5001/api)
if [ -n "$BACKEND_RESPONSE" ]; then
    echo "✓ Backend is responding:"
    echo "$BACKEND_RESPONSE"
else
    echo "✗ Backend not responding yet. Check logs:"
    docker compose logs backend --tail 20
fi

echo -e "\n=== 9. Show recent logs ==="
echo "--- Backend ---"
docker compose logs backend --tail 10
echo -e "\n--- Frontend ---"
docker compose logs frontend --tail 10

echo -e "\n=== DEPLOYMENT COMPLETE ==="
echo "📱 Frontend: http://20.2.83.176:80"
echo "🔧 Backend API: http://20.2.83.176:5001/api"
echo "🗄️  PostgreSQL: localhost:5432 (not exposed to internet)"
echo ""
echo "⚠️  IMPORTANT: Configure Azure NSG to allow ports 80 and 5001!"
echo ""
echo "Check status: docker compose ps"
echo "View logs: docker compose logs -f backend"
echo "Stop all: docker compose down"
