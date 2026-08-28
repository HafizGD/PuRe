import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseEndpoint =
      'https://api.worldnewsapi.com/search-news';
  static String get _apiKey => dotenv.env['WORLD_NEWS_API_KEY'] ?? '';

  static Future<List<dynamic>> fetchNews({
    String sourceCountries = 'id',
    int number = 50,
    String? language,
    String? text,
    Map<String, String>? extraParams,
  }) async {
    final params = <String, String>{
      'source-countries': sourceCountries,
      'number': number.toString(),
    };

    if (language != null && language.isNotEmpty) {
      params['language'] = language;
    }

    if (text != null && text.trim().isNotEmpty) {
      params['text'] = text.trim();
    }

    if (extraParams != null && extraParams.isNotEmpty) {
      params.addAll(extraParams);
    }

    final uri = Uri.parse(_baseEndpoint).replace(queryParameters: params);
    final response = await http.get(
      uri,
      headers: {'x-api-key': _apiKey},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch news (${response.statusCode}): ${response.reasonPhrase}',
      );
    }

    final decoded = json.decode(response.body);

    if (decoded is Map<String, dynamic>) {
      if (decoded['news'] is List) {
        return decoded['news'] as List<dynamic>;
      }
      if (decoded['data'] is List) {
        return decoded['data'] as List<dynamic>;
      }
      if (decoded['articles'] is List) {
        return decoded['articles'] as List<dynamic>;
      }
    } else if (decoded is List) {
      return decoded;
    }

    return [];
  }
}
