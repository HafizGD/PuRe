import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppPreferences.init();
  bool isDark = AppPreferences.isDarkMode;
  runApp(PureApp(isDarkMode: isDark));
}

// === MODEL ===
class News {
  final String link;
  final String? title;
  final String? snippet;
  final String? thumbnail;

  News({required this.link, this.title, this.snippet, this.thumbnail});

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      link: json['url'] ?? '',
      title: json['title'],
      snippet: json['description'],
      thumbnail: json['urlToImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'link': link,
      'title': title,
      'snippet': snippet,
      'thumbnail': thumbnail,
    };
  }
}

// === SERVICES ===
class AppPreferences {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static bool get isDarkMode => _prefs.getBool('isDarkMode') ?? false;

  static Future<void> setDarkMode(bool value) async {
    await _prefs.setBool('isDarkMode', value);
  }

  static Future<void> addBookmark(String link) async {
    final bookmarks = _prefs.getStringList('bookmarks') ?? [];
    if (!bookmarks.contains(link)) {
      bookmarks.add(link);
      await _prefs.setStringList('bookmarks', bookmarks);
    }
  }

  static Future<void> removeBookmark(String link) async {
    final bookmarks = _prefs.getStringList('bookmarks') ?? [];
    if (bookmarks.contains(link)) {
      bookmarks.remove(link);
      await _prefs.setStringList('bookmarks', bookmarks);
    }
  }

  static List<String> get bookmarks => _prefs.getStringList('bookmarks') ?? [];

  static Future<void> addRecent(String link) async {
    final recents = _prefs.getStringList('recents') ?? [];
    if (!recents.contains(link)) {
      recents.insert(0, link); // Tambahkan ke awal
      if (recents.length > 10) recents.removeLast(); // Batasi 10 item
      await _prefs.setStringList('recents', recents);
    }
  }

  static List<String> get recents => _prefs.getStringList('recents') ?? [];
}

class NewsApiService {
  static const String _baseUrl = 'https://newsapi.org/v2';
  static const String _apiKey = 'dda1f60322d94ce3b47adb285a63d5aa'; // GANTI DENGAN API KEY ANDA

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

// === SCREENS ===
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('PuRe:', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
            Text('Puzzle & Reasoning', style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.bodyMedium?.color)),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PuzzleScreen()));
                  },
                  child: const Text('Puzzle'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                  },
                  child: const Text('Browse'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<News> newsList = [];
  List<News> filteredNews = [];
  bool loading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  void _loadNews() async {
    try {
      final news = await NewsApiService.fetchTopHeadlines();
      setState(() {
        newsList = news;
        filteredNews = news;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _searchNews(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredNews = newsList;
      } else {
        filteredNews = newsList.where((news) => news.title?.toLowerCase().contains(query.toLowerCase()) ?? false).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PuRe: Puzzle & Reasoning'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: _searchNews,
              decoration: InputDecoration(
                hintText: 'Want to know more?',
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Chip(label: Text('Trending News')),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredNews.length,
                    itemBuilder: (c, i) {
                      final s = filteredNews[i];
                      bool isBookmarked = AppPreferences.bookmarks.contains(s.link);
                      return ListTile(
                        leading: s.thumbnail != null
                            ? Image.network(s.thumbnail!, width: 40, height: 40, fit: BoxFit.cover)
                            : const Icon(Icons.image),
                        title: Text(s.title ?? 'No Title'),
                        subtitle: Text(s.snippet ?? 'No Description'),
                        trailing: IconButton(
                          icon: Icon(
                            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: isBookmarked ? Colors.orange : null,
                          ),
                          onPressed: () async {
                            if (isBookmarked) {
                              await AppPreferences.removeBookmark(s.link);
                            } else {
                              await AppPreferences.addBookmark(s.link);
                            }
                            setState(() {}); // Refresh UI
                          },
                        ),
                        onTap: () {
                          AppPreferences.addRecent(s.link);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => NewsDetailScreen(item: s, userId: 1)),
                          );
                        },
                      );
                    },
                  ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
         Navigator.push(context, MaterialPageRoute(builder: (_) => MenuScreen(onNav: (String action) {})));
        },
        child: const Icon(Icons.menu),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class NewsDetailScreen extends StatefulWidget {
  final News item;
  final int userId;
  const NewsDetailScreen({Key? key, required this.item, required this.userId}) : super(key: key);

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  Map<String, dynamic> validate = {'valid_count': 0, 'invalid_count': 0};
  bool loading = false;
  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();
    isBookmarked = AppPreferences.bookmarks.contains(widget.item.link);
    fetchValidate();
  }

  Future<void> fetchValidate() async {
    setState(() {
      validate = {'valid_count': 1, 'invalid_count': 0}; // Mock data
    });
  }

  Future<void> vote(String t) async {
    setState(() => loading = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulasi API
    await fetchValidate();
    setState(() => loading = false);
  }

  Future<void> toggleBookmark() async {
    if (isBookmarked) {
      await AppPreferences.removeBookmark(widget.item.link);
    } else {
      await AppPreferences.addBookmark(widget.item.link);
    }
    setState(() => isBookmarked = !isBookmarked);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isBookmarked ? 'Bookmarked' : 'Removed from bookmarks')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.title ?? 'Detail'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.item.thumbnail != null)
              Container(
                height: 180,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(widget.item.thumbnail!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Text(widget.item.title ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(widget.item.snippet ?? ''),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: loading ? null : () => vote('valid'),
                  child: const Text('Valid'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: loading ? null : () => vote('invalid'),
                  child: const Text('Invalid'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: toggleBookmark,
                  child: Text(isBookmarked ? 'Unbookmark' : 'Bookmark'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PuzzleScreen()),
                  ),
                  child: const Text('Play Puzzle'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Votes: Valid ${validate['valid_count']}  •  Invalid ${validate['invalid_count']}'),
          ],
        ),
      ),
    );
  }
}

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({Key? key}) : super(key: key);

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<String> bookmarkLinks = [];

  @override
  void initState() {
    super.initState();
    loadBookmarks();
  }

  void loadBookmarks() {
    setState(() {
      bookmarkLinks = AppPreferences.bookmarks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      body: bookmarkLinks.isEmpty
          ? const Center(child: Text('No bookmarks yet.'))
          : FutureBuilder<List<News>>(
              future: Future.wait(
                bookmarkLinks.map((link) async => News(link: link, title: 'Loading...', snippet: '...')),
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Simulasi: kita tidak fetch detail, jadi tampilkan link saja
                return ListView.builder(
                  itemCount: bookmarkLinks.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('Bookmarked News ${index + 1}'),
                      subtitle: Text(bookmarkLinks[index]),
                      trailing: const Icon(Icons.bookmark),
                      onTap: () {
                        final news = News(link: bookmarkLinks[index], title: 'Bookmarked News ${index + 1}', snippet: 'Sample snippet...');
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => NewsDetailScreen(item: news, userId: 1)),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}

class RecentScreen extends StatefulWidget {
  const RecentScreen({Key? key}) : super(key: key);

  @override
  State<RecentScreen> createState() => _RecentScreenState();
}

class _RecentScreenState extends State<RecentScreen> {
  List<String> recentLinks = [];

  @override
  void initState() {
    super.initState();
    loadRecents();
  }

  void loadRecents() {
    setState(() {
      recentLinks = AppPreferences.recents;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Opened News'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      body: recentLinks.isEmpty
          ? const Center(child: Text('No recent news yet.'))
          : FutureBuilder<List<News>>(
              future: Future.wait(
                recentLinks.map((link) async => News(link: link, title: 'Loading...', snippet: '...')),
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  itemCount: recentLinks.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('Recent ${index + 1}'),
                      subtitle: Text(recentLinks[index]),
                      trailing: const Icon(Icons.history),
                      onTap: () {
                        final news = News(link: recentLinks[index], title: 'Recent ${index + 1}', snippet: 'Sample snippet...');
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => NewsDetailScreen(item: news, userId: 1)),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({Key? key}) : super(key: key);

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  List<int> tiles = [1, 2, 3, 4, 5, 6, 7, 8, 0]; // 0 adalah slot kosong

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puzzle & Reasoning'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Solve the puzzle!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: List.generate(9, (index) {
                  int tileValue = tiles[index];
                  if (tileValue == 0) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  }
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '$tileValue',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to News'),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuScreen extends StatelessWidget {
  final void Function(String) onNav;

  const MenuScreen({Key? key, required this.onNav}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDark = AppPreferences.isDarkMode;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => onNav('bookmarks'),
              child: const Text('Bookmarks'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => onNav('recent'),
              child: const Text('Recent Opened News'),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: isDark,
              onChanged: (value) async {
                await AppPreferences.setDarkMode(value);
                // Refresh theme
                if (context.mounted) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RootScreen()));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// === WIDGETS ===
class BottomNav extends StatelessWidget {
  final void Function(String) onNav;
  const BottomNav({Key? key, required this.onNav}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 12,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: 360,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => onNav('back'),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              GestureDetector(
                onTap: () => onNav('home'),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.extension, color: Colors.white),
                    Text('PuRe', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => onNav('menu'),
                icon: const Icon(Icons.menu, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// === APP & ROOT ===
class PureApp extends StatelessWidget {
  final bool isDarkMode;
  const PureApp({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PuRe News',
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: const RootScreen(),
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({Key? key}) : super(key: key);

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  String route = 'home';
  News? current;

  void handleOpen(News item) {
    setState(() {
      current = item;
      route = 'detail';
    });
  }

  void handleNav(String action) {
    if (action == 'menu') setState(() => route = 'menu');
    if (action == 'back') setState(() => route = 'home');
    if (action == 'home') setState(() => route = 'home');
    if (action == 'bookmarks') setState(() => route = 'bookmarks');
    if (action == 'recent') setState(() => route = 'recent');
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (route == 'home') {
      body = const HomeScreen();
    } else if (route == 'detail' && current != null) {
      body = NewsDetailScreen(item: current!, userId: 1);
    } else if (route == 'bookmarks') {
      body = const BookmarksScreen();
    } else if (route == 'recent') {
      body = const RecentScreen();
    } else if (route == 'menu') {
      body = MenuScreen(onNav: handleNav);
    } else {
      body = const SizedBox();
    }

    // Jangan tampilkan bottom nav di homepage
    if (route == 'home') {
      return Scaffold(body: body);
    }

    return Scaffold(
      body: Stack(children: [
        Positioned.fill(child: body),
        Align(alignment: Alignment.bottomCenter, child: BottomNav(onNav: handleNav)),
      ]),
    );
  }
}