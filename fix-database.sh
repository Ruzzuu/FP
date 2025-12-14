#!/bin/bash
set -e

echo "=== Fix Database: Create tables and test register ==="

echo "1. Stop all containers"
sudo docker compose down

echo ""
echo "2. Remove old postgres volume (fresh start)"
sudo docker volume rm fp_postgres_data 2>/dev/null || echo "Volume already removed or doesn't exist"

echo ""
echo "3. Start postgres only"
sudo docker compose up -d postgres

echo ""
echo "4. Wait for postgres to be ready (20 seconds)"
sleep 20

echo ""
echo "5. Rebuild and start backend"
sudo docker compose up -d backend

echo ""
echo "6. Wait for backend to be ready (30 seconds)"
sleep 30

echo ""
echo "7. Run migrations to create tables"
sudo docker compose exec backend npx prisma migrate deploy

echo ""
echo "8. Check if tables exist"
sudo docker compose exec postgres psql -U prisma -d fpdb -c "\dt"

echo ""
echo "9. Start frontend"
sudo docker compose up -d frontend

echo ""
echo "10. Check all container status"
sudo docker compose ps

echo ""
echo "11. Test backend API"
curl -s http://localhost:5001/api | jq 2>/dev/null || curl http://localhost:5001/api

echo ""
echo "12. Test register endpoint (should create user)"
curl -X POST http://localhost:5001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test123!@#",
    "name": "Test User"
  }' | jq 2>/dev/null || curl -X POST http://localhost:5001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test123!@#",
    "name": "Test User"
  }'

echo ""
echo ""
echo "=== DONE ==="
echo "Buka browser: http://20.2.83.176:3001/register"
echo "Kalau masih error, kirim output dari: sudo docker compose logs backend --tail 200"
