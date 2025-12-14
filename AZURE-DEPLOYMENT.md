# Azure Deployment Checklist

## Current Status
- ❌ Containers NOT running on Azure VM
- ✅ Code exists at: azureuser@fairuzfd:~/fp_cc/FP

## Quick Fix (Run on Azure VM)

```bash
# SSH ke Azure
ssh azureuser@20.2.83.176

# Navigate to project
cd ~/fp_cc/FP

# Pull latest code
git pull origin main

# Start containers
docker compose up -d

# Wait 30 seconds
sleep 30

# Check status
docker compose ps

# Test backend
curl http://localhost:5001/api

# Check logs if needed
docker compose logs backend --tail 50
```

## Azure Network Security Group (NSG) Rules

**MUST configure these ports in Azure Portal:**

1. Go to: Azure Portal → Virtual Machines → fairuzfd → Networking → Add inbound port rule

| Port | Protocol | Name | Priority |
|------|----------|------|----------|
| 80 | TCP | Allow-HTTP | 100 |
| 5001 | TCP | Allow-Backend-API | 110 |
| 443 | TCP | Allow-HTTPS | 120 |
| 22 | TCP | Allow-SSH | 130 |

**DO NOT expose PostgreSQL (5432) to public!**

## Access URLs (After NSG configured)

- **Frontend**: http://20.2.83.176:80
- **Backend API**: http://20.2.83.176:5001/api
- **SSH**: ssh azureuser@20.2.83.176

## Troubleshooting

### If `curl: (7) Failed to connect`
1. Containers not running → Run `docker compose up -d`
2. Ports not exposed → Check NSG rules
3. Backend crashed → Check `docker compose logs backend`

### If CORS error in browser
- Frontend needs to call: `http://20.2.83.176:5001/api`
- NOT: `http://localhost:5001/api`
- Update NEXT_PUBLIC_API_URL in docker-compose.yml for Azure

### If "Removed" appears
- Normal! It means old containers were stopped
- Just run `docker compose up -d` again
