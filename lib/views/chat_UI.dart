import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class ChatUI extends StatefulWidget {
  const ChatUI({super.key});

  @override
  State<ChatUI> createState() => _ChatUIState();
}

class _ChatUIState extends State<ChatUI> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  final ScrollController _scrollController = ScrollController();

  Future<void> sendMessage(String text) async {
    if (text.isEmpty) return;
    setState(() {
      messages.add({'user': 'You', 'text': text});
      scrollbehaviour();

      print(messages);
    });
    _controller.clear();
    await getBotResponse(text);
  }

  Future<void> getBotResponse(String userMessage) async {
    setState(() {
      messages.add({'user': 'Bot', 'text': 'Typing...'});
      scrollbehaviour();
    });

    var apiKey = "AIzaSyAXaTSf0HDiVJlr3_HuRM_zo82PxJ5CJpo";
    var body = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text":
                  '''the following question is asked by a user who is in my medicine app and you have to answer this question like a chatbot particlarly integrated for this app also keep track if the user is asking a question related to the previous one he asked the question is in the end first go through rules   .. RULES YOU SHOULD FOLLOW IN ASWERING THE QUESTION --> NOTICE: the answer should be to the point and make sure you donot give reference of this prompt engineering . firstly make sure NOT to use "**" to show bold rather where bolding the text is necessary you just write that particular text in capital case  . Notice:"DONT WRITE YOU COMPLETE RESPONSE IN CAPITAL CASE ONLY BOLD WORDS". if user asks any question other than regarding "medicine" or "health" or "pharmacueticals" or anything regards to medicine brands etc , just answer by saying "Sorry!. this bot is integrated to answer medicine & health related questions .... \n question is : $userMessage} " '''
            }
          ]
        }
      ]
    };
    var url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent?key=$apiKey');

    try {
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body));

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        setState(() {
          messages.removeLast();
          messages.add({
            'user': 'Bot',
            'text': result["candidates"][0]['content']["parts"][0]["text"]
          });
          scrollbehaviour();
        });
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        messages.removeLast();
        messages.add({
          'user': 'Bot',
          'text': 'Error getting response. Please try again \n Error ${e}'
        });
        scrollbehaviour();
      });
    }
  }

  Widget _buildMessage(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          gradient: isUser
              ? LinearGradient(
                  colors: [Colors.blue[100]!, Colors.purple[100]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    Colors.grey[200]!,
                    Colors.grey[400]!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Text(
          text,
          style: TextStyle(color: isUser ? Colors.black : Colors.black87),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    messages.add({
      'user': 'Bot',
      'text':
          'hey! welcome to our medical store \n this is a AI integrated ChatBot that will answer your queries \n you can ask questions like : \n - how much dosage risek 20 should i take? \n- What are the side effects of Panadol? \n- How should I take my antibiotics?  '
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
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset("assets/medbot_Logo.png"),
            ),
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                bool isUser = messages[index]['user'] == 'You';
                return _buildMessage(messages[index]['text']!, isUser);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(
                        foreground: Paint()
                          ..shader = const LinearGradient(
                            colors: <Color>[
                              Colors.blue,
                              Colors.purple,
                            ],
                          ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          color: Colors
                              .black, // Default border color (used as fallback)
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
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    sendMessage(_controller.text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  scrollbehaviour() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }
}
