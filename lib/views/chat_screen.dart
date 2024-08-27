import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ChatMessage> messages = [];
  List<ChatUser> typingUsers = [];
  var apiKey = "AIzaSyAXaTSf0HDiVJlr3_HuRM_zo82PxJ5CJpo";

  ChatUser sender = ChatUser(
    id: "User",
    firstName: "user",
  );
  ChatUser bot = ChatUser(
    id: "Bot",
    firstName: "Bot",
  );

  getResponse(ChatMessage message) async {
    setState(() {
      messages.insert(0, message);
      typingUsers.add(bot);
    });
    Map<String, List> body = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {"text": message.text}
          ]
        }
      ]
    };
    Map<String, dynamic> result = {};
    var url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent?key=${apiKey}');
    await http
        .post(url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body))
        .then((value) {
      if (value.statusCode == 200) {
        result = jsonDecode(value.body);
      } else {
        print("error occured --> statusCode ${value.statusCode}");
      }
    }).catchError((e) {
      print(e);
    });

    ChatMessage botMessage = ChatMessage(
        user: bot,
        createdAt: DateTime.now(),
        text: result["candidates"]![0]['content']["parts"][0]["text"]);
    setState(() {
      typingUsers.remove(bot);

      messages.insert(0, botMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: DashChat(
        currentUser: sender,
        onSend: (ChatMessage message) {
          getResponse(message);
        },
        messages: messages,
        typingUsers: typingUsers,
        inputOptions: InputOptions(
            inputDecoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(
              color: Colors.black, // Default border color (used as fallback)
              width: 2.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(
              color: Colors.black, // Border color when not focused
              width: 2.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(
              color: Colors.blue, // Border color when focused
              width: 2.0,
            ),
          ),
          hintText: 'ask anything? ',
          hintStyle: const TextStyle(color: Colors.grey),
        )),
        messageOptions: MessageOptions(showTime: true),
      ),
    );
  }
}
