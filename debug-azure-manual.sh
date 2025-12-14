#!/bin/bash
# Debug script for Azure VM - Run commands manually

echo "=== Step 1: Check current commit ==="
git log --oneline -1

echo ""
echo "=== Step 2: Pull latest changes ==="
git pull origin main

echo ""
echo "=== Step 3: Check if frontend has latest code ==="
git log --oneline -5

echo ""
echo "=== Step 4: Stop containers ==="
docker compose down

echo ""
echo "=== Step 5: Rebuild ONLY frontend ==="
docker compose build frontend --no-cache

echo ""
echo "=== Step 6: Start all containers ==="
docker compose up -d

echo ""
echo "=== Step 7: Wait 20 seconds ==="
sleep 20

echo ""
echo "=== Step 8: Check container status ==="
docker compose ps

echo ""
echo "=== Step 9: Test API - Create post with file ==="
TOKEN=$(curl -s -X POST http://localhost:5001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test123!@#"}' | jq -r '.accessToken')

echo "Token: ${TOKEN:0:50}..."

echo ""
echo "Creating test image file..."
echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==" | base64 -d > /tmp/test.png

echo ""
echo "=== Step 10: Upload post with image ==="
curl -X POST http://localhost:5001/api/posts \
  -H "Authorization: Bearer $TOKEN" \
  -F "title=Test Upload" \
  -F "content=Testing file upload" \
  -F "published=true" \
  -F "file=@/tmp/test.png" | jq .

echo ""
echo "=== Step 11: Get all posts (check fileUrl) ==="
curl -s http://localhost:5001/api/posts | jq '.posts[0] | {id, title, fileUrl}'

echo ""
echo "=== Step 12: Check uploads folder ==="
docker compose exec backend ls -lah /app/uploads/ | head -10

echo ""
echo "=== Step 13: Test if uploaded file is accessible ==="
FIRST_POST_URL=$(curl -s http://localhost:5001/api/posts | jq -r '.posts[0].fileUrl')
echo "File URL from API: $FIRST_POST_URL"

if [ ! -z "$FIRST_POST_URL" ] && [ "$FIRST_POST_URL" != "null" ]; then
  echo "Testing file accessibility..."
  curl -I "$FIRST_POST_URL" 2>&1 | head -5
fi

echo ""
echo "=== Step 14: Check backend logs for URL generation ==="
docker compose logs backend --tail 50 | grep -E "POST|fileUrl|uploads" | tail -20

echo ""
echo "=== DONE - Summary ==="
echo "1. Frontend rebuilt: Check if latest commit matches local"
echo "2. File upload test: Check if fileUrl is returned"
echo "3. Check uploads folder: Verify files are saved"
echo "4. Test file accessibility: Check if curl can access the file"
echo ""
echo "If fileUrl is still localhost:5001 instead of 20.2.83.176:5001,"
echo "check backend logs and docker-compose environment variables"
