import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:furniture_app/data/models/Order.dart';
import 'package:furniture_app/data/models/cart.dart';
import 'package:furniture_app/data/models/chatbot.dart';
import 'package:furniture_app/data/models/product.dart';
import 'package:furniture_app/data/repository/chatbot_repository.dart';

import 'package:get/get.dart';

import '../view/chatmessage.dart';

class ChatBotController extends GetxController {
  final TextEditingController textInput = TextEditingController();
  late MyOrder order;
  List<History> history = [];
  bool loadMess = false;

  @override
  void onInit() {
    super.onInit();
    loadDataTemplate();
  }

  Future<void> loadDataTemplate() async {
    ChatBotMessage chatBotMessage =
        await ChatBotRepository().getChatBotMessage('begin');
    ChatMessage mess = ChatMessage(
        messageContent: chatBotMessage.content,
        messageButton: chatBotMessage.contenButton,
        messageType: 'admin');
    history.insert(0, History(chatMessage: mess));
    update();
  }

  Future<void> loadDataButtonTemplate() async {
    ChatBotMessage chatBotMessage =
        await ChatBotRepository().getChatBotMessage('begin');
    ChatMessage mess = ChatMessage(
        messageContent: [],
        messageButton: chatBotMessage.contenButton,
        messageType: 'admin');
    history.insert(0, History(chatMessage: mess));
    update();
  }

  Future<void> chooseButton(String content, String id) async {
    ChatMessage mess =
        ChatMessage(messageContent: [content], messageType: 'user');
    history.insert(0, History(chatMessage: mess));
    update();

    if (id != "") {
      ChatBotMessage chatBotMessage =
          await ChatBotRepository().getChatBotMessage(id);
      ChatMessage mess = ChatMessage(
          messageContent: chatBotMessage.content,
          messageButton: chatBotMessage.contenButton,
          messageType: 'admin');
      history.insert(0, History(chatMessage: mess));
      update();
    } else {
      // Call Gemini AI API
      String apiKey = 'AIzaSyBqtlQWAQ271WPyWCijeeJVJ7wdz-CiKE4';
      String apiUrl =
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey';

      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': content}
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

        history.insert(0, History(widget: Text(aiResponse)));
        update();
      } else {
        history.insert(
            0, History(widget: Text('Failed to get response from AI')));
        update();
      }
    }
  }

  List<MyOrder> orders = [];
  List<Cart> carts = [];
  List<Product> products = [];
  List<String> status = [];
}

class History {
  Widget? widget;
  ChatMessage? chatMessage;

  History({this.widget, this.chatMessage});
}
