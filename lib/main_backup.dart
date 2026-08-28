import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'screens/homepage_screen.dart';
import 'screens/main_menu_screen.dart';
import 'screens/puzzle_screen.dart';
import 'screens/news_detail_screen.dart';
import 'screens/bookshelf_screen.dart';
import 'screens/bookmarks_screen.dart';
import 'screens/recent_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'package:pure/models/news.dart';

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
}

class NewsApiService {
  static const String _baseUrl = 'https://newsapi.org/v2';
  static const String _apiKey = 'dda1f60322d94ce3b47adb285a63d5aa';

  static Future<List<News>> fetchTopHeadlines() async {
    final url = '$_baseUrl/top-headlines?country=id&apiKey=$_apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final articles = data['articles'] as List;
      return articles.map((json) => News.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load news');
    }
  }

  static Future<List<News>> searchNews(String query) async {
    final url = '$_baseUrl/everything?q=$query&apiKey=$_apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final articles = data['articles'] as List;
      return articles.map((json) => News.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search news');
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
  String _currentRoute = 'homepage';
  News? _currentNews;
  List<News> _trendingNews = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTrendingNews();
  }

  Future<void> _loadTrendingNews() async {
    try {
      final news = await NewsApiService.fetchTopHeadlines();
      setState(() {
        _trendingNews = news.take(10).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _handlePuzzleFromHomepage() {
    // Random puzzle - fetch random news
    if (_trendingNews.isNotEmpty) {
      final randomNews = _trendingNews[0]; // Use first news for now
      setState(() {
        _currentNews = randomNews;
        _currentRoute = 'puzzle';
      });
    }
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
    final isBookmarked = AppPreferences.bookmarks.any((n) => n.link == news.link);
    if (isBookmarked) {
      await AppPreferences.removeBookmark(news.link);
    } else {
      await AppPreferences.addBookmark(news);
    }
    setState(() {});
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
          onPlayPuzzle: _handlePlayPuzzle,
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
      default:
        return HomepageScreen(
          onPuzzle: _handlePuzzleFromHomepage,
          onHome: _handleHomeFromHomepage,
        );
    }
  }

  bool _shouldShowBottomNav() {
    return _currentRoute != 'homepage';
  }

  @override
  Widget build(BuildContext context) {
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

