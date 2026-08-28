# PuRe News System API

File-file PHP ini digunakan sebagai backend API untuk aplikasi Flutter PuRe.

## Lokasi File
Semua file PHP berada di: `C:\xampp\htdocs\news\`

## Instalasi

1. ✅ File PHP sudah ada di `C:\xampp\htdocs\news\`
2. Pastikan database `news_system` sudah dibuat dan diimport dari `news_system.sql`
   - Buka phpMyAdmin: http://localhost/phpmyadmin
   - Import file `news_system.sql` dari folder database project
3. Edit file `db_config.php` dan sesuaikan konfigurasi database jika perlu:
   ```php
   $host = 'localhost';
   $dbname = 'news_system';
   $username = 'root';
   $password = ''; // Sesuaikan dengan password MySQL Anda jika ada
   ```
4. Pastikan XAMPP Apache dan MySQL sudah running

## Testing API

Setelah XAMPP running, test API dengan browser atau Postman:

### Test Register
URL: `http://localhost/news/register.php`
Method: POST
Body (JSON):
```json
{
  "username": "testuser",
  "password": "test123"
}
```

### Test Login
URL: `http://localhost/news/login.php`
Method: POST
Body (JSON):
```json
{
  "username": "testuser",
  "password": "test123"
}
```

## Endpoints

Base URL: `http://localhost/news/`

### 1. Register User
- **URL**: `POST /register.php`
- **Body**:
  ```json
  {
    "username": "string",
    "password": "string"
  }
  ```

### 2. Login User
- **URL**: `POST /login.php`
- **Body**:
  ```json
  {
    "username": "string",
    "password": "string"
  }
  ```

### 3. Bookmark News
- **Get Bookmarks**: `GET /bookmark.php?user_id=1`
- **Add Bookmark**: `POST /bookmark.php`
  ```json
  {
    "action": "add",
    "user_id": 1,
    "link": "https://news.com/article"
  }
  ```
- **Remove Bookmark**: `POST /bookmark.php`
  ```json
  {
    "action": "remove",
    "user_id": 1,
    "link": "https://news.com/article"
  }
  ```

### 4. Recent News
- **Get Recent**: `GET /recent.php`
- **Add Recent**: `POST /recent.php`
  ```json
  {
    "action": "add",
    "link": "https://news.com/article"
  }
  ```

### 5. Validate News
- **Get Validation**: `GET /validate.php?link=https://news.com/article`
- **Add Validation**: `POST /validate.php`
  ```json
  {
    "action": "validate",
    "link": "https://news.com/article",
    "is_valid": 1
  }
  ```
  - `is_valid`: 1 untuk Valid, 0 untuk Hoax

## Konfigurasi Flutter

Di file `lib/services/database_service.dart`, ganti `baseUrl` dengan:
```dart
static const String baseUrl = 'http://10.0.2.2/news'; // Untuk Android Emulator
// atau
static const String baseUrl = 'http://localhost/news'; // Untuk web
// atau
static const String baseUrl = 'http://YOUR_IP_ADDRESS/news'; // Untuk device fisik
```

## File yang Tersedia

- `db_config.php` - Konfigurasi database
- `register.php` - API registrasi user
- `login.php` - API login user
- `bookmark.php` - API bookmark news
- `recent.php` - API recent news
- `validate.php` - API validasi berita
- `.htaccess` - Konfigurasi CORS dan PHP

## Catatan Penting

- Pastikan XAMPP Apache dan MySQL sudah running
- Pastikan database `news_system` sudah dibuat dan diimport
- Untuk production, ganti `Access-Control-Allow-Origin: *` dengan domain spesifik di `.htaccess`
- Semua password di-hash menggunakan `password_hash()` untuk keamanan


