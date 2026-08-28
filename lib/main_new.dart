import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
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
import 'services/news_api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppPreferences.init();
  runApp(const PureApp());
}

// === SERVICES ===
class AppPreferences {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> addBookmark(News news) async {
    final bookmarks = _prefs.getStringList('bookmarks') ?? [];
    final newsJson = json.encode(news.toJson());
    if (!bookmarks.contains(newsJson)) {
      bookmarks.add(newsJson);
      await _prefs.setStringList('bookmarks', bookmarks);
    }
  }

  static Future<void> removeBookmark(String link) async {
    final bookmarks = _prefs.getStringList('bookmarks') ?? [];
    bookmarks.removeWhere((jsonStr) {
      final news = News.fromJson(json.decode(jsonStr));
      return news.link == link;
    });
    await _prefs.setStringList('bookmarks', bookmarks);
  }

  static List<News> get bookmarks {
    final list = _prefs.getStringList('bookmarks') ?? [];
    return list.map((jsonStr) => News.fromJson(json.decode(jsonStr))).toList();
  }

  static Future<void> addRecent(News news) async {
    final recents = _prefs.getStringList('recents') ?? [];
    final newsJson = json.encode(news.toJson());
    if (!recents.contains(newsJson)) {
      recents.insert(0, newsJson);
      if (recents.length > 10) recents.removeLast();
      await _prefs.setStringList('recents', recents);
    }
  }

  // Authentication methods
  static Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool('isLoggedIn', value);
  }

  static bool get isLoggedIn {
    return _prefs.getBool('isLoggedIn') ?? false;
  }

  static Future<void> clearLoginStatus() async {
    await _prefs.remove('isLoggedIn');
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
  String _currentRoute = 'login';
  News? _currentNews;
  List<News> _trendingNews = [];
  bool _isLoggedIn = false; // Always false at startup - login screen will show

  @override
  void initState() {
    super.initState();
    // Always show login screen at startup - reset login status
    _resetAndShowLogin();
    // Don't load news until user is logged in
  }

  Future<void> _resetAndShowLogin() async {
    // Always reset login status to ensure login screen appears
    await AppPreferences.clearLoginStatus();
    // No need to setState since _isLoggedIn is already false
  }

  Future<void> _handleLoginSuccess() async {
    await AppPreferences.setLoggedIn(true);
    // Load news after login
    _loadTrendingNews();
    setState(() {
      _isLoggedIn = true;
      _currentRoute = 'homepage'; // Set to homepage after login
    });
  }

  Future<void> _handleGuestLogin() async {
    await AppPreferences.setLoggedIn(true);
    // Load news after guest login
    _loadTrendingNews();
    setState(() {
      _isLoggedIn = true;
      _currentRoute = 'homepage'; // Set to homepage after guest login
    });
  }

  Future<void> _loadTrendingNews() async {
    try {
      final news = await NewsApiService.fetchTopHeadlines();
      setState(() {
        _trendingNews = news.take(10).toList();
      });
    } catch (e) {
      // Handle error silently
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

  void _handleBookmark(News news) async {
    final isBookmarked =
        AppPreferences.bookmarks.any((n) => n.link == news.link);
    if (isBookmarked) {
      await AppPreferences.removeBookmark(news.link);
    } else {
      await AppPreferences.addBookmark(news);
    }
    setState(() {});
  }

  void _handleNewsPuzzle(News news) {
    setState(() {
      _currentNews = news;
      _currentRoute = 'puzzle';
    });
  }

  Future<void> _handleNewsRead(News news) async {
    final uri = Uri.tryParse(news.link);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _handlePuzzleComplete(News news) {
    setState(() {
      _currentNews = news;
      _currentRoute = 'news_detail';
    });
  }

  void _handleStartQuiz() {
    if (_currentNews == null) return;
    setState(() {
      _currentRoute = 'quiz';
    });
  }

  void _handleQuizFinished() {
    if (_currentNews == null) return;
    setState(() {
      _currentRoute = 'news_detail';
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

  Widget _buildCurrentScreen() {
    switch (_currentRoute) {
      // Case 'login': Return empty widget to prevent homepage from being built
      // This ensures LoginScreen is the only widget rendered when _isLoggedIn == false
      case 'login':
        return const SizedBox.shrink();
      
      case 'homepage':
        return HomepageScreen(
          onPuzzle: _handlePuzzleFromHomepage,
          onHome: _handleHomeFromHomepage,
        );
      case 'main_menu':
        return MainMenuScreen(
          trendingNews: _trendingNews,
          onNewsTap: _handleNewsTap,
          onBookmark: _handleBookmark,
          onPuzzle: _handleNewsPuzzle,
          onRead: _handleNewsRead,
        );
      case 'puzzle':
        return PuzzleScreen(
          news: _currentNews,
          onComplete: _handlePuzzleComplete,
        );
      case 'news_detail':
        if (_currentNews == null) {
          return const Center(child: Text('No news selected'));
        }
        return NewsDetailScreen(
          news: _currentNews!,
          onPlayPuzzle: () {
            if (_currentNews != null) {
              _handleNewsPuzzle(_currentNews!);
            }
          },
          onStartQuiz: _handleStartQuiz,
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
        );
      case 'recent':
        return RecentScreen(
          onNewsTap: _handleNewsTap,
        );
      // Default case: Return empty widget instead of HomepageScreen
      // This prevents homepage from being built when route is unknown or during login state
      default:
        return const SizedBox.shrink();
    }
  }

  bool _shouldShowBottomNav() {
    return _currentRoute != 'homepage';
  }

  @override
  Widget build(BuildContext context) {
    // CRITICAL: Only show LoginScreen when not logged in
    // Do not render any other widget, including homepage
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
            ),
        ],
      ),
    );
  }
}
