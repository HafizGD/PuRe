# API Integration & Puzzle Mechanism

## API Integration

### World News API
- **Endpoint**: `https://api.worldnewsapi.com/search-news?source-countries=id&number=50`
- **API Key**: `d77b07cbb1d44ce39c2a19c614e63ccf`
- **Method**: GET dengan header `x-api-key`
- **Response**: JSON dengan array `news` yang berisi artikel berita

### Dependencies
- **OkHttp 4.12.0**: Untuk HTTP requests
- **Glide 4.16.0**: Untuk loading dan caching gambar
- **Material Design Components 1.11.0**: Untuk FloatingActionButton

## Puzzle Mechanism

### PuzzleActivity Features

1. **Fetch News from API**
   - Mengambil 50 berita dari Indonesia
   - Memilih berita acak yang memiliki gambar
   - Maksimal 10 percobaan untuk mencari berita dengan gambar

2. **Puzzle Creation**
   - Gambar di-crop menjadi square
   - Dibagi menjadi 3x3 grid (9 pieces)
   - Piece terakhir (index 8) adalah empty space
   - Setiap piece memiliki number hint (1-8)

3. **Puzzle Shuffling**
   - Generate solvable puzzle state
   - Shuffle dengan 100+ moves untuk memastikan puzzle bisa diselesaikan
   - Memastikan puzzle tidak dalam state solved

4. **Puzzle Solving**
   - User bisa click piece untuk memindahkannya
   - Piece hanya bisa dipindah jika adjacent dengan empty space
   - Ketika puzzle solved, otomatis navigate ke MainNewsActivity

5. **Controls**
   - **Skip Button**: Langsung ke MainNewsActivity tanpa menyelesaikan puzzle
   - **Reset Button**: Fetch berita baru dan buat puzzle baru

### Data Flow

```
PuzzleActivity
    ↓ (fetchNewsImage)
World News API
    ↓ (response)
Parse JSON → Get random article with image
    ↓ (Glide load image)
Create Puzzle (3x3 grid)
    ↓ (user solves or skips)
MainNewsActivity (with title, description, imageUrl)
```

## MainNewsActivity

### Data Display
- **Title**: Dari Intent extra "title"
- **Description**: Dari Intent extra "description" (dibagi menjadi 2 paragraf)
- **Image**: Dari Intent extra "imageUrl" (loaded dengan Glide)

### Features
- Bookmark toggle functionality
- Bottom navigation bar
- Display news content

## Permissions

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

## Error Handling

- Network failures: Toast message "Gagal ambil berita"
- No image found: Toast message "Gagal menemukan berita dengan gambar"
- JSON parsing errors: Toast message "Error parsing JSON"
- Empty response: Toast message "Response body kosong"

## Notes

- Puzzle menggunakan solvable state generation untuk memastikan puzzle bisa diselesaikan
- Glide cache di-clear saat reset untuk memastikan gambar baru di-load
- Puzzle state disimpan dalam ArrayList untuk easy manipulation
- Number hints membantu user mengetahui urutan yang benar

