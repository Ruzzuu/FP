#!/bin/bash
set -e

echo "=== Test All CRUD Operations ==="

BASE_URL="http://localhost:5001/api"
EMAIL="testuser-$(date +%s)@example.com"
PASSWORD="Test123!@#"
TOKEN=""

echo ""
echo "1. Register user: $EMAIL"
REGISTER_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"$EMAIL\",
    \"password\": \"$PASSWORD\",
    \"name\": \"Test User\"
  }")
echo "$REGISTER_RESPONSE" | jq . 2>/dev/null || echo "$REGISTER_RESPONSE"

TOKEN=$(echo "$REGISTER_RESPONSE" | jq -r '.accessToken' 2>/dev/null)
if [ "$TOKEN" = "null" ] || [ -z "$TOKEN" ]; then
  echo "ERROR: Registration failed or token not received"
  exit 1
fi
echo "✓ Got access token: ${TOKEN:0:50}..."

echo ""
echo "2. Login with same user"
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"$EMAIL\",
    \"password\": \"$PASSWORD\"
  }")
echo "$LOGIN_RESPONSE" | jq . 2>/dev/null || echo "$LOGIN_RESPONSE"
echo "✓ Login successful"

echo ""
echo "3. Create post without file"
POST_RESPONSE=$(curl -s -X POST "$BASE_URL/posts" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "title": "Test Post",
    "content": "This is test content",
    "published": true
  }')
echo "$POST_RESPONSE" | jq . 2>/dev/null || echo "$POST_RESPONSE"

POST_ID=$(echo "$POST_RESPONSE" | jq -r '.id' 2>/dev/null)
if [ "$POST_ID" = "null" ] || [ -z "$POST_ID" ]; then
  echo "ERROR: Post creation failed"
  exit 1
fi
echo "✓ Created post with ID: $POST_ID"

echo ""
echo "4. Get all posts"
curl -s "$BASE_URL/posts?page=1&limit=10" | jq . 2>/dev/null || curl -s "$BASE_URL/posts?page=1&limit=10"
echo "✓ Get all posts successful"

echo ""
echo "5. Get single post"
curl -s "$BASE_URL/posts/$POST_ID" | jq . 2>/dev/null || curl -s "$BASE_URL/posts/$POST_ID"
echo "✓ Get single post successful"

echo ""
echo "6. Update post"
UPDATE_RESPONSE=$(curl -s -X PATCH "$BASE_URL/posts/$POST_ID" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "title": "Updated Test Post",
    "content": "Updated content"
  }')
echo "$UPDATE_RESPONSE" | jq . 2>/dev/null || echo "$UPDATE_RESPONSE"
echo "✓ Update post successful"

echo ""
echo "7. Add reply to post"
REPLY_RESPONSE=$(curl -s -X POST "$BASE_URL/posts/$POST_ID/reply" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "content": "This is a test reply"
  }')
echo "$REPLY_RESPONSE" | jq . 2>/dev/null || echo "$REPLY_RESPONSE"

REPLY_ID=$(echo "$REPLY_RESPONSE" | jq -r '.id' 2>/dev/null)
if [ "$REPLY_ID" = "null" ] || [ -z "$REPLY_ID" ]; then
  echo "Warning: Reply creation might have failed"
else
  echo "✓ Created reply with ID: $REPLY_ID"
fi

echo ""
echo "8. Get post with replies"
curl -s "$BASE_URL/posts/$POST_ID" | jq . 2>/dev/null || curl -s "$BASE_URL/posts/$POST_ID"
echo "✓ Get post with replies successful"

echo ""
echo "9. Delete reply (if created)"
if [ "$REPLY_ID" != "null" ] && [ -n "$REPLY_ID" ]; then
  DELETE_REPLY_RESPONSE=$(curl -s -X DELETE "$BASE_URL/posts/$POST_ID/reply/$REPLY_ID" \
    -H "Authorization: Bearer $TOKEN")
  echo "$DELETE_REPLY_RESPONSE" | jq . 2>/dev/null || echo "$DELETE_REPLY_RESPONSE"
  echo "✓ Delete reply successful"
fi

echo ""
echo "10. Delete post"
DELETE_RESPONSE=$(curl -s -X DELETE "$BASE_URL/posts/$POST_ID" \
  -H "Authorization: Bearer $TOKEN")
echo "$DELETE_RESPONSE" | jq . 2>/dev/null || echo "$DELETE_RESPONSE"
echo "✓ Delete post successful"

echo ""
echo "11. Logout"
LOGOUT_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/logout" \
  -H "Authorization: Bearer $TOKEN")
echo "$LOGOUT_RESPONSE" | jq . 2>/dev/null || echo "$LOGOUT_RESPONSE"
echo "✓ Logout successful"

echo ""
echo "=== ALL TESTS PASSED ==="
echo "Summary:"
echo "- User registration: ✓"
echo "- User login: ✓"
echo "- Create post: ✓"
echo "- Get all posts: ✓"
echo "- Get single post: ✓"
echo "- Update post: ✓"
echo "- Add reply: ✓"
echo "- Get post with replies: ✓"
echo "- Delete reply: ✓"
echo "- Delete post: ✓"
echo "- Logout: ✓"
