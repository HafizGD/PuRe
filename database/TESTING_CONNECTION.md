# Testing Koneksi Database Flutter dengan PHP API

## Langkah-langkah Testing

### 1. Pastikan XAMPP Running
- Buka XAMPP Control Panel
- Start **Apache** dan **MySQL**
- Pastikan keduanya berstatus "Running" (hijau)

### 2. Import Database
- Buka phpMyAdmin: http://localhost/phpmyadmin
- Buat database baru atau gunakan database `news_system`
- Import file `news_system.sql` dari folder database

### 3. Konfigurasi URL di Flutter

Edit file `lib/services/database_service.dart`:

```dart
static const String baseUrl = 'http://10.0.2.2/news'; // Android Emulator
// atau
static const String baseUrl = 'http://localhost/news'; // Web
// atau
static const String baseUrl = 'http://YOUR_IP_ADDRESS/news'; // Device fisik
```

**Catatan:**
- **Android Emulator**: Gunakan `http://10.0.2.2/news` (10.0.2.2 adalah alias untuk localhost di emulator)
- **Web**: Gunakan `http://localhost/news`
- **Device Fisik**: 
  1. Cari IP address komputer Anda (ipconfig di CMD)
  2. Pastikan device dan komputer dalam jaringan WiFi yang sama
  3. Gunakan `http://YOUR_IP/news` (contoh: `http://192.168.1.100/news`)

### 4. Test Koneksi dari Flutter

1. Jalankan aplikasi Flutter
2. Di login screen, klik tombol **"Test Koneksi DB"** (di bawah tombol Guest)
3. Jika berhasil, akan muncul notifikasi hijau: "Koneksi ke database berhasil!"
4. Jika gagal, akan muncul notifikasi merah dengan pesan error

### 5. Test Manual dengan Browser

Buka browser dan test endpoint:

- **Register**: http://localhost/news/register.php
  - Method: POST
  - Body: `{"username":"test","password":"test123"}`
  
- **Login**: http://localhost/news/login.php
  - Method: POST
  - Body: `{"username":"test","password":"test123"}`

### 6. Troubleshooting

#### Error: "Connection refused" atau "Failed to connect"
- Pastikan XAMPP Apache sudah running
- Pastikan URL di `database_service.dart` sudah benar
- Untuk device fisik, pastikan firewall tidak memblokir port 80

#### Error: "Database connection failed"
- Pastikan MySQL sudah running di XAMPP
- Pastikan database `news_system` sudah dibuat dan diimport
- Cek konfigurasi di `db_config.php` (password MySQL jika ada)

#### Error: "Username atau password salah"
- Pastikan user sudah terdaftar di database
- Test dengan register dulu, baru login

#### Error: "HTTP 404" atau "File not found"
- Pastikan file PHP sudah ada di `C:\xampp\htdocs\news\`
- Pastikan nama file benar (register.php, login.php, dll)

### 7. Test dengan Postman (Opsional)

1. Install Postman
2. Buat request baru:
   - Method: POST
   - URL: http://localhost/news/register.php
   - Headers: `Content-Type: application/json`
   - Body (raw JSON):
     ```json
     {
       "username": "testuser",
       "password": "test123"
     }
     ```
3. Klik Send
4. Jika berhasil, akan dapat response:
   ```json
   {
     "success": true,
     "message": "Registrasi berhasil",
     "user_id": 1,
     "username": "testuser"
   }
   ```

## Checklist Testing

- [ ] XAMPP Apache running
- [ ] XAMPP MySQL running
- [ ] Database `news_system` sudah diimport
- [ ] File PHP ada di `C:\xampp\htdocs\news\`
- [ ] URL di `database_service.dart` sudah benar
- [ ] Test koneksi dari Flutter berhasil
- [ ] Register user berhasil
- [ ] Login user berhasil

## Catatan Penting

1. **Android Emulator**: Selalu gunakan `10.0.2.2` bukan `localhost`
2. **Device Fisik**: Pastikan komputer dan device dalam WiFi yang sama
3. **Firewall**: Pastikan firewall tidak memblokir koneksi
4. **Port**: Pastikan port 80 (HTTP) tidak digunakan aplikasi lain








