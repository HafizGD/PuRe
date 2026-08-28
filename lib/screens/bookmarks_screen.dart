import 'package:flutter/material.dart';
import '../models/news.dart';
import '../main.dart';
import '../utils/image_helper.dart';

class BookmarksScreen extends StatefulWidget {
  final Function(News) onNewsTap;
  final Function(News)? onPuzzle;
  final Function(News)? onRead;
  final Function(News) onBookmark;

  const BookmarksScreen({
    Key? key,
    required this.onNewsTap,
    this.onPuzzle,
    this.onRead,
    required this.onBookmark,
  }) : super(key: key);

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<News> bookmarks = [];
  String? _activeHintId;
  Offset _hintPosition = Offset.zero;
  VoidCallback? _hintOnBookmark;
  VoidCallback? _hintOnRead;
  VoidCallback? _hintOnPuzzle;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload bookmarks when screen becomes visible
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    // Use AppPreferences which handles database integration
    final bookmarksList = await AppPreferences.getBookmarks();
    setState(() {
      bookmarks = bookmarksList;
    });
  }

  void _toggleHint(
    String hintId,
    Offset position, {
    required VoidCallback onBookmark,
    required VoidCallback onRead,
    VoidCallback? onPuzzle,
  }) {
    setState(() {
      if (_activeHintId == hintId) {
        _activeHintId = null;
      } else {
        _activeHintId = hintId;
        _hintPosition = position;
        _hintOnBookmark = onBookmark;
        _hintOnRead = onRead;
        _hintOnPuzzle = onPuzzle;
      }
    });
  }

  Future<void> _removeBookmark(News news) async {
    // Use AppPreferences which handles database integration
    await AppPreferences.removeBookmark(news.link);
    await _loadBookmarks();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bookmark dihapus'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Title Section (sama seperti main menu)
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
                // Section Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Bookmarks',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Bookmarks List Container
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
                    child: bookmarks.isEmpty
                        ? const Center(
                            child: Text(
                              'No bookmarks yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF757575),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 26),
                            itemCount: bookmarks.length,
                            itemBuilder: (context, index) {
                              final news = bookmarks[index];
                              final hintId = 'bookmark-$index';
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: index == bookmarks.length - 1 ? 0 : 12),
                                  child: _BookmarkNewsTile(
                                    news: news,
                                    index: index + 1,
                                    total: bookmarks.length,
                                    onToggleHint: (offset, bookmark, read, puzzle) => _toggleHint(
                                      hintId,
                                      offset,
                                      onBookmark: bookmark,
                                      onRead: read,
                                      onPuzzle: puzzle,
                                    ),
                                    onBookmark: () => _removeBookmark(news),
                                    onPuzzle: widget.onPuzzle,
                                    onRead: widget.onRead,
                                    onDefaultTap: () => widget.onNewsTap(news),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 67), // Space for bottom nav
              ],
            ),
            // Hint overlay (same as main menu)
            if (_activeHintId != null)
              Positioned(
                left: _hintPosition.dx,
                top: _hintPosition.dy,
                child: _ActionHint(
                  onPlayPuzzle: _hintOnPuzzle,
                  onRead: _hintOnRead,
                  onBookmark: _hintOnBookmark ?? () {},
                  onClose: () {
                    setState(() {
                      _activeHintId = null;
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// News tile widget similar to main menu
class _BookmarkNewsTile extends StatefulWidget {
  final News news;
  final int index;
  final int total;
  final Function(Offset, VoidCallback, VoidCallback, VoidCallback?) onToggleHint;
  final VoidCallback onBookmark;
  final Function(News)? onPuzzle;
  final Function(News)? onRead;
  final VoidCallback onDefaultTap;

  const _BookmarkNewsTile({
    Key? key,
    required this.news,
    required this.index,
    required this.total,
    required this.onToggleHint,
    required this.onBookmark,
    this.onPuzzle,
    this.onRead,
    required this.onDefaultTap,
  }) : super(key: key);

  @override
  State<_BookmarkNewsTile> createState() => __BookmarkNewsTileState();
}

class __BookmarkNewsTileState extends State<_BookmarkNewsTile> {
  Map<String, int>? _validationStats;
  bool _loadingValidation = false;

  @override
  void initState() {
    super.initState();
    _loadValidationStats();
  }

  Future<void> _loadValidationStats() async {
    setState(() {
      _loadingValidation = true;
    });
    try {
      final stats = await AppPreferences.getNewsValidation(widget.news.link);
      if (mounted) {
        setState(() {
          _validationStats = stats;
          _loadingValidation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _validationStats = null;
          _loadingValidation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final thumbnail = widget.news.thumbnail ?? '';
    final hasImage = thumbnail.isNotEmpty;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapDown: (details) {
            final bookmarkCb = widget.onBookmark;
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

class _ThumbnailBox extends StatelessWidget {
  final bool hasImage;
  final String thumbnail;

  const _ThumbnailBox({
    required this.hasImage,
    required this.thumbnail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: hasImage
            ? ImageHelper.networkImage(
                url: thumbnail,
                fit: BoxFit.cover,
                placeholder: const _ImagePlaceholder(),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const _ImagePlaceholder();
                },
              )
            : const _ImagePlaceholder(),
      ),
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

class _ValidationBadge extends StatelessWidget {
  final int validCount;
  final bool loading;

  const _ValidationBadge({
    required this.validCount,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
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
          Icons.bookmark,
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
