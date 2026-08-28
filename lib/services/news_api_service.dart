import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news.dart';
import 'api_service.dart';

class NewsApiService {
  static const String _localApiBase =
      'http://10.0.2.2/pure-news-api/public/news.php';

  static Future<List<News>> fetchTopHeadlines({String? country}) async {
    try {
      final articles = await ApiService.fetchNews(
        sourceCountries: country ?? 'id',
        number: 50,
      );
      if (articles.isNotEmpty) {
        return articles.map((json) => News.fromJson(json)).toList();
      }
    } catch (_) {
      // Fall through to local API fallback
    }

    final localArticles = await _fetchFromLocal();
    return localArticles.map((json) => News.fromJson(json)).toList();
  }

  static Future<List<News>> searchNews(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return fetchTopHeadlines();
    }

    try {
      final articles = await ApiService.fetchNews(
        text: trimmed,
        number: 50,
      );
      if (articles.isNotEmpty) {
        return articles.map((json) => News.fromJson(json)).toList();
      }
    } catch (_) {
      // return empty list below
    }
    return [];
  }

  static Future<List<dynamic>> _fetchFromLocal() async {
    if (_localApiBase.isEmpty) {
      return [];
    }
    try {
      final response = await http.get(Uri.parse(_localApiBase));
      if (response.statusCode != 200) {
        return [];
      }
      final dynamic data = json.decode(response.body);
      if (data is List) {
        return data;
      }
      if (data is Map<String, dynamic>) {
        if (data['data'] is List) {
          return data['data'] as List<dynamic>;
        }
        if (data['articles'] is List) {
          return data['articles'] as List<dynamic>;
        }
      }
    } catch (_) {
      return [];
    }
    return [];
  }
}
