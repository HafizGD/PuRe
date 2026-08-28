class News {
  final String link;
  final String? title;
  final String? snippet;
  final String? content;
  final String? thumbnail;
  final String? author;
  final String? publishedAt;

  News({
    required this.link,
    this.title,
    this.snippet,
    this.content,
    this.thumbnail,
    this.author,
    this.publishedAt,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      link: _normalizeString(
            json['url'] ?? json['link'] ?? json['news_url'],
          ) ??
          '',
      title: _normalizeString(json['title']),
      snippet: _normalizeString(
            json['description'] ??
                json['snippet'] ??
                json['text'] ??
                json['summary'],
          ) ??
          '',
      content: _normalizeString(
        json['content'] ??
            json['full_description'] ??
            json['body'] ??
            json['content_text'] ??
            json['text'],
      ),
      thumbnail: _normalizeString(
        json['urlToImage'] ??
            json['thumbnail'] ??
            json['image'] ??
            json['image_url'] ??
            json['main_image'],
      ),
      author: _normalizeString(json['author'] ?? json['source_name']),
      publishedAt:
          _normalizeString(json['publishedAt'] ?? json['published_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'link': link,
      'title': title,
      'snippet': snippet,
      'content': content,
      'thumbnail': thumbnail,
      'author': author,
      'publishedAt': publishedAt,
    };
  }

  static String? _normalizeString(dynamic value) {
    if (value == null) return null;
    if (value is! String) return value.toString();
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.toLowerCase() == 'null') return null;
    return trimmed;
  }
}
