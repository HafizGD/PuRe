# Android Activities Documentation

Dokumentasi untuk semua Activity Android yang dibuat berdasarkan mockup Figma.

## Activities yang Tersedia

### 1. HomepageActivity
- **Layout**: `activity_homepage.xml`
- **Deskripsi**: Halaman utama dengan hero section, title "PuRe", subtitle, dan dua tombol
- **Navigasi**: Tombol mengarah ke MainMenuActivity

### 2. MainMenuActivity
- **Layout**: `activity_main_menu.xml`
- **Deskripsi**: Menu utama dengan:
  - Title dan subtitle
  - Search box
  - "Want to know more?" section
  - Trending News section dengan news items
- **Navigasi**: 
  - News items → MainNewsActivity
  - Bottom nav puzzle button → PuzzleActivity
  - Bottom nav menu button → BookshelfActivity

### 3. PuzzleActivity
- **Layout**: `activity_puzzle.xml`
- **Deskripsi**: Halaman puzzle dengan grid 3x3 untuk menyelesaikan puzzle
- **Navigasi**: Bottom navigation bar

### 4. MainNewsActivity
- **Layout**: `activity_main_news.xml`
- **Deskripsi**: Halaman detail berita dengan:
  - Header image
  - News title
  - News content (paragraf)
  - Bookmark icon
  - Globe icon
- **Navigasi**: Bottom navigation bar

### 5. BookshelfActivity
- **Layout**: `activity_bookshelf.xml`
- **Deskripsi**: Halaman bookshelf dengan:
  - Title "PuRe"
  - Bookmarks section (clickable)
  - Recent Opened News section (clickable)
- **Navigasi**: 
  - Bookmarks section → BookmarksActivity
  - Recent section → RecentActivity
  - Bottom navigation bar

### 6. BookmarksActivity
- **Layout**: `activity_bookmarks.xml`
- **Deskripsi**: Daftar bookmark dengan news items yang sudah di-bookmark
- **Navigasi**: 
  - News items → MainNewsActivity
  - Bookmark icon → Remove bookmark
  - Bottom navigation bar

### 7. RecentActivity
- **Layout**: `activity_recent.xml`
- **Deskripsi**: Daftar berita yang baru dibuka
- **Navigasi**: 
  - News items → MainNewsActivity
  - Bookmark icon → Toggle bookmark
  - Bottom navigation bar

## Bottom Navigation Bar

Semua activity (kecuali HomepageActivity) memiliki bottom navigation bar dengan:
- **Back Button**: Kembali ke activity sebelumnya
- **Puzzle Button**: Navigate ke PuzzleActivity
- **Menu Button**: Navigate ke BookshelfActivity
- **PuRe Text**: Branding text

## Resources

### Colors (`values/colors.xml`)
- `white`: #FFFFFF
- `background_gray`: #F5F5F5
- `dark_gray`: #2C2C2C
- `light_gray`: #D9D9D9
- `text_primary`: #1E1E1E
- `text_secondary`: #757575
- `icon_gray`: #E6E6E6
- `button_gray`: #E3E3E3

### Dimensions (`values/dimens.xml`)
- Padding dan margin values
- Corner radius
- Bottom navigation bar dimensions

### Drawables
- `button_gray_background.xml`
- `button_dark_background.xml`
- `card_background.xml`
- `white_card_background.xml`
- `dark_card_background.xml`
- `circle_background.xml`

## Cara Menggunakan

### Menjalankan dari MainActivity (Flutter)
MainActivity adalah FlutterActivity. Untuk menggunakan native Android activities, uncomment baris di MainActivity.kt:

```kotlin
startActivity(Intent(this, HomepageActivity::class.java))
```

### Menjalankan Langsung dari HomepageActivity
Untuk menjadikan HomepageActivity sebagai launcher activity, update AndroidManifest.xml:

```xml
<activity
    android:name=".HomepageActivity"
    android:exported="true"
    ...>
    <intent-filter>
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
    </intent-filter>
</activity>
```

## Catatan

- Semua activity menggunakan theme `LaunchTheme`
- Layout dirancang untuk screen width 411px (sesuai mockup Figma)
- Semua activity mendukung bottom navigation bar (kecuali HomepageActivity)
- Bookmark functionality sudah diimplementasikan dengan toggle state

