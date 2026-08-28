import 'package:flutter/material.dart';
import '../models/news.dart';
import '../utils/image_helper.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NewsCardWidget extends StatefulWidget {
  final News news;
  final VoidCallback onTap;
  final VoidCallback onBookmark;
  final VoidCallback? onPuzzle;
  final VoidCallback? onRead;

  const NewsCardWidget({
    Key? key,
    required this.news,
    required this.onTap,
    required this.onBookmark,
    this.onPuzzle,
    this.onRead,
  }) : super(key: key);

  @override
  State<NewsCardWidget> createState() => _NewsCardWidgetState();
}

class _NewsCardWidgetState extends State<NewsCardWidget> {
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
  }

  Future<void> _checkBookmarkStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList('bookmarks') ?? [];
    setState(() {
      _isBookmarked = bookmarks.any((jsonStr) {
        final news = News.fromJson(json.decode(jsonStr));
        return news.link == widget.news.link;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onSecondaryTapDown: (details) => _showContextMenu(details.globalPosition),
      onLongPressStart: (details) => _showContextMenu(details.globalPosition),
      child: Container(
        width: 378,
        height: 93,
        margin: const EdgeInsets.symmetric(horizontal: 9),
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
        child: Row(
          children: [
            _NewsThumbnail(thumbnailUrl: widget.news.thumbnail),
            // Title
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  widget.news.title ?? 'No Title',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E1E1E),
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // Bookmark Icon
            IconButton(
              icon: Icon(
                _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: const Color(0xFF2C2C2C),
                size: 31,
              ),
              onPressed: () {
                widget.onBookmark();
                setState(() {
                  _isBookmarked = !_isBookmarked;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showContextMenu(Offset globalPosition) async {
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        globalPosition.dx,
        globalPosition.dy,
        globalPosition.dx,
        globalPosition.dy,
      ),
      items: const [
        PopupMenuItem(
          value: 'read',
          child: Text('Read'),
        ),
        PopupMenuItem(
          value: 'puzzle',
          child: Text('Puzzle'),
        ),
        PopupMenuItem(
          value: 'bookmark',
          child: Text('Bookmark'),
        ),
      ],
    );

    switch (selected) {
      case 'read':
        widget.onRead?.call();
        break;
      case 'puzzle':
        widget.onPuzzle?.call();
        break;
      case 'bookmark':
        widget.onBookmark();
        setState(() {
          _isBookmarked = !_isBookmarked;
        });
        break;
      default:
        break;
    }
  }
}

class _NewsThumbnail extends StatelessWidget {
  final String? thumbnailUrl;

  const _NewsThumbnail({this.thumbnailUrl});

  @override
  Widget build(BuildContext context) {
    final hasImage = thumbnailUrl != null && thumbnailUrl!.isNotEmpty;
    return Container(
      width: 70,
      height: 70,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: hasImage
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: ImageHelper.networkImage(
                      url: thumbnailUrl!,
                      fit: BoxFit.cover,
                      placeholder: const _ThumbnailPlaceholder(),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const _ThumbnailPlaceholder();
                      },
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.05),
                          Colors.black.withOpacity(0.25),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              )
            : const _ThumbnailPlaceholder(),
      ),
    );
  }
}

class _ThumbnailPlaceholder extends StatelessWidget {
  const _ThumbnailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2C2C2C),
      child: const Icon(
        Icons.image,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}
