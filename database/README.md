# PuRe News System API

File-file PHP ini digunakan sebagai backend API untuk aplikasi Flutter PuRe.

## Instalasi

1. Copy semua file di folder ini ke `C:\xampp\htdocs\pure-api\` (atau folder lain di htdocs)
2. Pastikan database `news_system` sudah dibuat dan diimport dari `news_system.sql`
3. Edit file `db_config.php` dan sesuaikan konfigurasi database:
   ```php
   $host = 'localhost';
   $dbname = 'news_system';
   $username = 'root';
   $password = ''; // Sesuaikan dengan password MySQL Anda
   ```

## Endpoints

### 1. Register User
- **URL**: `POST /register.php`
- **Body**:
  ```json
  {
    "username": "string",
    "password": "string"
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "message": "Registrasi berhasil",
    "user_id": 1,
    "username": "string"
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
- **Response**:
  ```json
  {
    "success": true,
    "message": "Login berhasil",
    "user_id": 1,
    "username": "string"
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
static const String baseUrl = 'http://10.0.2.2/pure-api'; // Untuk Android Emulator
// atau
static const String baseUrl = 'http://localhost/pure-api'; // Untuk web
// atau
static const String baseUrl = 'http://YOUR_IP_ADDRESS/pure-api'; // Untuk device fisik
```

## Testing

Gunakan Postman atau curl untuk test API:

```bash
# Test Register
curl -X POST http://localhost/pure-api/register.php \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"test123"}'

# Test Login
curl -X POST http://localhost/pure-api/login.php \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"test123"}'
```

## Catatan

- Pastikan XAMPP sudah running (Apache dan MySQL)
- Pastikan database `news_system` sudah dibuat
- Pastikan semua file PHP memiliki permission yang tepat
- Untuk production, ganti `Access-Control-Allow-Origin: *` dengan domain spesifik








