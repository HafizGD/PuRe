import 'package:http/http.dart' as http;
import 'package:pure/services/news_api_service.dart';

Future<void> main() async {
  final news = await NewsApiService.fetchTopHeadlines();
  for (final item in news.take(3)) {
    print('title: ${item.title}');
    print('thumbnail: ${item.thumbnail}');
    if (item.thumbnail != null && item.thumbnail!.isNotEmpty) {
      final res = await http.get(Uri.parse(item.thumbnail!));
      print('image status: ${res.statusCode}');
    }
    if (item.snippet != null) {
      final snippet = item.snippet!;
      final cut = snippet.length > 80 ? snippet.substring(0, 80) : snippet;
      print('content snippet: $cut');
    }
    print('----');
  }
}

