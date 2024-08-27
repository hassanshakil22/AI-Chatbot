import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

ChatUser sender = ChatUser(
  id: "User",
  firstName: "user",
);
ChatUser bot = ChatUser(
  id: "MedBot",
  firstName: "MedBot",
);

class _ChatScreenState extends State<ChatScreen> {
  List<ChatMessage> messages = [
    ChatMessage(
        user: bot,
        createdAt: DateTime.now(),
        text:
            "hey! welcome to our medical store \n this is a AI integrated ChatBot that will answer your queries \n you can ask questions like : \n - how much dosage risek 20 should i take? \n- What are the side effects of Panadol? \n- How should I take my antibiotics?   "),
  ];
  List<ChatUser> typingUsers = [];
  var apiKey = "AIzaSyAXaTSf0HDiVJlr3_HuRM_zo82PxJ5CJpo";

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
            {
              "text":
                  '''the following question is asked by a user who is in my medicine app and you have to answer this question like a chatbot particlarly integrated for this app also keep track if the user is asking a question related to the previous one he asked the question is in the end first go through rules .. RULES YOU SHOULD FOLLOW IN ASWERING THE QUESTION --> NOTICE: the answer should be to the point and make sure you donot give reference of this prompt engineering . firstly make sure NOT to use "**" to show bold rather where bolding the text is necessary you just write that particular text in capital case  . Notice:"DONT WRITE YOU COMPLETE RESPONSE IN CAPITAL CASE ONLY BOLD WORDS". if user asks any question other than regarding "medicine" or "health" or "pharmacueticals" , just answer by saying "Sorry!. this bot is integrated to answer medicine & health related questions .... \n question is : ${message.text} "  '''
            }
          ]
        }
      ]
    };
    var result;
    var url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent?key=$apiKey');
    await http
        .post(url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body))
        .then((value) async {
      if (value.statusCode == 200) {
        result = await jsonDecode(value.body);
        print(result);
      } else {
        print("error occured --> statusCode ${value.statusCode}");
      }
    }).catchError((e) {
      print(e);
    });

    ChatMessage botMessage = ChatMessage(
        user: bot,
        createdAt: DateTime.now(),
        text: result["candidates"][0]['content']["parts"][0]["text"]);
    setState(() {
      typingUsers.remove(bot);

      messages.insert(0, botMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.grey[200]!,
                Colors.grey[400]!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent, // Transparent to show gradient
            title: Text(
              'MedBot',
              style: TextStyle(
                foreground: Paint()
                  ..shader = LinearGradient(
                    colors: <Color>[
                      Colors.blue,
                      Colors.purple,
                    ],
                  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
              ),
            ),
            centerTitle: true,
          ),
        ),
      ),
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
            borderSide: const BorderSide(
              color: Colors.black, // Default border color (used as fallback)
              width: 2.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(
              color: Colors.black, // Border color when not focused
              width: 2.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(
              color: Colors.blue, // Border color when focused
              width: 2.0,
            ),
          ),
          hintText: 'ask anything? ',
          hintStyle: TextStyle(
            foreground: Paint()
              ..shader = LinearGradient(
                colors: <Color>[
                  Colors.blue,
                  Colors.purple,
                ],
              ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
          ),
        )),
        messageOptions: MessageOptions(
          showTime: true,
          messageDecorationBuilder: (message, previousMessage, nextMessage) {
            return BoxDecoration(
              gradient: LinearGradient(
                  colors: message.user.id == 'User'
                      ? [Colors.blue[100]!, Colors.purple[100]!]
                      : [Colors.grey[200]!, Colors.grey[400]!]),
              borderRadius: BorderRadius.circular(16.0),
            );
          },
          messageTextBuilder: (message, previousMessage, nextMessage) {
            return message.user.id == 'User'
                ? Text(
                    message.text,
                    style: TextStyle(
                      foreground: Paint()
                        ..shader = LinearGradient(
                          colors: <Color>[
                            Colors.blue,
                            Colors.purple[900]!,
                          ],
                        ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                    ),
                  )
                : Text(message.text);
          },
        ),
      ),
    );
  }
}
