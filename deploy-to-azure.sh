#!/bin/bash

# Script untuk deploy ke Azure VM
# Run: bash deploy-to-azure.sh

AZURE_IP="20.2.83.176"
AZURE_USER="azureuser"
AZURE_DIR="~/fp_cc/FP"

echo "=== 1. Push code ke GitHub ==="
git add .
git commit -m "Fix CORS and port configuration"
git push origin main

echo -e "\n=== 2. SSH ke Azure dan pull latest code ==="
ssh ${AZURE_USER}@${AZURE_IP} << 'EOF'
cd ~/fp_cc/FP
git pull origin main

echo -e "\n=== 3. Stop old containers ==="
docker compose down

echo -e "\n=== 4. Rebuild containers ==="
docker compose build --no-cache

echo -e "\n=== 5. Start containers ==="
docker compose up -d

echo -e "\n=== 6. Wait for services ==="
sleep 30

echo -e "\n=== 7. Check status ==="
docker compose ps

echo -e "\n=== 8. Test backend API ==="
curl -s http://localhost:5001/api || echo "Backend not ready"

echo -e "\n=== 9. Check logs ==="
docker compose logs backend --tail 20

echo -e "\n=== SUCCESS! ==="
echo "Frontend: http://20.2.83.176:80"
echo "Backend API: http://20.2.83.176:5001/api"
EOF
