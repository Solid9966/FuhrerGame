// lobby.dart
import 'package:flutter/material.dart';

class LobbyPage extends StatelessWidget {
  const LobbyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('Lobby List'),
        backgroundColor: Colors.brown[400],
      ),
      body: ListView.builder(
        itemCount: 10, // 샘플로 10개의 채팅방 목록을 표시
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              'Lobby ${index + 1}',
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () {
              // 나중에 채팅방 화면으로 이동하도록 추가 가능
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Lobby ${index + 1} selected')),
              );
            },
          );
        },
      ),
    );
  }
}
