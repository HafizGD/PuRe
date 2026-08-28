// Implementation untuk web
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

Widget createWebImageWidget({
  required String url,
  required BoxFit fit,
  Widget? placeholder,
}) {
  final viewType = 'web-img-${url.hashCode}';
  
  // Register platform view hanya sekali
  if (!_registeredViews.contains(viewType)) {
    ui_web.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId) {
        final img = html.ImageElement()
          ..src = url
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = _getObjectFit(fit)
          ..style.display = 'block';
        
        // Jangan set crossOrigin jika tidak diperlukan (bisa menyebabkan masalah)
        // crossOrigin hanya diperlukan jika kita ingin mengakses pixel data
        
        img.onError.listen((_) {
          // Error handling - bisa log error di sini
        });
        
        return img;
      },
    );
    _registeredViews.add(viewType);
  }
  
  return HtmlElementView(viewType: viewType);
}

// Set untuk tracking view yang sudah diregister
final Set<String> _registeredViews = <String>{};

String _getObjectFit(BoxFit fit) {
  switch (fit) {
    case BoxFit.cover:
      return 'cover';
    case BoxFit.contain:
      return 'contain';
    case BoxFit.fill:
      return 'fill';
    case BoxFit.fitWidth:
    case BoxFit.fitHeight:
    case BoxFit.scaleDown:
      return 'scale-down';
    case BoxFit.none:
      return 'none';
  }
}

