import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';


import 'package:get/get.dart';

import '../view/chatmessage.dart';

class ChatBotController extends GetxController {
  final TextEditingController textInput = TextEditingController();
  List<History> history = [];
  bool loadMess = false;

  // Map lưu các câu trả lời mẫu
  final Map<String, Map<String, dynamic>> chatData = {
    'begin': {
      'content': ['Chào bạn, tôi có thể giúp gì cho bạn?'],
      'button': {
        'Giá sản phẩm': 'step1',
        'Chính sách bảo hành': 'step2',
      },
    },
    'step1': {
      'content': ['Giá sản phẩm được hiển thị trong danh mục.'],
      'button': {
        'Trở về': 'begin',
      },
    },
    'step2': {
      'content': ['Chính sách bảo hành là 12 tháng.'],
      'button': {
        'Trở về': 'begin',
      },
    },
  };

  @override
  void onInit() {
    super.onInit();
    loadDataTemplate('begin');
  }

  // Tải dữ liệu mẫu từ Map
  void loadDataTemplate(String id) {
    final data = chatData[id];
    if (data != null) {
      final ChatMessage message = ChatMessage(
        messageContent: List<String>.from(data['content']),
        messageButton: Map<String, String>.from(data['button']),
        messageType: 'admin',
      );
      history.insert(0, History(chatMessage: message));
      update();
    }
  }

  // Xử lý khi người dùng nhấn vào nút
  Future<void> chooseButton(String content, String id) async {
    // Thêm câu hỏi của người dùng vào lịch sử
    final userMessage = ChatMessage(
      messageContent: [content],
      messageType: 'user',
    );
    history.insert(0, History(chatMessage: userMessage));
    update();

    // Nếu ID tồn tại trong Map, hiển thị nội dung từ Map
    if (id.isNotEmpty && chatData.containsKey(id)) {
      loadDataTemplate(id);
    } else {
      // Nếu không, gọi API Gemini
      await fetchResponseFromGemini(content);
    }
  }

  // Gọi API Gemini nếu không có câu trả lời mẫu
  Future<void> fetchResponseFromGemini(String userInput) async {
    loadMess = true; // Bật trạng thái loading
    update();

    String apiKey = 'AIzaSyBqtlQWAQ271WPyWCijeeJVJ7wdz-CiKE4';
    String apiUrl =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': userInput}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.9,
            'topK': 1,
            'topP': 1,
            'maxOutputTokens': 2048,
            'stopSequences': []
          },
          'safetySettings': []
        }),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        String aiResponse =
        jsonResponse['candidates'][0]['content']['parts'][0]['text'];

        final aiMessage = ChatMessage(
          messageContent: [aiResponse],
          messageType: 'admin',
        );
        history.insert(0, History(chatMessage: aiMessage));
      } else {
        history.insert(
          0,
          History(widget: const Text('Failed to get response from AI')),
        );
      }
    } catch (e) {
      history.insert(
        0,
        History(widget: const Text('An error occurred while calling AI.')),
      );
    }

    loadMess = false; // Tắt trạng thái loading
    update();
  }


}

class History {
  Widget? widget;
  ChatMessage? chatMessage;

  History({this.widget, this.chatMessage});
}
