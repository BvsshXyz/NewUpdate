#!/bin/bash

# Konfigurasi
GITHUB_REPO="https://github.com/BvsshXyz/NewUpdate.git"  # Ganti dengan repo GitHub kamu
TELEGRAM_BOT_TOKEN="6694391135:AAEpl43B6WqG6yND1WoIYYyJRn"                   # Ganti dengan token bot Telegram
TELEGRAM_CHAT_ID="6648546911"                       # Ganti dengan chat ID Telegram

# Buat direktori backup
BACKUP_DIR="/backup"
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p $BACKUP_DIR
fi

# Buat file auto-backup script
BACKUP_SCRIPT="$BACKUP_DIR/autobackup.sh"

cat << 'EOF' > $BACKUP_SCRIPT
#!/bin/bash

# Konfigurasi
GITHUB_REPO="https://github.com/BvsshXyz/NewUpdate.git"  # Ganti dengan repo GitHub kamu
TELEGRAM_BOT_TOKEN="6694391135:AAEpl43B6WqG6yND1WoIYYyJRn"                   # Ganti dengan token bot Telegram
TELEGRAM_CHAT_ID="6648546911"                       # Ganti dengan chat ID Telegram

# Lokasi direktori backup
BACKUP_DIR="/backup"
BACKUP_FILE="$BACKUP_DIR/backup-$(date +'%Y-%m-%d').tar.gz"

# Backup akun SSH, VMess, VLESS, Trojan, OpenVPN, dll
echo "Membuat backup..."
tar -czf $BACKUP_FILE /etc/ssh /etc/v2ray /etc/trojan-go /etc/xray /etc/openvpn

# Backup semua akun di VPS
echo "Membackup semua akun di VPS..."
getent passwd | awk -F: '{print $1}' > $BACKUP_DIR/user_accounts.txt

# Tambahkan file user_accounts.txt ke dalam backup
tar -czf $BACKUP_FILE -C $BACKUP_DIR user_accounts.txt --append

# Upload backup ke GitHub
echo "Mengupload backup ke GitHub..."
cd $BACKUP_DIR
git init
git remote add origin $GITHUB_REPO
git add $BACKUP_FILE user_accounts.txt
git commit -m "Auto backup $(date)"

# Push ke branch main di GitHub
git push -u origin main --force  # Pastikan branch yang dituju adalah 'main'

# Mengirim notifikasi ke Telegram
echo "Mengirim notifikasi ke Telegram..."
curl -s -X POST https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage -d chat_id=$TELEGRAM_CHAT_ID -d text="Backup berhasil: $(date) - File: $BACKUP_FILE"

echo "Proses selesai."
EOF

# Berikan izin eksekusi untuk backup script
chmod +x $BACKUP_SCRIPT

# Tambahkan cron job untuk menjalankan backup otomatis
CRON_JOB="0 0 * * * $BACKUP_SCRIPT > /dev/null 2>&1"
(crontab -l; echo "$CRON_JOB") | crontab -

echo "Instalasi dan pengaturan auto-backup selesai."
