// game_room.dart
import 'package:flutter/material.dart';
import 'WebsocketService.dart';

class GameRoomPage extends StatefulWidget {
  final String roomName;

  const GameRoomPage({super.key, required this.roomName});

  @override
  _GameRoomPageState createState() => _GameRoomPageState();
}

class _GameRoomPageState extends State<GameRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<String> _messages = [];
  final WebSocketService _webSocketService = WebSocketService();

  @override
  void initState() {
    super.initState();
    _webSocketService.connect((message) {
      setState(() {
        _messages.insert(0, message); // 새 메시지를 리스트에 추가
      });
    });
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      final username = "User1"; // 사용자 이름 설정
      final content = _messageController.text;

      _webSocketService.sendMessage(username, content); // 메시지 전송
      _messageController.clear();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Text(widget.roomName),
        backgroundColor: Colors.brown[400],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              reverse: true,
              itemBuilder: (context, index) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.brown[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _messages[_messages.length - 1 - index],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: Colors.grey),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send, color: Colors.orange),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
