import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_keys.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  final String apiKey = ApiKeys.groqApiKey;
  final String groqUrl = "https://api.groq.com/openai/v1/chat/completions";

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    String userMsg = _messageController.text.trim();
    setState(() {
      _messages.add({"role": "user", "content": userMsg});
      _isLoading = true;
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse(groqUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "llama-3.1-8b-instant",
          "messages": [
            {
              "role": "system",
              "content": "You are SkinSentinel AI, a professional dermatology assistant. Provide helpful, short, and accurate skin care advice. Suggest visiting a doctor for serious issues."
            },
            ..._messages
          ],
          "temperature": 0.7,
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          _messages.add({
            "role": "assistant",
            "content": data['choices'][0]['message']['content'].toString().trim()
          });
        });
      } else {
        _showErrorSnippet("Server Busy. Please try again.");
      }
    } catch (e) {
      _showErrorSnippet("Connection timeout. Check your internet.");
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _showErrorSnippet(String msg) {
    setState(() {
      _messages.add({"role": "assistant", "content": "⚠️ $msg"});
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Check Theme Mode
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // ✅ Dynamic Background
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("AI MEDICAL ASSISTANT",
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: isDarkMode ? Colors.cyanAccent : Colors.cyan[800]
            )),
        // ✅ Dynamic AppBar Color
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDarkMode ? Colors.white : Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                bool isUser = _messages[index]['role'] == "user";
                return _buildChatBubble(isUser, _messages[index]['content']!, isDarkMode);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(color: Colors.cyanAccent, strokeWidth: 2),
              ),
            ),
          _buildInputArea(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildChatBubble(bool isUser, String content, bool isDark) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(15),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          // ✅ Dynamic Bubble Colors
          color: isUser
              ? Colors.cyanAccent.withOpacity(isDark ? 0.1 : 0.2)
              : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200]),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 20),
          ),
          border: Border.all(
              color: isUser
                  ? Colors.cyanAccent.withOpacity(0.3)
                  : (isDark ? Colors.white12 : Colors.black12)
          ),
        ),
        child: Text(
          content,
          style: TextStyle(
            // ✅ Dynamic Text Color
              color: isUser
                  ? (isDark ? Colors.cyanAccent : Colors.cyan[900])
                  : (isDark ? Colors.white : Colors.black87),
              fontSize: 14,
              height: 1.4
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.5 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5)
          )
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(25)
                ),
                child: TextField(
                  controller: _messageController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: "Describe skin issue...",
                    hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black38),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _sendMessage,
              child: CircleAvatar(
                backgroundColor: isDark ? Colors.cyanAccent : Colors.cyan[700],
                radius: 22,
                child: Icon(Icons.send_rounded, color: isDark ? Colors.black : Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}