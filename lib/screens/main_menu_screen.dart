import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/news.dart';
import '../services/news_api_service.dart' as NewsApiService;
import '../services/database_service.dart';
import '../utils/image_helper.dart';
import '../main.dart';

class MainMenuScreen extends StatefulWidget {
  final List<News> trendingNews;
  final Function(News) onNewsTap;
  final Function(News) onBookmark;
  final Function(News)? onPuzzle;
  final Function(News)? onRead;
  final Function(News)? onBookmarkNavigate;

  const MainMenuScreen({
    Key? key,
    required this.trendingNews,
    required this.onNewsTap,
    required this.onBookmark,
    this.onPuzzle,
    this.onRead,
    this.onBookmarkNavigate,
  }) : super(key: key);

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

typedef _HintToggleCallback = void Function(
  Offset position,
  VoidCallback onBookmark,
  VoidCallback onRead,
  VoidCallback? onPuzzle,
);

class _MainMenuScreenState extends State<MainMenuScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<News> _newsList = [];
  List<News> _verifiedNews = [];
  bool _isLoading = false;
  bool _isLoadingVerified = false;
  String? _errorMessage;
  String? _activeHintId;
  Offset _hintPosition = Offset.zero;
  VoidCallback? _hintOnBookmark;
  VoidCallback? _hintOnRead;
  VoidCallback? _hintOnPuzzle;

  @override
  void initState() {
    super.initState();
    _newsList = widget.trendingNews;
    // Always load news to ensure we have data
    // If trendingNews is provided, use it as initial data but still refresh
    _loadNews();
    _loadVerifiedNews();
  }

  Future<void> _loadNews() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _activeHintId = null;
    });

    try {
      final news = await NewsApiService.NewsApiService.fetchTopHeadlines();
      if (news.isNotEmpty) {
        setState(() {
          _newsList = news;
          _isLoading = false;
        });
      } else {
        // If API returns empty, keep existing news or show error
        if (_newsList.isEmpty) {
          setState(() {
            _errorMessage = 'Tidak ada berita yang tersedia. Silakan coba lagi nanti.';
            _isLoading = false;
          });
        } else {
          // Keep existing news if API fails but we have cached data
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      // If we have cached news, don't show error, just keep using it
      if (_newsList.isEmpty) {
        setState(() {
          _errorMessage = 'Gagal memuat berita: ${e.toString()}';
          _isLoading = false;
        });
      } else {
        // Keep existing news if we have it
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadVerifiedNews() async {
    setState(() {
      _isLoadingVerified = true;
    });

    try {
      final verifiedNews = await DatabaseService.getVerifiedNews();
      if (mounted) {
        setState(() {
          _verifiedNews = verifiedNews;
          _isLoadingVerified = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _verifiedNews = [];
          _isLoadingVerified = false;
        });
      }
    }
  }

  List<News> _filterNews(List<News> source) {
    if (_searchQuery.isEmpty) return source;
    final lowerQuery = _searchQuery.toLowerCase();
    return source.where((news) {
      final title = news.title?.toLowerCase() ?? '';
      final snippet = news.snippet?.toLowerCase() ?? '';
      return title.contains(lowerQuery) || snippet.contains(lowerQuery);
    }).toList();
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: 220,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _toggleHint(
    String id,
    Offset globalPosition, {
    required VoidCallback onBookmark,
    required VoidCallback onRead,
    VoidCallback? onPuzzle,
  }) {
    final renderBox = context.findRenderObject() as RenderBox?;
    final localPosition =
        renderBox != null ? renderBox.globalToLocal(globalPosition) : globalPosition;
    setState(() {
      if (_activeHintId == id) {
        _activeHintId = null;
        return;
      }
      _activeHintId = id;
      _hintPosition = localPosition;
      _hintOnBookmark = onBookmark;
      _hintOnRead = onRead;
      _hintOnPuzzle = onPuzzle;
    });
  }

  List<Widget> _buildNewsCards(List<News> newsList, {required String section}) {
    final total = newsList.length;
    return List.generate(total, (index) {
      final news = newsList[index];
      final hintId = '$section-$index';
      return Padding(
        padding: EdgeInsets.only(bottom: index == total - 1 ? 0 : 12),
        child: _NewsListTile(
          news: news,
          index: index + 1,
          total: total,
          onToggleHint: (offset, bookmark, read, puzzle) => _toggleHint(
            hintId,
            offset,
            onBookmark: bookmark,
            onRead: read,
            onPuzzle: puzzle,
          ),
          onBookmark: () => widget.onBookmark(news),
          onBookmarkNavigate: widget.onBookmarkNavigate != null
              ? () => widget.onBookmarkNavigate!(news)
              : null,
          onPuzzle: widget.onPuzzle,
          onRead: widget.onRead,
          onDefaultTap: () => widget.onNewsTap(news),
        ),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use _newsList if available, otherwise fallback to widget.trendingNews
    final List<News> newsToDisplay = _newsList.isNotEmpty 
        ? _newsList 
        : (widget.trendingNews.isNotEmpty ? widget.trendingNews : <News>[]);
    final filteredNews = _filterNews(newsToDisplay);
    // Use verified news from database (already filtered and sorted)
    final verifiedNews = _verifiedNews;
    final trendingNews = filteredNews;
    final mediaQuery = MediaQuery.of(context);
    final availableWidth = mediaQuery.size.width;
    final availableHeight = mediaQuery.size.height -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom;
    const double hintHeight = 100;
    const double hintWidth = 140;
    const double hintMargin = 12;
    const double bottomNavHeight = 67;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Title Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PuRe:',
                        style: TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1E1E),
                          letterSpacing: -0.03,
                          height: 1.2,
                        ),
                      ),
                      const Text(
                        'Puzzle & Reasoning',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF757575),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Want to know more section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Want to know more?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Search Box
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 4,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.trim();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        suffixIcon: const Icon(Icons.search, size: 24),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Verified + Trending News Section
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 9),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 4,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _isLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : _errorMessage != null
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _errorMessage!,
                                        style: const TextStyle(
                                          color: Color(0xFF757575),
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: _loadNews,
                                        child: const Text('Coba Lagi'),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Scrollbar(
                                thumbVisibility: true,
                                child: RefreshIndicator(
                                  onRefresh: () async {
                                    await Future.wait([
                                      _loadNews(),
                                      _loadVerifiedNews(),
                                    ]);
                                  },
                                  child: SingleChildScrollView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 11, vertical: 18),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildSectionHeader('Verified News'),
                                        const SizedBox(height: 16),
                                        if (_isLoadingVerified)
                                          const Padding(
                                            padding:
                                                EdgeInsets.symmetric(horizontal: 4),
                                            child: Center(
                                              child: Padding(
                                                padding: EdgeInsets.all(16.0),
                                                child: CircularProgressIndicator(),
                                              ),
                                            ),
                                          )
                                        else if (verifiedNews.isEmpty)
                                          const Padding(
                                            padding:
                                                EdgeInsets.symmetric(horizontal: 4),
                                            child: Text(
                                              'Belum ada berita terverifikasi.\nMinimal 5 pengguna harus memvalidasi berita.',
                                              style: TextStyle(
                                                color: Color(0xFF757575),
                                                fontSize: 16,
                                              ),
                                            ),
                                          )
                                        else
                                          ..._buildNewsCards(
                                            verifiedNews,
                                            section: 'verified',
                                          ),
                                        const SizedBox(height: 28),
                                        _buildSectionHeader('Trending News'),
                                        const SizedBox(height: 16),
                                        if (trendingNews.isEmpty)
                                          const Padding(
                                            padding:
                                                EdgeInsets.symmetric(horizontal: 4),
                                            child: Text(
                                              'Belum ada berita trending lainnya.',
                                              style: TextStyle(
                                                color: Color(0xFF757575),
                                                fontSize: 16,
                                              ),
                                            ),
                                          )
                                        else
                                          ..._buildNewsCards(
                                            trendingNews,
                                            section: 'trending',
                                          ),
                                        const SizedBox(height: 140),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                  ),
                ),
                const SizedBox(height: 67), // Space for bottom nav
              ],
            ),
            if (_activeHintId != null &&
                _hintOnBookmark != null &&
                _hintOnRead != null)
              Positioned(
                left: (_hintPosition.dx - hintWidth / 2)
                    .clamp(hintMargin, availableWidth - hintWidth - hintMargin),
                top: (_hintPosition.dy - 110).clamp(
                  hintMargin,
                  availableHeight - bottomNavHeight - hintHeight - hintMargin,
                ),
                child: _ActionHint(
                  onPlayPuzzle: _hintOnPuzzle,
                  onRead: _hintOnRead!,
                  onBookmark: _hintOnBookmark!,
                  onClose: () => setState(() => _activeHintId = null),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NewsListTile extends StatefulWidget {
  final News news;
  final int index;
  final int total;
  final _HintToggleCallback onToggleHint;
  final VoidCallback onBookmark;
  final VoidCallback? onBookmarkNavigate;
  final Function(News)? onPuzzle;
  final Function(News)? onRead;
  final VoidCallback onDefaultTap;

  const _NewsListTile({
    Key? key,
    required this.news,
    required this.index,
    required this.total,
    required this.onToggleHint,
    required this.onBookmark,
    this.onBookmarkNavigate,
    this.onPuzzle,
    this.onRead,
    required this.onDefaultTap,
  }) : super(key: key);

  @override
  State<_NewsListTile> createState() => __NewsListTileState();
}

class __NewsListTileState extends State<_NewsListTile> {
  Map<String, int>? _validationStats;
  bool _loadingValidation = false;

  @override
  void initState() {
    super.initState();
    _loadValidationStats();
  }

  Future<void> _loadValidationStats() async {
    if (!mounted) return;
    
    setState(() {
      _loadingValidation = true;
    });
    
    try {
      debugPrint('Loading validation stats for: ${widget.news.link}');
      final stats = await AppPreferences.getNewsValidation(widget.news.link);
      debugPrint('Validation stats loaded: $stats');
      
      if (mounted) {
        setState(() {
          _validationStats = stats ?? {'valid': 0, 'invalid': 0};
          _loadingValidation = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading validation stats: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _validationStats = {'valid': 0, 'invalid': 0};
          _loadingValidation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final thumbnail = widget.news.thumbnail ?? '';
    final hasImage = thumbnail.isNotEmpty;
    
    // Debug logging
    if (kDebugMode) {
      debugPrint('NewsListTile: ${widget.news.title}');
      debugPrint('NewsListTile: thumbnail = $thumbnail');
      debugPrint('NewsListTile: hasImage = $hasImage');
      debugPrint('NewsListTile: validationStats = $_validationStats');
      debugPrint('NewsListTile: loadingValidation = $_loadingValidation');
    }
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapDown: (details) {
            final bookmarkCb =
                widget.onBookmarkNavigate != null ? widget.onBookmarkNavigate! : widget.onBookmark;
            final readCb = widget.onRead != null ? () => widget.onRead!(widget.news) : widget.onDefaultTap;
            final puzzleCb = widget.onPuzzle != null ? () => widget.onPuzzle!(widget.news) : null;
            widget.onToggleHint(
              details.globalPosition,
              bookmarkCb,
              readCb,
              puzzleCb,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SizedBox(
              width: 378,
              height: 93,
              child: Stack(
                children: [
                  Positioned(
                    left: 12,
                    top: 11,
                    child: _ThumbnailBox(
                      hasImage: hasImage,
                      thumbnail: thumbnail,
                    ),
                  ),
                  Positioned(
                    left: 117,
                    top: 14,
                    right: 60,
                    child: Text(
                      widget.news.title ?? 'No Title',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E1E1E),
                        letterSpacing: 0.15,
                        height: 1.5,
                      ),
                    ),
                  ),
                  // Bookmark button - di bawah
                  Positioned(
                    top: 52,
                    right: 16,
                    child: _BookmarkButton(onBookmark: widget.onBookmark),
                  ),
                  // Validation badge - centang hijau dengan angka valid, di atas bookmark
                  Positioned(
                    top: 12,
                    right: 16,
                    child: _ValidationBadge(
                      validCount: _validationStats?['valid'] ?? 0,
                      loading: _loadingValidation,
                    ),
                  ),
                  if (widget.news.snippet != null && widget.news.snippet!.isNotEmpty)
                    Positioned(
                      left: 117,
                      bottom: 12,
                      right: 80,
                      child: Text(
                        widget.news.snippet!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF616161),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: const Icon(
        Icons.photo,
        color: Colors.grey,
        size: 30,
      ),
    );
  }
}

class _ThumbnailBox extends StatelessWidget {
  final bool hasImage;
  final String thumbnail;

  const _ThumbnailBox({
    required this.hasImage,
    required this.thumbnail,
  });

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      debugPrint('ThumbnailBox: hasImage=$hasImage, thumbnail=$thumbnail');
    }
    
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: hasImage && thumbnail.isNotEmpty
            ? ImageHelper.networkImage(
                url: thumbnail,
                fit: BoxFit.cover,
                placeholder: const _ImagePlaceholder(),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) {
                    if (kDebugMode) {
                      debugPrint('ThumbnailBox: Image loaded successfully');
                    }
                    return child;
                  }
                  if (kDebugMode) {
                    debugPrint('ThumbnailBox: Loading image... ${progress.cumulativeBytesLoaded}/${progress.expectedTotalBytes}');
                  }
                  return const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('ThumbnailBox: Error loading thumbnail: $error');
                  debugPrint('ThumbnailBox: Thumbnail URL: $thumbnail');
                  debugPrint('ThumbnailBox: Stack trace: $stackTrace');
                  return const _ImagePlaceholder();
                },
              )
            : const _ImagePlaceholder(),
      ),
    );
  }
}

class _ValidationBadge extends StatelessWidget {
  final int validCount;
  final bool loading;

  const _ValidationBadge({
    required this.validCount,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      debugPrint('_ValidationBadge: loading=$loading, validCount=$validCount');
    }
    
    // Selalu tampilkan badge (loading atau dengan angka)
    if (loading) {
      return Container(
        width: 40,
        height: 20,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
        ),
      );
    }

    // Tampilkan badge dengan centang hijau dan angka validasi
    // Tampilkan bahkan jika validCount = 0 (untuk konsistensi UI)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            size: 14,
            color: Colors.green,
          ),
          const SizedBox(width: 4),
          Text(
            validCount.toString(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E1E1E),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookmarkButton extends StatelessWidget {
  final VoidCallback onBookmark;

  const _BookmarkButton({required this.onBookmark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onBookmark,
      child: Container(
        width: 31,
        height: 31,
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.bookmark_outline,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

class _ActionHint extends StatelessWidget {
  final VoidCallback? onPlayPuzzle;
  final VoidCallback? onRead;
  final VoidCallback onBookmark;
  final VoidCallback onClose;

  const _ActionHint({
    this.onPlayPuzzle,
    this.onRead,
    required this.onBookmark,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 110,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2).withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withOpacity(0.11)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HintButton(
              label: 'Play Puzzle',
              onTap: onPlayPuzzle != null
                  ? () {
                      onClose();
                      onPlayPuzzle!();
                    }
                  : null,
            ),
            _HintButton(
              label: 'Read',
              onTap: () {
                onClose();
                onRead?.call();
              },
            ),
            _HintButton(
              label: 'Bookmark',
              onTap: () {
                onClose();
                onBookmark();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HintButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _HintButton({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
            color: enabled ? const Color(0xFF1E1E1E) : Colors.grey,
            shadows: const [
              Shadow(
                color: Color(0x40000000),
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
