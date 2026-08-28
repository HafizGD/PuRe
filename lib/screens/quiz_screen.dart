import 'package:flutter/material.dart';
import '../models/news.dart';
import '../services/groq_service.dart';
import 'dart:math';

class QuizScreen extends StatefulWidget {
  final News news;
  final VoidCallback? onFinish;

  const QuizScreen({
    Key? key,
    required this.news,
    this.onFinish,
  }) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  _QuizContent? _content;
  bool _showAnswer = false;
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedAnswer;
  bool? _isCorrect;

  @override
  void initState() {
    super.initState();
    _loadQuizContent();
  }

  Future<void> _loadQuizContent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final newsTitle = widget.news.title ?? 'Berita';
      final newsContent = widget.news.content ?? widget.news.snippet ?? '';

      print('🔍 Loading quiz for: $newsTitle');

      final quizData = await GroqService.generateQuiz(
        newsTitle: newsTitle,
        newsContent: newsContent,
      );

      print('✅ Quiz data received: $quizData');

      if (mounted) {
        setState(() {
          _content = _QuizContent(
            question: quizData['question'] as String,
            correctAnswer: quizData['correct_answer'] as String,
            options: _buildShuffledOptions(
              quizData['correct_answer'] as String,
              (quizData['wrong_answers'] as List<dynamic>)
                  .map((e) => e.toString())
                  .toList(),
            ),
          );
          _isLoading = false;
        });
        
        print('✅ Quiz content loaded: ${_content!.question}');
      }
    } catch (e) {
      print('❌ Error loading quiz: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat quiz: ${e.toString()}';
          _isLoading = false;
          _content = _buildFallbackQuizContent(widget.news);
        });
      }
    }
  }

  List<String> _buildShuffledOptions(String correctAnswer, List<String> wrongAnswers) {
    final options = <String>[correctAnswer];
    
    for (int i = 0; i < wrongAnswers.length && options.length < 3; i++) {
      if (wrongAnswers[i].trim().isNotEmpty) {
        options.add(wrongAnswers[i]);
      }
    }
    
    while (options.length < 3) {
      options.add('Informasi masih berkembang');
    }
    
    options.shuffle(Random());
    
    print('✅ Options shuffled: $options');
    return options;
  }

  void _handleAnswerTap(String option) {
    if (_showAnswer) return;
    
    print('👆 Answer tapped: $option');
    
    final isCorrect = option == _content!.correctAnswer;
    
    setState(() {
      _selectedAnswer = option;
      _isCorrect = isCorrect;
      _showAnswer = true;
    });
    
    print('✅ Answer result: ${isCorrect ? "CORRECT" : "WRONG"}');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCorrect ? '✅ Jawaban benar!' : '❌ Jawaban salah',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isCorrect 
            ? Colors.green 
            : Colors.red,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading 
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Membuat pertanyaan quiz...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            )
          : _content == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage ?? 'Tidak dapat memuat quiz',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF757575),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadQuizContent,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      const Text(
                        'Quiz',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1E1E1E),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Text(
                        'Puzzle & Reasoning',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF757575),
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Title
                      const Text(
                        'Quiz!',
                        style: TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E1E1E),
                          letterSpacing: -0.03,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Content
                      if (!_showAnswer) 
                        _buildQuestionSection() 
                      else 
                        _buildAnswerSection(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildQuestionSection() {
    if (_content == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pertanyaannya:',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E1E1E),
            height: 1.27,
          ),
        ),
        const SizedBox(height: 16),
        
         // Kotak pertanyaan - fleksibel dengan softWrap
         Container(
           width: double.infinity,
           padding: const EdgeInsets.all(20),
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
           child: Text(
             _content!.question,
             style: const TextStyle(
               fontSize: 16,
               fontWeight: FontWeight.w500,
               color: Color(0xFF1E1E1E),
               height: 1.5,
               letterSpacing: 0.15,
             ),
             textAlign: TextAlign.center,
             softWrap: true,
             maxLines: null,
             overflow: TextOverflow.visible,
           ),
         ),
        const SizedBox(height: 24),
        
        // Opsi jawaban - SANGAT SIMPLE
        ...List.generate(_content!.options.length, (index) {
          final option = _content!.options[index];
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () {
                print('🔥 TAP DETECTED: $option');
                _handleAnswerTap(option);
              },
              behavior: HitTestBehavior.opaque, // ✅ PENTING!
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.black.withOpacity(0.11),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                 child: Text(
                   option,
                   style: const TextStyle(
                     fontSize: 14,
                     fontWeight: FontWeight.w500,
                     color: Color(0xFF1E1E1E),
                     height: 1.4,
                   ),
                   textAlign: TextAlign.center,
                   softWrap: true,
                   maxLines: null,
                   overflow: TextOverflow.visible,
                 ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAnswerSection() {
    if (_content == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pertanyaan
        Text(
          _content!.question,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E1E1E),
            height: 1.4,
          ),
          textAlign: TextAlign.center,
          softWrap: true,
          maxLines: null,
          overflow: TextOverflow.visible,
        ),
        const SizedBox(height: 24),
        
        // Feedback
        if (_selectedAnswer != null && _isCorrect != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isCorrect! 
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isCorrect! ? Colors.green : Colors.red,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isCorrect! ? Icons.check_circle : Icons.cancel,
                  color: _isCorrect! ? Colors.green : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _isCorrect! 
                        ? 'Jawabanmu benar! 🎉'
                        : 'Jawabanmu salah 😔',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _isCorrect! ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        
        const Text(
          'Jawaban yang benar:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF757575),
          ),
        ),
        const SizedBox(height: 8),
        
        // Jawaban benar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.green,
              width: 2,
            ),
          ),
           child: Text(
             _content!.correctAnswer,
             style: const TextStyle(
               fontSize: 14,
               fontWeight: FontWeight.w600,
               color: Color(0xFF1E1E1E),
               height: 1.4,
             ),
             textAlign: TextAlign.center,
             softWrap: true,
             maxLines: null,
             overflow: TextOverflow.visible,
           ),
        ),
        const SizedBox(height: 24),
        
        // Tombol selesai
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (widget.onFinish != null) {
                widget.onFinish!();
              } else {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Selesai',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  _QuizContent _buildFallbackQuizContent(News news) {
    final title = news.title?.trim();
    final content = _cleanText(news.content);
    final snippet = _cleanText(news.snippet);

    final question = (title != null && title.isNotEmpty)
        ? 'Apa inti dari berita: ${title.length > 50 ? title.substring(0, 50) + "..." : title}?'
        : 'Apa inti dari berita yang baru saja kamu baca?';

    String answer;
    if (content.isNotEmpty) {
      answer = _shorten(content, maxLength: 80);
    } else if (snippet.isNotEmpty) {
      answer = _shorten(snippet, maxLength: 80);
    } else {
      answer = 'Informasi masih berkembang';
    }

    final options = _buildShuffledOptions(
      answer,
      [
        'Belum ada konfirmasi resmi',
        'Situasi masih terus dipantau',
      ],
    );

    return _QuizContent(
      question: question,
      correctAnswer: answer,
      options: options,
    );
  }

  String _cleanText(String? value) {
    if (value == null) return '';
    return value.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _shorten(String text, {int maxLength = 200}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }
}

class _QuizContent {
  final String question;
  final String correctAnswer;
  final List<String> options;

  const _QuizContent({
    required this.question,
    required this.correctAnswer,
    required this.options,
  });
}