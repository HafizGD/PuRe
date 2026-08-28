import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'dart:typed_data';

/// Helper untuk memuat gambar yang kompatibel dengan web dan mobile
class ImageHelper {
  /// Memuat gambar dari URL dengan headers yang tepat untuk web
  static Widget networkImage({
    required String url,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    ImageErrorWidgetBuilder? errorBuilder,
    ImageLoadingBuilder? loadingBuilder,
  }) {
    // Untuk web, gunakan StatefulWidget dengan CORS proxy
    if (kIsWeb) {
      return _WebNetworkImage(
        url: url,
        fit: fit,
        placeholder: placeholder,
        errorBuilder: errorBuilder,
        loadingBuilder: loadingBuilder,
      );
    } else {
      // Untuk mobile, gunakan Image.network biasa
      return Image.network(
        url,
        fit: fit,
        errorBuilder: errorBuilder ??
            (context, error, stackTrace) {
              return placeholder ??
                  const Icon(Icons.image_not_supported, color: Colors.grey);
            },
        loadingBuilder: loadingBuilder,
      );
    }
  }

  /// Memuat gambar sebagai bytes untuk digunakan sebagai ImageProvider
  /// Berguna untuk puzzle screen yang perlu memproses gambar
  static Future<ImageProvider<Object>?> loadImageAsProvider(String imageUrl) async {
    try {
      // Untuk web, gunakan CORS proxy
      if (kIsWeb) {
        final proxyUrls = [
          'https://api.allorigins.win/raw?url=${Uri.encodeComponent(imageUrl)}',
          'https://corsproxy.io/?${Uri.encodeComponent(imageUrl)}',
          'https://api.codetabs.com/v1/proxy?quest=${Uri.encodeComponent(imageUrl)}',
        ];

        for (final proxyUrl in proxyUrls) {
          try {
            final response = await http.get(Uri.parse(proxyUrl)).timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                throw TimeoutException('Image load timeout');
              },
            );

            if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
              final uiImage = await _decodeImage(response.bodyBytes);
              final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
              if (byteData != null) {
                return MemoryImage(byteData.buffer.asUint8List());
              }
            }
          } catch (e) {
            debugPrint('CORS proxy failed: $e');
            continue;
          }
        }
        return null;
      } else {
        // Untuk mobile, gunakan http.get langsung
        final response = await http.get(Uri.parse(imageUrl)).timeout(
          const Duration(seconds: 10),
        );
        
        if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
          return null;
        }

        final uiImage = await _decodeImage(response.bodyBytes);
        final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
        
        if (byteData == null) return null;

        return MemoryImage(byteData.buffer.asUint8List());
      }
    } catch (e) {
      debugPrint('Error loading image: $e');
      return null;
    }
  }

  static Future<ui.Image> _decodeImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}

/// StatefulWidget untuk memuat gambar di web dengan CORS proxy
class _WebNetworkImage extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final Widget? placeholder;
  final ImageErrorWidgetBuilder? errorBuilder;
  final ImageLoadingBuilder? loadingBuilder;

  const _WebNetworkImage({
    required this.url,
    required this.fit,
    this.placeholder,
    this.errorBuilder,
    this.loadingBuilder,
  });

  @override
  State<_WebNetworkImage> createState() => _WebNetworkImageState();
}

class _WebNetworkImageState extends State<_WebNetworkImage> {
  ImageProvider<Object>? _imageProvider;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(_WebNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.url != oldWidget.url) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = false;
      _imageProvider = null;
    });

    try {
      final provider = await ImageHelper.loadImageAsProvider(widget.url);
      if (mounted) {
        setState(() {
          _imageProvider = provider;
          _loading = false;
          _error = provider == null;
        });
      }
    } catch (e) {
      debugPrint('Error loading web image: $e');
      if (mounted) {
        setState(() {
          _loading = false;
          _error = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      if (widget.loadingBuilder != null) {
        return widget.loadingBuilder!(context, const SizedBox(), null);
      }
      return widget.placeholder ?? const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error || _imageProvider == null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(
          context,
          Exception('Failed to load image'),
          StackTrace.current,
        );
      }
      return widget.placeholder ?? const Icon(
        Icons.image_not_supported,
        color: Colors.grey,
      );
    }

    return Image(
      image: _imageProvider!,
      fit: widget.fit,
      errorBuilder: widget.errorBuilder ??
          (context, error, stackTrace) {
            return widget.placeholder ?? const Icon(
              Icons.image_not_supported,
              color: Colors.grey,
            );
          },
    );
  }
}

