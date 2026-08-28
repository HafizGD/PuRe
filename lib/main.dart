import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/homepage_screen.dart';
import 'screens/main_menu_screen.dart';
import 'screens/puzzle_screen.dart';
import 'screens/news_detail_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/bookshelf_screen.dart';
import 'screens/bookmarks_screen.dart';
import 'screens/recent_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'models/news.dart';
import 'services/database_service.dart';
import 'services/news_api_service.dart' as news_api;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (error) {
    debugPrint('Environment file could not be loaded: $error');
  }
  await AppPreferences.init();
  runApp(const PureApp());
}

// === SERVICES ===
class AppPreferences {
  static late SharedPreferences _prefs;
  static int? _currentUserId; // Store current user ID from database
  static String? _currentUsername; // Store current username

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // Load current user info if logged in
    _currentUserId = _prefs.getInt('current_user_id');
    _currentUsername = _prefs.getString('current_username');
  }

  // Bookmark methods - Updated to use database
  static Future<bool> addBookmark(News news) async {
    // Check if already bookmarked (check both local storage and database)
    final bookmarks = _prefs.getStringList('bookmarks') ?? [];
    final alreadyBookmarked = bookmarks.any((jsonStr) {
      try {
        final n = News.fromJson(json.decode(jsonStr));
        return n.link == news.link;
      } catch (e) {
        return false;
      }
    });
    
    if (alreadyBookmarked) {
      return false; // Already bookmarked
    }
    
    // If user is logged in, save to database FIRST (priority)
    if (_currentUserId != null) {
      final dbSuccess = await DatabaseService.addBookmark(_currentUserId!, news);
      if (!dbSuccess) {
        // If database fails, still save to local storage as backup
        final newsJson = json.encode(news.toJson());
        bookmarks.add(newsJson);
        await _prefs.setStringList('bookmarks', bookmarks);
        return true; // Saved to local storage as backup
      }
      // Database save successful, also save to local storage for quick access
      final newsJson = json.encode(news.toJson());
      bookmarks.add(newsJson);
      await _prefs.setStringList('bookmarks', bookmarks);
      return true; // Successfully saved to database and local storage
    } else {
      // User not logged in, save to local storage only
      final newsJson = json.encode(news.toJson());
      bookmarks.add(newsJson);
      await _prefs.setStringList('bookmarks', bookmarks);
      return true; // Saved to local storage (will sync to database when user logs in)
    }
  }

  static Future<void> removeBookmark(String link) async {
    // If user is logged in, remove from database FIRST (priority)
    if (_currentUserId != null) {
      await DatabaseService.removeBookmark(_currentUserId!, link);
      // Also remove from local storage
      final bookmarks = _prefs.getStringList('bookmarks') ?? [];
      bookmarks.removeWhere((jsonStr) {
        try {
          final news = News.fromJson(json.decode(jsonStr));
          return news.link == link;
        } catch (e) {
          return false;
        }
      });
      await _prefs.setStringList('bookmarks', bookmarks);
    } else {
      // User not logged in, remove from local storage only
      final bookmarks = _prefs.getStringList('bookmarks') ?? [];
      bookmarks.removeWhere((jsonStr) {
        try {
          final news = News.fromJson(json.decode(jsonStr));
          return news.link == link;
        } catch (e) {
          return false;
        }
      });
      await _prefs.setStringList('bookmarks', bookmarks);
    }
  }

  static Future<List<News>> getBookmarks() async {
    // If logged in, get from database FIRST (source of truth with full News data)
    if (_currentUserId != null) {
      try {
        // Get full News objects from database
        final dbBookmarks = await DatabaseService.getBookmarks(_currentUserId!);
        
        // Update local storage with complete News objects from database
        final updatedBookmarks = <String>[];
        for (final news in dbBookmarks) {
          updatedBookmarks.add(json.encode(news.toJson()));
        }
        await _prefs.setStringList('bookmarks', updatedBookmarks);
        
        return dbBookmarks;
      } catch (e) {
        // If database fails, fallback to local storage
        final localBookmarks = _prefs.getStringList('bookmarks') ?? [];
        final newsList = <News>[];
        for (final jsonStr in localBookmarks) {
          try {
            final news = News.fromJson(json.decode(jsonStr));
            newsList.add(news);
          } catch (e) {
            // Skip invalid entries
          }
        }
        return newsList;
      }
    } else {
      // User not logged in, get from local storage only
      final localBookmarks = _prefs.getStringList('bookmarks') ?? [];
      final newsList = <News>[];
      for (final jsonStr in localBookmarks) {
        try {
          final news = News.fromJson(json.decode(jsonStr));
          newsList.add(news);
        } catch (e) {
          // Skip invalid entries
        }
      }
      return newsList;
    }
  }
  
  // Sync local bookmarks to database when user logs in
  static Future<void> syncBookmarksToDatabase() async {
    if (_currentUserId == null) return;
    
    try {
      // Get all bookmarks from local storage (with full News objects)
      final localBookmarks = _prefs.getStringList('bookmarks') ?? [];
      final localNewsList = <News>[];
      
      for (final jsonStr in localBookmarks) {
        try {
          final news = News.fromJson(json.decode(jsonStr));
          localNewsList.add(news);
        } catch (e) {
          // Skip invalid entries
        }
      }
      
      // Get bookmarks from database (with full News objects)
      final dbBookmarks = await DatabaseService.getBookmarks(_currentUserId!);
      final dbLinks = dbBookmarks.map((n) => n.link).toList();
      
      // Add any local bookmarks that aren't in database
      for (final news in localNewsList) {
        if (!dbLinks.contains(news.link)) {
          await DatabaseService.addBookmark(_currentUserId!, news);
        }
      }
      
      // Update local storage with complete News objects from database
      // This ensures that even if local storage is cleared, we can restore from database
      final updatedBookmarks = <String>[];
      for (final news in dbBookmarks) {
        updatedBookmarks.add(json.encode(news.toJson()));
      }
      
      // Also add any local bookmarks that aren't in database yet
      for (final news in localNewsList) {
        if (!dbLinks.contains(news.link)) {
          updatedBookmarks.add(json.encode(news.toJson()));
        }
      }
      
      // Update local storage with complete News objects
      await _prefs.setStringList('bookmarks', updatedBookmarks);
    } catch (e) {
      // If sync fails, it's okay - bookmarks are still in local storage
    }
  }

  // Recent news methods - Updated to use database
  static Future<void> addRecent(News news) async {
    // If user is logged in, save to database FIRST (priority)
    if (_currentUserId != null) {
      final dbSuccess = await DatabaseService.addRecentNews(_currentUserId!, news);
      if (!dbSuccess) {
        // If database fails, still save to local storage as backup
        final recents = _prefs.getStringList('recents') ?? [];
        final newsJson = json.encode(news.toJson());
        if (!recents.contains(newsJson)) {
          recents.insert(0, newsJson);
          if (recents.length > 10) recents.removeLast();
          await _prefs.setStringList('recents', recents);
        }
        return; // Saved to local storage as backup
      }
      // Database save successful, also save to local storage for quick access
      final recents = _prefs.getStringList('recents') ?? [];
      final newsJson = json.encode(news.toJson());
      if (!recents.contains(newsJson)) {
        recents.insert(0, newsJson);
        if (recents.length > 10) recents.removeLast();
        await _prefs.setStringList('recents', recents);
      }
    } else {
      // User not logged in, save to local storage only
      final recents = _prefs.getStringList('recents') ?? [];
      final newsJson = json.encode(news.toJson());
      if (!recents.contains(newsJson)) {
        recents.insert(0, newsJson);
        if (recents.length > 10) recents.removeLast();
        await _prefs.setStringList('recents', recents);
      }
    }
  }

  static Future<List<News>> getRecents() async {
    // If logged in, get from database FIRST (source of truth with full News data)
    if (_currentUserId != null) {
      try {
        // Get full News objects from database
        final dbRecents = await DatabaseService.getRecentNews(_currentUserId!);
        
        // Update local storage with complete News objects from database
        final updatedRecents = <String>[];
        for (final news in dbRecents) {
          updatedRecents.add(json.encode(news.toJson()));
        }
        await _prefs.setStringList('recents', updatedRecents);
        
        return dbRecents;
      } catch (e) {
        // If database fails, fallback to local storage
        final localRecents = _prefs.getStringList('recents') ?? [];
        final newsList = <News>[];
        for (final jsonStr in localRecents) {
          try {
            final news = News.fromJson(json.decode(jsonStr));
            newsList.add(news);
          } catch (e) {
            // Skip invalid entries
          }
        }
        return newsList;
      }
    } else {
      // User not logged in, get from local storage only
      final localRecents = _prefs.getStringList('recents') ?? [];
      final newsList = <News>[];
      for (final jsonStr in localRecents) {
        try {
          final news = News.fromJson(json.decode(jsonStr));
          newsList.add(news);
        } catch (e) {
          // Skip invalid entries
        }
      }
      return newsList;
    }
  }

  // News validation methods - New methods for database
  static Future<bool> validateNews(String link, bool isValid) async {
    // Only allow validation if user is logged in
    if (_currentUserId == null) {
      return false;
    }
    return await DatabaseService.validateNews(_currentUserId!, link, isValid);
  }

  static Future<Map<String, int>?> getNewsValidation(String link) async {
    final result = await DatabaseService.getNewsValidation(link);
    if (result != null) {
      return {
        'valid': result['jumlah_valid'] as int,
        'invalid': result['jumlah_tidak_valid'] as int,
      };
    }
    return null;
  }

  // Authentication methods - Updated to use database
  static Future<void> setLoggedIn(bool value, {int? userId, String? username}) async {
    await _prefs.setBool('isLoggedIn', value);
    if (value && userId != null && username != null) {
      _currentUserId = userId;
      _currentUsername = username;
      await _prefs.setInt('current_user_id', userId);
      await _prefs.setString('current_username', username);
    } else {
      _currentUserId = null;
      _currentUsername = null;
      await _prefs.remove('current_user_id');
      await _prefs.remove('current_username');
    }
  }

  static bool get isLoggedIn {
    return _prefs.getBool('isLoggedIn') ?? false;
  }

  static int? get currentUserId => _currentUserId;
  static String? get currentUsername => _currentUsername;

  static Future<void> clearLoginStatus() async {
    await _prefs.remove('isLoggedIn');
    await _prefs.remove('current_user_id');
    await _prefs.remove('current_username');
    _currentUserId = null;
    _currentUsername = null;
  }

  // User registration and login methods - Updated to use database
  static Future<Map<String, dynamic>> registerUser(String username, String password) async {
    final result = await DatabaseService.registerUser(username, password);
    if (result != null && result['success'] == true) {
      return {'success': true, 'message': result['message'] ?? 'Registrasi berhasil'};
    }
    return {'success': false, 'message': result?['message'] ?? 'Registrasi gagal'};
  }

  static Future<Map<String, dynamic>> validateLogin(String username, String password) async {
    try {
      final result = await DatabaseService.loginUser(username, password);
      if (result != null && result['success'] == true) {
        // Try to get user_id from different possible keys and formats
        dynamic userIdValue = result['user_id'] ?? result['userId'];
        int? userId;
        
        if (userIdValue != null) {
          if (userIdValue is int) {
            userId = userIdValue;
          } else if (userIdValue is num) {
            userId = userIdValue.toInt();
          } else if (userIdValue is String) {
            userId = int.tryParse(userIdValue);
          }
        }
        
        if (userId != null && userId > 0) {
          await setLoggedIn(true, userId: userId, username: username);
          return {'success': true, 'user_id': userId, 'message': 'Login berhasil'};
        } else {
          // If no valid user_id, still allow login but without database features
          await setLoggedIn(true, userId: null, username: username);
          return {'success': true, 'message': 'Login berhasil (tanpa user ID)'};
        }
      }
      return {'success': false, 'message': result?['message'] ?? 'Username atau password salah'};
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }
}

class PureApp extends StatelessWidget {
  const PureApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PuRe: Puzzle & Reasoning',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const RootScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({Key? key}) : super(key: key);

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  String _currentRoute = 'login'; // Changed from 'homepage' to 'login' - prevents homepage from being built
  News? _currentNews;
  List<News> _trendingNews = [];
  bool _isLoggedIn = false; // Added: Login state - always false at startup

  @override
  void initState() {
    super.initState();
    // Removed _loadTrendingNews() from here - only load after login
    // Reset login status to ensure login screen appears
    _resetAndShowLogin();
  }

  // Added: Reset login status at startup to ensure login screen appears
  Future<void> _resetAndShowLogin() async {
    await AppPreferences.clearLoginStatus();
    // No need to setState since _isLoggedIn is already false
  }

  // Added: Handle successful login
  Future<void> _handleLoginSuccess() async {
    // setLoggedIn sudah dipanggil di validateLogin dengan userId dan username
    // Sync bookmarks from local storage to database
    await AppPreferences.syncBookmarksToDatabase();
    // Load news after login
    _loadTrendingNews();
    setState(() {
      _isLoggedIn = true;
      _currentRoute = 'puzzle'; // Set to puzzle after login (random puzzle with hidden title)
      _currentNews = null; // Set null, PuzzleScreen akan fetch random news sendiri
    });
  }

  // Added: Handle guest login
  Future<void> _handleGuestLogin() async {
    // Guest login tidak punya userId, jadi set null
    await AppPreferences.setLoggedIn(true, userId: null, username: 'Guest');
    // Load news after guest login
    _loadTrendingNews();
    setState(() {
      _isLoggedIn = true;
      _currentRoute = 'puzzle'; // Set to puzzle after guest login (random puzzle with hidden title)
      _currentNews = null; // Set null, PuzzleScreen akan fetch random news sendiri
    });
  }

  Future<void> _loadTrendingNews() async {
    try {
      final news = await news_api.NewsApiService.fetchTopHeadlines();
      if (news.isNotEmpty) {
        setState(() {
          _trendingNews = news.take(10).toList();
        });
      } else {
        // If no news, try to keep existing or show empty
        setState(() {
          _trendingNews = [];
        });
      }
    } catch (e) {
      // On error, keep existing news if available, otherwise empty
      setState(() {
        // Keep existing _trendingNews if available
      });
    }
  }

  Future<void> _handlePuzzleFromHomepage() async {
    // Fetch random news langsung dari API
    setState(() {
      _currentRoute = 'puzzle';
      _currentNews = null; // Set null dulu, PuzzleScreen akan fetch sendiri
    });
  }

  void _handleHomeFromHomepage() {
    setState(() {
      _currentRoute = 'main_menu';
    });
  }

  void _handleNewsTap(News news) {
    setState(() {
      _currentNews = news;
      _currentRoute = 'news_detail';
    });
  }

  void _handlePuzzleForNews(News news) {
    setState(() {
      _currentNews = news;
      _currentRoute = 'puzzle';
    });
  }

  void _handleBookmark(News news) async {
    final bookmarks = await AppPreferences.getBookmarks();
    final isBookmarked = bookmarks.any((n) => n.link == news.link);
    if (isBookmarked) {
      await AppPreferences.removeBookmark(news.link);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bookmark dihapus'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      final success = await AppPreferences.addBookmark(news);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berita berhasil ditambahkan ke bookmark'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
    setState(() {});
  }

  Future<void> _handleBookmarkAndShow(News news) async {
    final bookmarks = await AppPreferences.getBookmarks();
    final alreadyBookmarked = bookmarks.any((n) => n.link == news.link);
    if (!alreadyBookmarked) {
      await AppPreferences.addBookmark(news);
    }
    setState(() {
      _currentNews = news;
      _currentRoute = 'bookmarks';
    });
  }

  void _handlePlayPuzzle() {
    if (_currentNews != null) {
      setState(() {
        _currentRoute = 'puzzle';
      });
    }
  }

  void _handlePuzzleComplete(News news) {
    setState(() {
      _currentNews = news;
      _currentRoute = 'news_detail';
    });
  }

  void _handleStartQuiz() {
    if (_currentNews != null) {
      setState(() {
        _currentRoute = 'quiz';
      });
    }
  }

  void _handleQuizFinished() {
    setState(() {
      _currentRoute = 'main_menu';
    });
  }

  void _handleBack() {
    if (_currentRoute == 'homepage') {
      // Can't go back from homepage
      return;
    } else if (_currentRoute == 'main_menu' || _currentRoute == 'puzzle') {
      setState(() {
        _currentRoute = 'homepage';
      });
    } else if (_currentRoute == 'news_detail') {
      setState(() {
        _currentRoute = 'main_menu';
      });
    } else if (_currentRoute == 'quiz') {
      setState(() {
        _currentRoute = 'news_detail';
      });
    } else if (_currentRoute == 'bookmarks' || _currentRoute == 'recent') {
      setState(() {
        _currentRoute = 'bookshelf';
      });
    } else if (_currentRoute == 'bookshelf') {
      setState(() {
        _currentRoute = 'main_menu';
      });
    }
  }

  void _handlePuzzleNav() {
    if (_trendingNews.isNotEmpty) {
      final randomNews = _trendingNews[0];
      setState(() {
        _currentNews = randomNews;
        _currentRoute = 'puzzle';
      });
    }
  }

  void _handleMenuNav() {
    setState(() {
      _currentRoute = 'bookshelf';
    });
  }

  // Handle logout
  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      // Clear login status
      await AppPreferences.clearLoginStatus();
      setState(() {
        _isLoggedIn = false;
        _currentRoute = 'login';
        _currentNews = null;
        _trendingNews = [];
      });
    }
  }

  // Handle login from guest
  void _handleLoginFromGuest() {
    // Clear guest login status first
    AppPreferences.clearLoginStatus().then((_) {
      // Set logged in to false to show login screen
      setState(() {
        _isLoggedIn = false;
        _currentRoute = 'login';
        _currentNews = null;
        _trendingNews = [];
      });
    });
  }

  Widget _buildCurrentScreen() {
    switch (_currentRoute) {
      // Added: Case 'login' - returns empty widget to prevent homepage from being built
      // This ensures LoginScreen is the only widget rendered when _isLoggedIn == false
      case 'login':
        return const SizedBox.shrink();
      
      case 'homepage':
        return HomepageScreen(
          onPuzzle: _handlePuzzleFromHomepage,
          onHome: _handleHomeFromHomepage,
          onLogout: _handleLogout,
          onLogin: _handleLoginFromGuest,
        );
      case 'main_menu':
        return MainMenuScreen(
          trendingNews: _trendingNews,
          onNewsTap: _handleNewsTap,
          onBookmark: _handleBookmark,
          onBookmarkNavigate: _handleBookmarkAndShow,
          onPuzzle: _handlePuzzleForNews,
          onRead: _handleNewsTap,
        );
      case 'puzzle':
        return PuzzleScreen(
          news: _currentNews,
          onComplete: _handlePuzzleComplete,
          hideTitle: _currentNews == null, // Sembunyikan judul jika random puzzle
        );
      case 'news_detail':
        if (_currentNews == null) {
          return const Center(child: Text('No news selected'));
        }
        return NewsDetailScreen(
          news: _currentNews!,
          onPlayPuzzle: _handlePlayPuzzle,
          onStartQuiz: _handleStartQuiz,
          onHome: () {
            setState(() {
              _currentRoute = 'homepage';
            });
          },
        );
      case 'quiz':
        if (_currentNews == null) {
          return const Center(child: Text('No quiz available'));
        }
        return QuizScreen(
          news: _currentNews!,
          onFinish: _handleQuizFinished,
        );
      case 'bookshelf':
        return BookshelfScreen(
          onBookmarks: () {
            setState(() {
              _currentRoute = 'bookmarks';
            });
          },
          onRecent: () {
            setState(() {
              _currentRoute = 'recent';
            });
          },
        );
      case 'bookmarks':
        return BookmarksScreen(
          onNewsTap: _handleNewsTap,
          onPuzzle: _handlePuzzleForNews,
          onRead: _handleNewsTap,
          onBookmark: _handleBookmark,
        );
      case 'recent':
        return RecentScreen(
          onNewsTap: _handleNewsTap,
        );
      // Changed: Default case now returns empty widget instead of HomepageScreen
      // This prevents homepage from being built when route is unknown or during login state
      default:
        return const SizedBox.shrink();
    }
  }

  bool _shouldShowBottomNav() {
    return _currentRoute != 'homepage';
  }

  void _handleSkipPuzzle() {
    if (_currentNews != null) {
      _handleNewsTap(_currentNews!);
    } else {
      setState(() {
        _currentRoute = 'main_menu';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // CRITICAL: Only show LoginScreen when not logged in
    // Do not render any other widget, including homepage
    // This ensures homepage is NOT built until after login
    if (!_isLoggedIn) {
      return LoginScreen(
        onLoginSuccess: _handleLoginSuccess,
        onGuestLogin: _handleGuestLogin,
      );
    }

    // Only render main app after user has logged in or chosen guest
    // This ensures homepage and other screens are NOT created until after login
    return Scaffold(
      body: Stack(
        children: [
          _buildCurrentScreen(),
          if (_shouldShowBottomNav())
            BottomNavBar(
              onBack: _handleBack,
              onPuzzle: _handlePuzzleNav,
              onMenu: _handleMenuNav,
              puzzleMode: _currentRoute == 'puzzle',
              onSkip: _currentRoute == 'puzzle' ? _handleSkipPuzzle : null,
            ),
        ],
      ),
    );
  }
}

