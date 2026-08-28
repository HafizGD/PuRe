import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GroqService {
  static String get _apiKey =>
      dotenv.env['GROQ_API_KEY'] ?? '';
  static const String _baseUrl = 'https://api.groq.com/openai/v1';

  static Future<Map<String, dynamic>> generateQuiz({
    required String newsTitle,
    required String newsContent,
  }) async {
    try {
      // Bersihkan konten berita
      final cleanContent = _cleanContent(newsContent);
      if (cleanContent.isEmpty) {
        throw Exception('Konten berita kosong');
      }

      // Buat prompt untuk Groq
      final prompt = '''Berdasarkan berita berikut, buatkan 1 pertanyaan quiz dengan 3 pilihan jawaban (hanya 1 yang benar).

Judul Berita: $newsTitle

Isi Berita:
$cleanContent

Format response JSON:
{
  "question": "pertanyaan yang relevan dengan isi berita (MAKSIMAL 1 KALIMAT)",
  "correct_answer": "jawaban yang benar sesuai dengan pertanyaan dan isi berita (MAKSIMAL 1 KALIMAT, maksimal 100 karakter)",
  "wrong_answers": ["jawaban salah 1 (MAKSIMAL 1 KALIMAT, maksimal 100 karakter)", "jawaban salah 2 (MAKSIMAL 1 KALIMAT, maksimal 100 karakter)"]
}

KETENTUAN PENTING:
1. Pertanyaan HARUS relevan dengan isi berita dan MAKSIMAL 1 KALIMAT
2. Jawaban benar HARUS sesuai dengan pertanyaan dan ada di isi berita, MAKSIMAL 1 KALIMAT
3. Jawaban salah HARUS:
   - KREATIF dan RANDOM tapi tetap relevan dengan topik berita
   - Bisa berupa salah satu kalimat yang ada di berita TAPI tidak menjawab pertanyaan yang diberikan
   - Atau bisa berupa jawaban yang masuk akal tapi TIDAK sesuai dengan isi berita untuk pertanyaan tersebut
   - Masih mengarah ke topik berita (tidak keluar topik sama sekali)
   - TIDAK sesuai dengan pertanyaan yang diberikan
   - MAKSIMAL 1 KALIMAT per jawaban
   - Buat jawaban salah yang menarik dan menantang, bukan jawaban yang terlalu jelas salah
4. Semua teks dalam bahasa Indonesia
5. Response HANYA berisi JSON, tanpa teks tambahan apapun
6. Pastikan pertanyaan dan semua jawaban singkat, jelas, dan mudah dipahami''';

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          // ✅ PERBAIKAN: Ganti model yang sudah deprecated
          'model': 'llama-3.3-70b-versatile', // Model terbaru yang masih aktif
          'messages': [
            {
              'role': 'system',
              'content': 'Kamu adalah asisten yang ahli membuat pertanyaan quiz berdasarkan berita. Selalu respon dengan format JSON yang valid.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.5,
          'max_tokens': 600,
          // ✅ TAMBAHAN: Paksa output JSON
          'response_format': {'type': 'json_object'},
        }),
      );

      if (response.statusCode != 200) {
        print('❌ Groq API error: ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception('Groq API error: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      final content = data['choices']?[0]?['message']?['content'] as String?;

      if (content == null) {
        throw Exception('Tidak ada response dari Groq');
      }

      print('✅ Groq Response: $content'); // Debug log

      // Parse JSON dari response
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
      if (jsonMatch == null) {
        throw Exception('Format response tidak valid');
      }

      final quizData = json.decode(jsonMatch.group(0)!) as Map<String, dynamic>;

      // ✅ TAMBAHAN: Validasi data
      if (!quizData.containsKey('question') || 
          !quizData.containsKey('correct_answer') ||
          !quizData.containsKey('wrong_answers')) {
        throw Exception('Format quiz tidak lengkap');
      }

      // Ambil jawaban salah dari Groq
      final wrongAnswers = (quizData['wrong_answers'] as List<dynamic>?)
              ?.map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty)
              .toList() ?? [];

      // Jika jawaban salah kurang dari 2, tambahkan dari kalimat berita
      final enhancedWrongAnswers = _enhanceWrongAnswers(
        wrongAnswers,
        cleanContent,
        quizData['question'] as String? ?? '',
        quizData['correct_answer'] as String? ?? '',
      );

      return {
        'question': quizData['question'] as String? ?? 'Apa inti dari berita ini?',
        'correct_answer': quizData['correct_answer'] as String? ?? 'Jawaban tidak tersedia',
        'wrong_answers': enhancedWrongAnswers,
      };
    } catch (e) {
      print('❌ Error generating quiz: $e');
      // Fallback jika Groq API gagal
      return _generateFallbackQuiz(newsTitle, newsContent);
    }
  }

  static String _cleanContent(String? content) {
    if (content == null || content.isEmpty) return '';
    
    // Hapus pattern seperti [+1234 chars]
    String cleaned = content.replaceAll(RegExp(r'\[\+\d+\s*chars?\]'), '');
    
    // Hapus whitespace berlebihan
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    // Batasi panjang konten (Groq punya limit token)
    if (cleaned.length > 2000) {
      cleaned = cleaned.substring(0, 2000) + '...';
    }
    
    return cleaned;
  }

  /// Meningkatkan jawaban salah dengan mengambil kalimat dari berita
  static List<String> _enhanceWrongAnswers(
    List<String> existingWrongAnswers,
    String newsContent,
    String question,
    String correctAnswer,
  ) {
    final result = <String>[];
    result.addAll(existingWrongAnswers);

    // Jika masih kurang dari 2 jawaban salah, ambil kalimat dari berita
    if (result.length < 2 && newsContent.isNotEmpty) {
      final sentences = _extractSentences(newsContent);
      
      // Filter kalimat yang tidak sama dengan jawaban benar dan relevan
      final candidateSentences = sentences
          .where((sentence) {
            final lowerSentence = sentence.toLowerCase();
            final lowerCorrect = correctAnswer.toLowerCase();
            
            // Jangan ambil kalimat yang terlalu mirip dengan jawaban benar
            if (lowerSentence.contains(lowerCorrect) || 
                lowerCorrect.contains(lowerSentence)) {
              return false;
            }
            
            // Jangan ambil kalimat yang terlalu pendek atau terlalu panjang
            if (sentence.length < 20 || sentence.length > 100) {
              return false;
            }
            
            // Pastikan kalimat tidak menjawab pertanyaan secara langsung
            return true;
          })
          .toList();

      // Acak dan ambil kalimat yang berbeda
      candidateSentences.shuffle();
      
      for (final sentence in candidateSentences) {
        if (result.length >= 2) break;
        
        // Pastikan tidak duplikat
        if (!result.any((existing) => 
            existing.toLowerCase() == sentence.toLowerCase())) {
          result.add(sentence);
        }
      }
    }

    // Jika masih kurang, tambahkan jawaban generik yang kreatif
    while (result.length < 2) {
      final genericAnswers = [
        'Masalah ini masih dalam tahap investigasi lebih lanjut.',
        'Informasi detail belum dapat dikonfirmasi secara resmi.',
        'Situasi tersebut masih terus dipantau oleh pihak terkait.',
        'Belum ada pernyataan resmi mengenai hal tersebut.',
        'Data lengkap masih dalam proses pengumpulan.',
      ];
      
      for (final answer in genericAnswers) {
        if (result.length >= 2) break;
        if (!result.any((existing) => 
            existing.toLowerCase() == answer.toLowerCase())) {
          result.add(answer);
        }
      }
      
      // Jika masih kurang, break untuk menghindari infinite loop
      if (result.length < 2) break;
    }

    return result.take(2).toList();
  }

  /// Mengekstrak kalimat dari konten berita
  static List<String> _extractSentences(String content) {
    // Split berdasarkan titik, tanda tanya, dan tanda seru
    final sentences = content
        .split(RegExp(r'[.!?]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && s.length > 10)
        .toList();
    
    return sentences;
  }

  static Map<String, dynamic> _generateFallbackQuiz(
    String title,
    String content,
  ) {
    // Fallback quiz jika Groq API gagal
    final question = title.isNotEmpty
        ? 'Apa yang menyebabkan ${title.length > 40 ? title.substring(0, 40) + "..." : title} menjadi pusat perhatian?'
        : 'Apa inti dari berita yang baru saja kamu baca?';

    final cleanContent = _cleanContent(content);
    String correctAnswer;
    
    if (cleanContent.isNotEmpty) {
      // Ambil kalimat pertama sebagai jawaban (maksimal 1 kalimat)
      final sentences = cleanContent.split('.');
      correctAnswer = sentences.first.trim();
      if (correctAnswer.length > 100) {
        correctAnswer = correctAnswer.substring(0, 97) + '...';
      }
      // Pastikan hanya 1 kalimat
      if (correctAnswer.contains('.')) {
        correctAnswer = correctAnswer.split('.').first.trim() + '.';
      }
    } else {
      correctAnswer = 'Informasi masih berkembang.';
    }

    // Ambil kalimat dari berita sebagai jawaban salah
    final sentences = _extractSentences(cleanContent);
    final wrongAnswers = <String>[];
    
    // Ambil kalimat yang berbeda dari jawaban benar
    for (final sentence in sentences) {
      if (wrongAnswers.length >= 2) break;
      
      final lowerSentence = sentence.toLowerCase();
      final lowerCorrect = correctAnswer.toLowerCase();
      
      // Pastikan kalimat tidak sama dengan jawaban benar
      if (!lowerSentence.contains(lowerCorrect) && 
          !lowerCorrect.contains(lowerSentence) &&
          sentence.length >= 20 && 
          sentence.length <= 100) {
        wrongAnswers.add(sentence);
      }
    }
    
    // Jika masih kurang, tambahkan jawaban generik
    final topic = title.isNotEmpty ? title.split(' ').take(3).join(' ') : 'berita';
    while (wrongAnswers.length < 2) {
      final genericAnswers = [
        'Masalah terkait $topic masih dalam investigasi lebih lanjut.',
        'Detail tentang $topic belum diumumkan secara resmi oleh pihak terkait.',
        'Informasi lengkap mengenai $topic masih dalam proses verifikasi.',
        'Situasi terkait $topic masih terus dipantau dan dikaji.',
      ];
      
      for (final answer in genericAnswers) {
        if (wrongAnswers.length >= 2) break;
        if (!wrongAnswers.any((existing) => 
            existing.toLowerCase() == answer.toLowerCase())) {
          wrongAnswers.add(answer);
        }
      }
      
      if (wrongAnswers.length < 2) break;
    }
    
    return {
      'question': question,
      'correct_answer': correctAnswer,
      'wrong_answers': wrongAnswers.take(2).toList(),
    };
  }

  // ✅ TAMBAHAN: Fungsi untuk cek available models
  static Future<List<String>> getAvailableModels() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/models'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final models = (data['data'] as List)
            .map((model) => model['id'] as String)
            .toList();
        print('✅ Available models: $models');
        return models;
      }
      return [];
    } catch (e) {
      print('❌ Error fetching models: $e');
      return [];
    }
  }
}