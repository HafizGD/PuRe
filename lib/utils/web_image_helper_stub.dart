// Stub untuk non-web platforms
import 'package:flutter/material.dart';

Widget createWebImageWidget({
  required String url,
  required BoxFit fit,
  Widget? placeholder,
}) {
  // Fallback untuk non-web
  return Image.network(url, fit: fit);
}







