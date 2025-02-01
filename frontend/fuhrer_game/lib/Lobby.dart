// lobby.dart
import 'package:flutter/material.dart';
import 'GameRoom.dart';
import 'ReadyRoom.dart';
import 'dart:math';

class LobbyPage extends StatefulWidget {
  const LobbyPage({super.key});

  @override
  _LobbyPageState createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  List<Map<String, dynamic>> rooms = []; //기능 구현을 위해 우선 static으로 선언하였음.
  final TextEditingController roomCodeController = TextEditingController();

  void _joinRoom(String roomCode) { //방에 입장.
    final roomIndex = rooms.indexWhere((room) => room['roomCode'] == roomCode);
    if (roomIndex != -1) {
      setState(() {
        rooms[roomIndex]['playerCount'] += 1;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReadyRoomPage(
                roomName: rooms[roomIndex]['roomName'],
                roomCode: roomCode, // ReadyRoom에서는 기존 RoomCode 사용
                gameRoomCode: roomCode + "_game", // GameRoom에서는 별도 RoomCode 사용
                onLeave:(){
                  setState(() {
                    rooms[roomIndex]['playerCount'] -= 1;
                    if (rooms[roomIndex]['playerCount'] == 0) {
                      rooms.removeAt(roomIndex);
                    }
                  });
                }
              ),
        ),
      );
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room not found')),
      );
    }
  }

  void _addRoom(String roomName, String roomCode) { //로비에 새로운 방을 추가와 동시에 입장.
    setState(() {
      rooms.add({'roomName': roomName, 'roomCode': roomCode, 'playerCount': 0,});
    });

    _joinRoom(roomCode);
  }

  String _randomRoomCode() { //새로운 방을 생성할 때, 랜덤 roomCode(중복x)를 생성.
    const String chars = '0123456789';
    String newCode;

    do{
      newCode = String.fromCharCodes(
        Iterable.generate(8, (_) => chars.codeUnitAt(Random().nextInt(chars.length))),
      );
    }while (rooms.any((room) => room['roomCode'] == newCode));

    return newCode;
  }

  Future<void> _showCreateRoomDialog(BuildContext context) async { //creatroom 팝업창 생성 함수.
    final TextEditingController roomNameController = TextEditingController();
    final String randomRoomCode = _randomRoomCode();

    await showDialog( //create room 생성 팝업창.
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Create a Room',
            style: TextStyle(color: Colors.orange),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField( //roomName을 입력받는 텍스트필드.
                controller: roomNameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter Room Name',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10), //랜덤하게 부여된 roomCode 확인 박스.
              Text(
                'Room Code: $randomRoomCode',
                style: const TextStyle(color: Colors.orange, fontSize: 14),
              ),
            ],
          ),

          actions: [
            TextButton( //roomCreate 취소 버튼.
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton( //room Create 버튼.
              onPressed: () {
                if (roomNameController.text.isNotEmpty) {
                  Navigator.pop(context);
                  _addRoom(roomNameController.text, randomRoomCode);
                }
                else{
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a room name'))
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  //본문

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('Main Lobby'),
        backgroundColor: Colors.brown[400],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded( //room code로 join시 code입력칸.
                  child: TextField(
                    controller: roomCodeController,
                    decoration: InputDecoration(
                      hintText: 'Enter Room Code',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8), //room code로 join시 입장버튼.
                ElevatedButton(
                  onPressed: () {
                    if (roomCodeController.text.isNotEmpty) {
                        _joinRoom(roomCodeController.text);
                    }
                    else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Input roomCode')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text('Join'),
                ),
              ],
            ),
          ),

          Expanded( //대기방 목록
            child: ListView.builder(
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                return ListTile(
                  leading: const Icon(Icons.circle, color: Colors.green),
                  title: Row(
                    children: [
                      const Icon(Icons.circle),
                      Text(' ${room['roomName']}  ${room['playerCount']}명 참여중',
                      style: const TextStyle(color: Colors.white),
                    )],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        rooms.removeAt(index);
                      });
                    },
                  ),
                  onTap: () => _joinRoom(room['roomCode']),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () => _showCreateRoomDialog(context),
        tooltip: 'Create Room',
        child: const Icon(Icons.add),
      ),
    );
  }
}
