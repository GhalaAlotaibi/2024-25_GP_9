import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatbotUI extends StatefulWidget {
  @override
  _ChatbotUIState createState() => _ChatbotUIState();
}

class _ChatbotUIState extends State<ChatbotUI> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  final String _apiUrl = "http://10.0.2.2:5000/chat"; // Android emulator
  // final String _apiUrl = "https://your-deployed-api.com/chat"; // Production

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: _controller.text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    final userMessage = _controller.text;
    _controller.clear();

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'query': userMessage}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _messages.add(ChatMessage(
            text: data['response'],
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
      } else {
        _showError("API Error: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Connection failed: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: false,
        isError: true,
        timestamp: DateTime.now(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline,
                color: const Color.fromARGB(255, 56, 47, 47)),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(8),
              reverse: false,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isUser
              ? Color(0xFFE0E0E0)
              : (message.isError
                  ? Colors.red[100]
                  : Color.fromARGB(255, 203, 176, 227)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: message.isUser
            ? Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.black : Colors.white,
                  fontSize: 16,
                ),
                textDirection: TextDirection.rtl, // For Arabic support
              )
            : Align(
                alignment: Alignment.centerRight, // محاذاة النص لليمين
                child: MarkdownBody(
                  data: message.text, // يعرض النص باستخدام Markdown
                  selectable: true,
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textDirection: TextDirection.rtl, // Arabic direction
              textAlign: TextAlign.right, // ✅ Align text and hint to the right
              decoration: InputDecoration(
                hintText: '...اكتب رسالتك هنا',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(width: 8),
          _isLoading
              ? CircularProgressIndicator()
              : IconButton(
                  icon: Icon(Icons.send, color: Color(0xFF674188)),
                  onPressed: _sendMessage,
                ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "عن الشات بوت",
          textDirection: TextDirection.rtl,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "هذا شات بوت يساعدك تطبخ! 🍳\n\nاسأله عن أي وصفة وهو بيرد عليك بالمكونات وطريقة التحضير خطوة بخطوة.",
          textDirection: TextDirection.rtl,
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            child: Text("تم", textDirection: TextDirection.rtl),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });
}
