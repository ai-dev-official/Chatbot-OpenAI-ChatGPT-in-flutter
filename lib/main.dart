import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'constant.dart';
import 'model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ChatPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

const backgroundColor = Color(0xffe11d48);
const botBackgroundColor = Color(0xff444654);
const chatBackgroundColor = Color(0xff737373);
const inputBackgroundColor = Color(0xff6b7280);

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

Future<String> generateResponse(String prompt) async {
  const apiKey = apiSecretKey;

  var url = Uri.https("api.openai.com", "/v1/completions");
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $apiKey"
    },
    body: json.encode({
      "model": "text-davinci-003",
      "prompt": prompt,
      'temperature': 0,
      'max_tokens': 2000,
      'top_p': 1,
      'frequency_penalty': 0.0,
      'presence_penalty': 0.0,
    }),
  );

  // Do something with the response
  Map<String, dynamic> newresponse = jsonDecode(response.body);

  return newresponse['choices'][0]['text'];
}

class _ChatPageState extends State<ChatPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  late bool isLoading;

  @override
  void initState() {
    super.initState();
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
       decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blueGrey.shade800.withOpacity(0.9),
            Colors.blueGrey.shade50.withOpacity(0.9),
          ]
          ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
       appBar: const  _CustomAppBar(),
        // backgroundColor: backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: _buildList(),
              ),
              Visibility(
                visible: isLoading,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    _buildInput(),
                    _buildSubmit(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmit() {
    return Visibility(
      visible: !isLoading,
      child: Container(
        color: inputBackgroundColor,
        child: IconButton(
          icon: const Icon(
            Icons.send_rounded,
            color: Color(0xff22c55e),
          ),
          onPressed: () async {
            setState(
              () {
                _messages.add(
                  ChatMessage(
                    text: _textController.text,
                    chatMessageType: ChatMessageType.user,
                  ),
                );
                isLoading = true;
              },
            );
            var input = _textController.text;
            _textController.clear();
            Future.delayed(const Duration(milliseconds: 50))
                .then((_) => _scrollDown());
            generateResponse(input).then((value) {
              setState(() {
                isLoading = false;
                _messages.add(
                  ChatMessage(
                    text: value,
                    chatMessageType: ChatMessageType.bot,
                  ),
                );
              });
            });
            _textController.clear();
            Future.delayed(const Duration(milliseconds: 50))
                .then((_) => _scrollDown());
          },
        ),
      ),
    );
  }

  Expanded _buildInput() {
    return Expanded(
      child: TextField(
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.send,
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(color: Colors.white),
        controller: _textController,
        decoration: const InputDecoration(
          fillColor: inputBackgroundColor,
          filled: true,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  ListView _buildList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        var message = _messages[index];
        return ChatMessageWidget(
          text: message.text,
          chatMessageType: message.chatMessageType,
        );
      },
    );
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}

class ChatMessageWidget extends StatelessWidget {
  const ChatMessageWidget(
      {super.key, required this.text, required this.chatMessageType});

  final String text;
  final ChatMessageType chatMessageType;

  @override
  Widget build(BuildContext context) {
    return Container(
       padding: EdgeInsets.only(
          top: 10,
          bottom: 10,
          left: chatMessageType == ChatMessageType.bot ? 0 : 15,
          right: chatMessageType == ChatMessageType.bot ? 15 : 0),
      alignment: chatMessageType == ChatMessageType.bot ? Alignment.centerRight : Alignment.centerLeft,

      child: Container(
        
         margin: chatMessageType == ChatMessageType.bot
              ? const EdgeInsets.only(left: 30)
              : const EdgeInsets.only(right: 30),
          padding:
              const EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
          decoration: BoxDecoration(
              borderRadius: chatMessageType == ChatMessageType.bot
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                      bottomLeft: Radius.circular(50),
                    )
                  : const BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
        color: chatMessageType == ChatMessageType.bot
            ? botBackgroundColor
            : chatBackgroundColor,
          ),
        child: Row(
          // mainAxisAlignment: chatMessageType == ChatMessageType.bot 
          //       ? MainAxisAlignment.start: MainAxisAlignment.end,
          //       crossAxisAlignment: chatMessageType == ChatMessageType.bot 
          //       ? CrossAxisAlignment.start: CrossAxisAlignment.start,
          
          children: <Widget>[
            chatMessageType == ChatMessageType.bot
                ? Container(
                   decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      ),
                    alignment: Alignment.topLeft,
                    margin: const EdgeInsets.only(right: 16.0),
                    child: CircleAvatar(
                      backgroundColor: const Color.fromRGBO(16, 163, 127, 1),
                      child: Image.asset(
                        'assets/bot.png',
                        width: 20,
                        height: 20,
                        scale: 1.5,
                      ),
                    ),
                  )
                : Container(
                  alignment: Alignment.topRight,
                    margin: const EdgeInsets.only(right: 16.0),
                    child: const CircleAvatar(
                      child: Icon(
                        Icons.person,
                      ),
                    ),
                  ),
            Expanded(
              child: Column(
                // mainAxisAlignment: chatMessageType == ChatMessageType.bot 
                // ? MainAxisAlignment.end: MainAxisAlignment.start,
                // crossAxisAlignment: chatMessageType == ChatMessageType.bot 
                // ? CrossAxisAlignment.end: CrossAxisAlignment.start,
              
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(4.0),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    child: Text(
                      text,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomAppBar extends StatelessWidget with PreferredSizeWidget{
  const _CustomAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: const Icon(Icons.grid_view_rounded),
      title: const Text(
        "OpenAI Chatgpt",
        textAlign: TextAlign.center,
        ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 20),
          width: 20,
          height: 20,
          
          child: const CircleAvatar(
            backgroundColor: const Color.fromRGBO(16, 163, 127, 1),
            backgroundImage: NetworkImage(
            'https://twitter.com/AI_Dev_official/photo',
            
          )
          ),
        )
      ],
    );
  }
    @override
  Size get preferredSize => const Size.fromHeight(56.0);
}
