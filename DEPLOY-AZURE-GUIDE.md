# 🚀 CARA DEPLOY KE AZURE (Step-by-Step)

## ✅ Jawaban Pertanyaan Anda

**Q: Apa maksud "Removed"?**
A: **Normal!** Artinya container lama berhasil dihentikan sebelum rebuild. Bukan error.

**Q: Kenapa `curl: (7) Failed to connect`?**
A: Containers **BELUM running** di Azure VM. Anda perlu jalankan `docker compose up -d` dulu.

**Q: Apakah CORS bermasalah?**
A: Sudah diperbaiki! Sekarang backend allow CORS dari IP Azure (20.2.83.176).

---

## 📋 Step 1: Push Code ke GitHub

```bash
# Di local machine (laptop/PC Anda)
cd /home/frid/cc/fpcc/FP-PBKK

git add .
git commit -m "Fix CORS, ports, and Azure deployment"
git push origin main
```

---

## 📋 Step 2: SSH ke Azure VM

```bash
ssh azureuser@20.2.83.176
```

---

## 📋 Step 3: Pull Latest Code & Deploy

```bash
# Setelah SSH ke Azure
cd ~/fp_cc/FP

# Pull latest code
git pull origin main

# Make scripts executable
chmod +x start-azure.sh

# Run deployment
bash start-azure.sh
```

**Script akan otomatis:**
1. ✅ Stop old containers
2. ✅ Build new containers
3. ✅ Start all services
4. ✅ Test backend API
5. ✅ Show logs

---

## 📋 Step 4: Configure Azure Network Security Group (NSG)

**WAJIB! Tanpa ini, website tidak bisa diakses dari internet.**

### Via Azure Portal:

1. Login ke **Azure Portal** (portal.azure.com)
2. Go to: **Virtual Machines** → **fairuzfd** (nama VM Anda)
3. Klik **Networking** di sidebar kiri
4. Klik **Add inbound port rule**

**Tambahkan 2 rules ini:**

#### Rule 1: Allow HTTP (Port 80 - Frontend)
- **Source**: Any
- **Source port ranges**: *
- **Destination**: Any
- **Service**: HTTP
- **Destination port ranges**: 80
- **Protocol**: TCP
- **Action**: Allow
- **Priority**: 100
- **Name**: Allow-Frontend-HTTP

#### Rule 2: Allow Backend API (Port 5001)
- **Source**: Any
- **Source port ranges**: *
- **Destination**: Any
- **Service**: Custom
- **Destination port ranges**: 5001
- **Protocol**: TCP
- **Action**: Allow
- **Priority**: 110
- **Name**: Allow-Backend-API

### Via Azure CLI (alternatif):

```bash
# Allow port 80 (Frontend)
az network nsg rule create \
  --resource-group <your-resource-group> \
  --nsg-name <your-nsg-name> \
  --name Allow-Frontend-HTTP \
  --priority 100 \
  --destination-port-ranges 80 \
  --access Allow \
  --protocol Tcp

# Allow port 5001 (Backend API)
az network nsg rule create \
  --resource-group <your-resource-group> \
  --nsg-name <your-nsg-name> \
  --name Allow-Backend-API \
  --priority 110 \
  --destination-port-ranges 5001 \
  --access Allow \
  --protocol Tcp
```

---

## 📋 Step 5: Test Deployment

### From Azure VM (via SSH):

```bash
# Test backend locally
curl http://localhost:5001/api

# Test frontend locally
curl http://localhost:80
```

### From Your Browser:

1. **Frontend**: http://20.2.83.176:80
2. **Backend API**: http://20.2.83.176:5001/api

---

## 🔧 Troubleshooting

### Problem: `curl: (7) Failed to connect to localhost port 5001`

**Solution:**
```bash
# Check if containers are running
docker compose ps

# If not running, start them
docker compose up -d

# Check logs
docker compose logs backend --tail 50
```

### Problem: Can't access from browser but `curl localhost:80` works on VM

**Solution:** Azure NSG rules belum dikonfigurasi. Lihat Step 4.

### Problem: "CORS policy" error in browser console

**Solution:** Already fixed! Backend now allows requests from `20.2.83.176`.

### Problem: Containers keep restarting

**Solution:**
```bash
# Check what's wrong
docker compose logs backend --tail 100

# Common issues:
# - Prisma binary target mismatch → Already fixed (debian-openssl-3.0.x)
# - Port already in use → Change ports in docker-compose.yml
# - Out of memory → Check `docker stats`
```

---

## 📝 Useful Commands

```bash
# Check container status
docker compose ps

# View logs (follow mode)
docker compose logs -f backend
docker compose logs -f frontend

# Restart specific service
docker compose restart backend

# Stop all containers
docker compose down

# Rebuild and restart
docker compose up -d --build

# Remove everything and start fresh
docker compose down -v
docker compose up -d --build
```

---

## 🎯 Expected Result

After completing all steps:

✅ **Frontend** accessible at: http://20.2.83.176:80
✅ **Backend API** accessible at: http://20.2.83.176:5001/api
✅ Login/Register works without CORS errors
✅ All containers healthy: `docker compose ps` shows "Up" status

---

## 🔒 Security Notes

1. ✅ PostgreSQL (port 5432) is **NOT** exposed to internet (internal only)
2. ⚠️ Change `JWT_SECRET` in `.env.azure` untuk production
3. ⚠️ Use HTTPS in production (install SSL certificate)
4. ⚠️ Limit SSH access via Azure NSG (only your IP)

---

## 📞 Next Steps

Setelah deployment berhasil:
1. Test login/register di http://20.2.83.176:80
2. Setup SSL certificate (Let's Encrypt + Nginx reverse proxy)
3. Configure custom domain
4. Setup automated backup untuk database
5. Configure monitoring & alerts
