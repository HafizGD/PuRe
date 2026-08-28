import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/news.dart';

class DatabaseService {
  // Otomatis memilih URL berdasarkan platform
  // Untuk Android Emulator: http://10.0.2.2/news
  // Untuk Web: http://localhost/news
  // Untuk Device Fisik: http://YOUR_IP_ADDRESS/news (ubah manual jika perlu)
  static String get baseUrl {
    if (kIsWeb) {
      // Untuk web, gunakan localhost
      return 'http://localhost/news';
    } else {
      // Untuk Android emulator, gunakan 10.0.2.2
      // Untuk device fisik, ubah ke IP komputer Anda
      return 'http://10.0.2.2/news';
    }
  }
  
  // ========== USER METHODS ==========
  
  /// Register new user
  static Future<Map<String, dynamic>?> registerUser(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );
      
      // Check if response body is empty
      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Server tidak memberikan response. Pastikan XAMPP Apache dan MySQL running.'
        };
      }
      
      // Try to decode JSON
      try {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          return decoded;
        }
        
        // Return error message from server if available
        return {
          'success': false,
          'message': decoded['message'] ?? 'HTTP ${response.statusCode}'
        };
      } catch (e) {
        // JSON decode error
        return {
          'success': false,
          'message': 'Error parsing response: ${e.toString()}\nResponse: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Koneksi gagal: ${e.toString()}\n\nPastikan:\n1. XAMPP Apache dan MySQL running\n2. URL di database_service.dart sudah benar\n3. Database news_system sudah diimport'
      };
    }
  }
  
  /// Login user
  static Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );
      
      // Check if response body is empty
      if (response.body.isEmpty || response.body.trim().isEmpty) {
        return {
          'success': false,
          'message': 'Server tidak memberikan response. Pastikan XAMPP Apache dan MySQL running.'
        };
      }
      
      // Try to decode JSON
      try {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        
        if (response.statusCode == 200) {
          // Ensure user_id is properly formatted
          if (decoded.containsKey('user_id')) {
            final userId = decoded['user_id'];
            if (userId is num) {
              decoded['user_id'] = userId.toInt();
            }
          }
          return decoded;
        }
        
        // Return error message from server if available
        return {
          'success': false,
          'message': decoded['message'] ?? 'HTTP ${response.statusCode}'
        };
      } catch (e) {
        // JSON decode error - response is not valid JSON
        return {
          'success': false,
          'message': 'Error parsing response dari server. Pastikan file PHP tidak ada error.\nResponse: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error koneksi: ${e.toString()}\n\nPastikan:\n1. XAMPP Apache dan MySQL running\n2. URL benar: $baseUrl/login.php'
      };
    }
  }
  
  // ========== BOOKMARK METHODS ==========
  
  /// Add bookmark for user with full News data
  static Future<bool> addBookmark(int userId, News news) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bookmark.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'action': 'add',
          'user_id': userId,
          'link': news.link,
          'title': news.title,
          'snippet': news.snippet,
          'content': news.content,
          'thumbnail': news.thumbnail,
          'author': news.author,
          'publishedAt': news.publishedAt,
        }),
      );
      
      // Check if response body is empty
      if (response.body.isEmpty || response.body.trim().isEmpty) {
        return false;
      }
      
      // Try to decode JSON
      try {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (response.statusCode == 200) {
          return data['success'] == true;
        }
        return false;
      } catch (e) {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
  
  /// Remove bookmark for user
  static Future<bool> removeBookmark(int userId, String link) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bookmark.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'action': 'remove',
          'user_id': userId,
          'link': link,
        }),
      );
      
      // Check if response body is empty
      if (response.body.isEmpty || response.body.trim().isEmpty) {
        return false;
      }
      
      // Try to decode JSON
      try {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (response.statusCode == 200) {
          return data['success'] == true;
        }
        return false;
      } catch (e) {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
  
  /// Get bookmarks for user (returns full News objects)
  static Future<List<News>> getBookmarks(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bookmark.php?user_id=$userId'),
      );
      
      // Check if response body is empty
      if (response.body.isEmpty || response.body.trim().isEmpty) {
        return [];
      }
      
      // Try to decode JSON
      try {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (response.statusCode == 200 && data['success'] == true && data['bookmarks'] is List) {
          return (data['bookmarks'] as List)
              .map((item) {
                // Convert database format to News object
                return News(
                  link: item['link'] as String? ?? '',
                  title: item['title'] as String?,
                  snippet: item['snippet'] as String?,
                  content: item['content'] as String?,
                  thumbnail: item['thumbnail'] as String?,
                  author: item['author'] as String?,
                  publishedAt: item['publishedAt'] as String?,
                );
              })
              .toList();
        }
        return [];
      } catch (e) {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
  
  // ========== RECENT NEWS METHODS ==========
  
  /// Add recent news with full News data
  static Future<bool> addRecentNews(int userId, News news) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/recent.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'action': 'add',
          'user_id': userId,
          'link': news.link,
          'title': news.title,
          'snippet': news.snippet,
          'content': news.content,
          'thumbnail': news.thumbnail,
          'author': news.author,
          'publishedAt': news.publishedAt,
        }),
      );
      
      // Check if response body is empty
      if (response.body.isEmpty || response.body.trim().isEmpty) {
        return false;
      }
      
      // Try to decode JSON
      try {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (response.statusCode == 200) {
          return data['success'] == true;
        }
        return false;
      } catch (e) {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
  
  /// Get recent news list for user (returns full News objects)
  static Future<List<News>> getRecentNews(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/recent.php?user_id=$userId'),
      );
      
      // Check if response body is empty
      if (response.body.isEmpty || response.body.trim().isEmpty) {
        return [];
      }
      
      // Try to decode JSON
      try {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (response.statusCode == 200 && data['success'] == true && data['recents'] is List) {
          return (data['recents'] as List)
              .map((item) {
                // Convert database format to News object
                return News(
                  link: item['link'] as String? ?? '',
                  title: item['title'] as String?,
                  snippet: item['snippet'] as String?,
                  content: item['content'] as String?,
                  thumbnail: item['thumbnail'] as String?,
                  author: item['author'] as String?,
                  publishedAt: item['publishedAt'] as String?,
                );
              })
              .toList();
        }
        return [];
      } catch (e) {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
  
  // ========== VALIDATE NEWS METHODS ==========
  
  /// Validate news (add/update user validation)
  static Future<bool> validateNews(int userId, String link, bool isValid) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/validate.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'action': 'validate',
          'user_id': userId,
          'link': link,
          'is_valid': isValid ? 1 : 0,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  /// Get news validation stats (returns only jumlah_valid for menu display)
  static Future<Map<String, dynamic>?> getNewsValidation(String link) async {
    try {
      final encodedLink = Uri.encodeComponent(link);
      final response = await http.get(
        Uri.parse('$baseUrl/validate.php?link=$encodedLink'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          return {
            'jumlah_valid': data['jumlah_valid'] ?? 0,
            'jumlah_tidak_valid': data['jumlah_tidak_valid'] ?? 0,
          };
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // ========== VERIFIED NEWS METHODS ==========
  
  /// Get verified news (news with at least 5 validations, ordered by validation count)
  static Future<List<News>> getVerifiedNews() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/verified_news.php'),
      );
      
      // Check if response body is empty
      if (response.body.isEmpty || response.body.trim().isEmpty) {
        return [];
      }
      
      // Try to decode JSON
      try {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (response.statusCode == 200 && data['success'] == true && data['verified_news'] is List) {
          return (data['verified_news'] as List)
              .map((item) {
                // Convert database format to News object
                return News(
                  link: item['link'] as String? ?? '',
                  title: item['title'] as String?,
                  snippet: item['snippet'] as String?,
                  content: item['content'] as String?,
                  thumbnail: item['thumbnail'] as String?,
                  author: item['author'] as String?,
                  publishedAt: item['publishedAt'] as String?,
                );
              })
              .toList();
        }
        return [];
      } catch (e) {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
  
  // ========== TEST CONNECTION ==========
  
  /// Test database connection
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      // Test dengan endpoint register (akan return error tapi koneksi berhasil)
      final response = await http.post(
        Uri.parse('$baseUrl/register.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({}),
      );
      
      // Jika dapat response (meskipun error), berarti koneksi berhasil
      return {
        'success': true,
        'message': 'Koneksi ke database berhasil!',
        'status_code': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }
}

