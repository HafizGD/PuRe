import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/news.dart';
import '../services/database_service.dart';
import '../services/news_api_service.dart';

class PuzzleScreen extends StatefulWidget {
  final News? news;
  final Function(News)? onComplete;
  final bool hideTitle; // Parameter untuk menyembunyikan judul

  const PuzzleScreen({
    Key? key,
    this.news,
    this.onComplete,
    this.hideTitle =
        false, // Default false, akan true jika news null (random puzzle)
  }) : super(key: key);

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  static const int _rows = 3;
  static const int _cols = 3;

  late List<int> puzzleState;
  late List<int> correctOrder;

  bool isSolved = false;
  bool _loadingNews = true;
  bool _imageFailed = false;

  News? _currentNews;
  String? _newsTitle;
  ImageProvider<Object>? _thumbnailProvider;
  bool _showTitle = true; // State untuk menampilkan/menyembunyikan judul

  @override
  void initState() {
    super.initState();
    puzzleState = _generateSolvedBoard();
    correctOrder = List<int>.from(puzzleState);
    _currentNews = widget.news;

    if (_currentNews != null) {
      _newsTitle = _currentNews!.title;
      _showTitle = !widget.hideTitle; // Tampilkan judul jika tidak hideTitle
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _preparePuzzleForCurrentNews();
      });
    } else {
      _showTitle = false; // Sembunyikan judul untuk random puzzle
      _fetchRandomNews();
    }
  }

  Future<void> _fetchRandomNews() async {
    setState(() {
      _loadingNews = true;
    });

    try {
      final headlines = await NewsApiService.fetchTopHeadlines();

      if (headlines.isEmpty) {
        setState(() {
          _loadingNews = false;
          _newsTitle = 'No news available';
        });
        return;
      }

      final withImages =
          headlines.where((news) => (news.thumbnail ?? '').isNotEmpty).toList();

      final candidates = withImages.isNotEmpty ? withImages : headlines;

      final random = Random();
      final News randomNews = candidates[random.nextInt(candidates.length)];

      setState(() {
        _currentNews = randomNews;
        _newsTitle = _currentNews?.title;
        _showTitle = false; // Sembunyikan judul untuk random puzzle
      });

      await _preparePuzzleForCurrentNews();
    } catch (e) {
      setState(() {
        _loadingNews = false;
        _newsTitle = 'Error loading news';
      });
    }
  }

  List<int> _generateSolvedBoard() {
    final totalTiles = _rows * _cols;
    return List<int>.generate(
      totalTiles,
      (index) => index < totalTiles - 1 ? index + 1 : 0,
    );
  }

  Future<void> _preparePuzzleForCurrentNews() async {
    setState(() {
      _loadingNews = true;
      _imageFailed = false;
      isSolved = false;
      puzzleState = List<int>.from(correctOrder);
    });

    final imageUrl = _currentNews?.thumbnail;
    debugPrint('Puzzle: Preparing puzzle for news: ${_currentNews?.title}');
    debugPrint('Puzzle: Image URL: $imageUrl');

    if (imageUrl == null || imageUrl.isEmpty) {
      debugPrint('Puzzle: No image URL available, using number puzzle');
      setState(() {
        _thumbnailProvider = null;
        _loadingNews = false;
      });
      _shufflePuzzle();
      return;
    }

    debugPrint('Puzzle: Loading square image...');
    final provider = await _loadSquareImage(imageUrl);
    if (!mounted) return;

    if (provider == null) {
      debugPrint('Puzzle: Failed to load image, using number puzzle');
      setState(() {
        _thumbnailProvider = null;
        _loadingNews = false;
        _imageFailed = true;
      });
      _shufflePuzzle();
      return;
    }

    debugPrint('Puzzle: Precaching image...');
    try {
      await precacheImage(provider, context);
      debugPrint('Puzzle: Image precached successfully');
    } catch (e) {
      debugPrint('Puzzle: Error precaching image: $e');
      if (!mounted) return;
      setState(() {
        _thumbnailProvider = null;
        _loadingNews = false;
        _imageFailed = true;
      });
      _shufflePuzzle();
      return;
    }

    if (!mounted) return;
    debugPrint('Puzzle: Setting thumbnail provider and shuffling');
    setState(() {
      _thumbnailProvider = provider;
      _loadingNews = false;
    });
    _shufflePuzzle();
  }

  Future<ImageProvider<Object>?> _loadSquareImage(String imageUrl) async {
    try {
      // Validasi URL
      if (imageUrl.isEmpty) {
        debugPrint('Puzzle: Image URL is empty');
        return null;
      }

      final uri = Uri.tryParse(imageUrl);
      if (uri == null || !uri.hasScheme) {
        debugPrint('Puzzle: Invalid image URL: $imageUrl');
        return null;
      }

      debugPrint('Puzzle: Loading image from: $imageUrl');

      // Untuk web, gunakan proxy backend agar CORS sumber gambar tidak
      // perlu diaktifkan oleh server berita.
      if (kIsWeb) {
        final proxyUri = Uri.parse('${DatabaseService.baseUrl}/image_proxy.php')
            .replace(queryParameters: {'url': imageUrl});
        debugPrint('Puzzle: Loading image through backend proxy');
        final response = await http.get(proxyUri).timeout(
              const Duration(seconds: 15),
              onTimeout: () => throw TimeoutException('Image load timeout'),
            );

        if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
          debugPrint(
              'Puzzle: Backend image proxy failed: ${response.statusCode}');
          return null;
        }

        final uiImage = await _decodeImage(response.bodyBytes);
        final squareImage = await _cropToSquare(uiImage);
        final byteData =
            await squareImage.toByteData(format: ui.ImageByteFormat.png);
        return byteData == null
            ? null
            : MemoryImage(byteData.buffer.asUint8List());
      } else {
        // Untuk mobile, gunakan http.get seperti biasa
        final response = await http.get(uri).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            debugPrint('Puzzle: Image load timeout');
            throw TimeoutException('Image load timeout');
          },
        );

        if (response.statusCode != 200) {
          debugPrint(
              'Puzzle: Image load failed with status: ${response.statusCode}');
          return null;
        }

        if (response.bodyBytes.isEmpty) {
          debugPrint('Puzzle: Image response is empty');
          return null;
        }

        debugPrint(
            'Puzzle: Decoding image (${response.bodyBytes.length} bytes)');
        final uiImage = await _decodeImage(response.bodyBytes);

        debugPrint('Puzzle: Cropping image to square');
        final squareImage = await _cropToSquare(uiImage);

        debugPrint('Puzzle: Converting to byte data');
        final byteData =
            await squareImage.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) {
          debugPrint('Puzzle: Failed to convert image to byte data');
          return null;
        }

        debugPrint('Puzzle: Image loaded successfully');
        return MemoryImage(byteData.buffer.asUint8List());
      }
    } catch (e, stackTrace) {
      debugPrint('Puzzle: Error loading image: $e');
      debugPrint('Puzzle: Stack trace: $stackTrace');
      return null;
    }
  }

  Future<ui.Image> _cropToSquare(ui.Image image) async {
    final newSize = min(image.width, image.height);
    final xOffset = ((image.width - newSize) / 2).round();
    final yOffset = ((image.height - newSize) / 2).round();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final src = ui.Rect.fromLTWH(
      xOffset.toDouble(),
      yOffset.toDouble(),
      newSize.toDouble(),
      newSize.toDouble(),
    );
    final dst = ui.Rect.fromLTWH(
      0,
      0,
      newSize.toDouble(),
      newSize.toDouble(),
    );
    canvas.drawImageRect(image, src, dst, Paint());
    return recorder.endRecording().toImage(newSize, newSize);
  }

  Future<ui.Image> _decodeImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  void _shufflePuzzle() {
    final random = Random();
    for (int i = 0; i < 200; i++) {
      final emptyIndex = puzzleState.indexOf(0);
      final neighbors = _getNeighbors(emptyIndex);
      if (neighbors.isEmpty) continue;
      final target = neighbors[random.nextInt(neighbors.length)];
      puzzleState[emptyIndex] = puzzleState[target];
      puzzleState[target] = 0;
    }
    setState(() {});
  }

  List<int> _getNeighbors(int index) {
    final List<int> neighbors = [];
    final row = index ~/ _cols;
    final col = index % _cols;

    if (row > 0) neighbors.add((row - 1) * _cols + col);
    if (row < _rows - 1) neighbors.add((row + 1) * _cols + col);
    if (col > 0) neighbors.add(row * _cols + (col - 1));
    if (col < _cols - 1) neighbors.add(row * _cols + (col + 1));

    return neighbors;
  }

  void _movePiece(int index) {
    final emptyIndex = puzzleState.indexOf(0);
    if (_getNeighbors(emptyIndex).contains(index)) {
      setState(() {
        puzzleState[emptyIndex] = puzzleState[index];
        puzzleState[index] = 0;
        _checkSolved();
      });
    }
  }

  void _checkSolved() {
    for (int i = 0; i < puzzleState.length; i++) {
      if (puzzleState[i] != correctOrder[i]) {
        return;
      }
    }
    if (!isSolved) {
      isSolved = true;
      // Tampilkan judul setelah puzzle selesai
      if (mounted) {
        setState(() {
          _showTitle = true; // Tampilkan judul setelah puzzle selesai
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Puzzle selesai! Membuka berita...')),
        );
        // Tunggu sebentar sebelum membuka berita
        Future.delayed(const Duration(milliseconds: 500), () {
          if (widget.onComplete != null && _currentNews != null) {
            widget.onComplete!(_currentNews!);
          }
        });
      }
    }
  }

  Widget _buildTile(int index) {
    final value = puzzleState[index];
    if (value == 0) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black12),
        ),
      );
    }

    // Hitung posisi tile yang benar (bukan posisi saat ini di puzzleState)
    final correctRow = (value - 1) ~/ _cols;
    final correctCol = (value - 1) % _cols;

    return GestureDetector(
      onTap: () => _movePiece(index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: _thumbnailProvider == null ? Colors.white : Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background untuk tile tanpa gambar
              if (_thumbnailProvider == null)
                Container(
                  color: Colors.white,
                  child: Center(
                    child: Text(
                      value.toString(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                )
              else
                // Gambar puzzle yang dipecah menjadi 3x3
                Builder(
                  builder: (context) {
                    return ClipRect(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final tileWidth = constraints.maxWidth;
                          final tileHeight = constraints.maxHeight;
                          final imageWidth = tileWidth * _cols;
                          final imageHeight = tileHeight * _rows;

                          // Hitung offset untuk menampilkan bagian gambar yang benar
                          final offsetX = -correctCol * tileWidth;
                          final offsetY = -correctRow * tileHeight;

                          return OverflowBox(
                            minWidth: tileWidth,
                            minHeight: tileHeight,
                            maxWidth: imageWidth,
                            maxHeight: imageHeight,
                            alignment: Alignment.topLeft,
                            child: Transform.translate(
                              offset: Offset(offsetX, offsetY),
                              child: SizedBox(
                                width: imageWidth,
                                height: imageHeight,
                                child: _thumbnailProvider != null
                                    ? Image(
                                        image: _thumbnailProvider!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          debugPrint(
                                              'Puzzle: Error displaying image tile: $error');
                                          return Container(
                                            color: Colors.grey[300],
                                            child: Center(
                                              child: Text(
                                                value.toString(),
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Container(
                                            color: Colors.grey[200],
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                    : null,
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : Container(
                                        color: Colors.grey[300],
                                        child: Center(
                                          child: Text(
                                            value.toString(),
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              // Nomor urutan di sudut kiri atas
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      value.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _loadingNews
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 67),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 36),
                      const Center(
                        child: Text(
                          'Puzzle & Reasoning',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF757575),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (_newsTitle != null && _showTitle)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Center(
                            child: Text(
                              _newsTitle!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1E1E1E),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      Center(
                        child: _buildPuzzleCard(),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildPuzzleCard() {
    return Container(
      width: 394,
      margin: const EdgeInsets.symmetric(horizontal: 9),
      padding: const EdgeInsets.only(bottom: 22),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Container(
              width: 220,
              height: 40,
              margin: const EdgeInsets.only(top: 19),
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
              child: const Center(
                child: Text(
                  'Solve the puzzle !',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: SizedBox(
                    height: 320,
                    width: 320,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _cols,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _rows * _cols,
                      itemBuilder: (context, index) => _buildTile(index),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    isSolved
                        ? 'Mantap! Puzzle selesai, membuka berita...'
                        : 'Selesaikan puzzle untuk membaca berita lengkap.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF1E1E1E),
                      fontSize: 14,
                    ),
                  ),
                ),
                if (_imageFailed)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Center(
                      child: Text(
                        'Gambar gagal dimuat, gunakan puzzle angka.',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
