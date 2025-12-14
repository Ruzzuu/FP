#!/bin/bash

# Azure VM Fix Script - Run dengan sudo
# Usage: sudo bash fix-azure.sh

echo "=== 1. Add user to docker group (no more sudo needed) ==="
usermod -aG docker azureuser
echo "✓ User added to docker group (logout & login untuk efek)"

echo -e "\n=== 2. Check backend logs ==="
docker compose logs backend --tail 50

echo -e "\n=== 3. Stop all containers ==="
docker compose down

echo -e "\n=== 4. Rebuild backend (fix Prisma binary) ==="
docker compose build --no-cache backend

echo -e "\n=== 5. Start all services ==="
docker compose up -d

echo -e "\n=== 6. Wait 30 seconds ==="
sleep 30

echo -e "\n=== 7. Check status ==="
docker compose ps

echo -e "\n=== 8. Check backend logs again ==="
docker compose logs backend --tail 30

echo -e "\n=== 9. Test API ==="
curl http://localhost:5001/api || echo "Backend still not ready"

echo -e "\n=== DONE ==="
echo "If backend still restarting, check logs: docker compose logs backend"
