import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:tracki/Utils/constants.dart';
import 'package:tracki/widgets/my_icon_button.dart';

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
      backgroundColor: kbackgroundColor,
      appBar: AppBar(
        backgroundColor: kbackgroundColor,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 8),
          child: IconButton(
            icon: Icon(Icons.info_outline, color: Colors.black),
            onPressed: () => _showInfoDialog(context),
          ),
        ),
        actions: [
          MyIconButton(
            icon: Icons.arrow_forward_ios,
            pressed: () {
              Navigator.pop(context);
            },
          ),
        ],
        title: Text(
          'مساعد الطبخ الذكي',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
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
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    final RenderBox appBarBox = context.findRenderObject() as RenderBox;
    final position = appBarBox.localToGlobal(Offset.zero);

    showDialog(
      context: context,
      builder: (context) => Stack(
        children: [
          Positioned(
            top: position.dy + kToolbarHeight + 8, // Below app bar
            left: 16, // Left margin
            child: Material(
              color: Colors.transparent,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          "عن مساعد الطبخ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Divider(height: 1),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "هذا شات بوت يساعدك تطبخ! 🍳",
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "اسأله عن أي وصفة وهو بيرد عليك بالمكونات وطريقة التحضير خطوة بخطوة.",
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("تم"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment:
            CrossAxisAlignment.end, // Align avatars with message bottom
        children: message.isUser
            ? [
                // User message layout (right side)
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: kBannerColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(0),
                      ),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ),
                SizedBox(width: 8),
              ]
            : [
                // Bot message layout (left side)
                CircleAvatar(
                  radius: 21,
                  backgroundImage: AssetImage('assets/images/chatbotChef.png'),
                ),
                SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: message.isError ? Colors.red[100] : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(18),
                      ),
                    ),
                    child: MarkdownBody(
                      data: message.text,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(color: Colors.black87, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.all(8),
      color: kbackgroundColor,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: '...اكتب رسالتك هنا',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  _isLoading
                      ? Padding(
                          padding: EdgeInsets.all(8),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: Icon(Icons.send, color: Color(0xFF674188)),
                          onPressed: _sendMessage,
                        ),
                ],
              ),
            ),
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
