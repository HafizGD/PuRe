# Testing Flutter Web dengan Database

## Masalah yang Sering Terjadi

### Error: "Failed to fetch" di Flutter Web

**Penyebab:**
- URL `10.0.2.2` hanya untuk Android emulator
- Flutter web perlu menggunakan `localhost`

**Solusi:**
✅ Sudah diperbaiki! `database_service.dart` sekarang otomatis menggunakan:
- `http://localhost/news` untuk web
- `http://10.0.2.2/news` untuk Android emulator

## Langkah Testing

### 1. Pastikan XAMPP Running
- Buka XAMPP Control Panel
- Start **Apache** dan **MySQL**
- Status harus "Running" (hijau)

### 2. Test API di Browser
Buka browser dan test:
- **Test Connection**: http://localhost/news/test.php
  - Harus menampilkan JSON dengan info database
  
- **Register (akan error karena GET)**: http://localhost/news/register.php
  - Harus menampilkan: `{"success":false,"message":"Method not allowed"}`
  - Ini normal! Berarti file PHP bisa diakses

### 3. Restart Flutter Web
**PENTING:** Setelah mengubah `database_service.dart`, lakukan:

```bash
# Stop aplikasi (Ctrl+C)
# Kemudian restart
flutter run -d chrome
# atau
flutter run -d web-server
```

**Jangan hanya hot reload!** Perlu **hot restart** atau **full restart**.

### 4. Test dari Flutter Web
1. Buka aplikasi di browser
2. Klik tombol **"Test Koneksi DB"** di login screen
3. Jika berhasil, akan muncul notifikasi hijau

## Troubleshooting

### Masih Error "Failed to fetch"?

#### 1. Cek Browser Console
- Buka Developer Tools (F12)
- Tab **Console** dan **Network**
- Lihat error detail

#### 2. Cek CORS
Di browser console, jika ada error CORS:
- Pastikan `.htaccess` ada di `C:\xampp\htdocs\news\`
- Pastikan Apache mod_headers enabled

#### 3. Test dengan curl/Postman
```bash
# Test POST request
curl -X POST http://localhost/news/register.php \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"test123"}'
```

#### 4. Cek Port
- Pastikan Apache menggunakan port 80
- Jika port lain, ubah URL: `http://localhost:PORT/news`

#### 5. Clear Browser Cache
- Tekan Ctrl+Shift+Delete
- Clear cache dan cookies
- Restart browser

### Error: "Connection refused"

**Penyebab:** XAMPP Apache tidak running

**Solusi:**
1. Buka XAMPP Control Panel
2. Start Apache
3. Test di browser: http://localhost/news/test.php

### Error: "Database connection failed"

**Penyebab:** MySQL tidak running atau database belum diimport

**Solusi:**
1. Start MySQL di XAMPP
2. Import `news_system.sql` ke phpMyAdmin
3. Test: http://localhost/news/test.php

## Checklist

- [ ] XAMPP Apache running
- [ ] XAMPP MySQL running
- [ ] Database `news_system` sudah diimport
- [ ] File PHP ada di `C:\xampp\htdocs\news\`
- [ ] Test http://localhost/news/test.php berhasil
- [ ] Flutter web sudah di-restart (bukan hanya hot reload)
- [ ] Browser cache sudah di-clear

## Catatan Penting

1. **Flutter Web** menggunakan `http://localhost/news`
2. **Android Emulator** menggunakan `http://10.0.2.2/news`
3. **Device Fisik** menggunakan `http://YOUR_IP/news`
4. Setelah mengubah `database_service.dart`, **harus restart** aplikasi (bukan hot reload)








