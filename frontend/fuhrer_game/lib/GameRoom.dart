// game_room.dart
import 'package:flutter/material.dart';
import 'WebsocketService.dart';
import 'ReadyRoom.dart';
import 'dart:math';
import 'ProgressChecker.dart';

class GameRoomPage extends StatefulWidget {
  final String roomName;
  final String roomCode; // 여기서 roomCode는 ReadyRoom과 다름
  final String userName;
  final List<String> participants;

  const GameRoomPage({super.key, required this.roomName, required this.roomCode, required this.userName, required this.participants,});

  @override
  _GameRoomPageState createState() => _GameRoomPageState();
}

class _GameRoomPageState extends State<GameRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  late WebSocketService _webSocketService; // WebSocketService 필드 정의
  final List<Map<String, dynamic>> _messages = []; // 메시지 리스트

  late String username; // 사용자 이름
  late List<String> _participants; // 참가자 리스트

  //추가부분
  late String president; //대통령.
  String? chancellor; //수상.
  Map<String, String> playerRoles = {}; //플레이어 역할.
  bool votingInProgress = false;
  Map<String, bool> votes = {};

  int currentRound = 1; //현재 라운드 정보
  int electionTracker = 2; // 현재 선거 트래커 상태

  @override
  void initState() {
    super.initState();
    username = widget.userName; // 초기값 설정
    _participants = widget.participants; //참여자 확인.

    _assignRoles();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showRolePopup();
    });

    _webSocketService = WebSocketService();
    _webSocketService.connect((messageData) {
      setState(() {
        // JSON 데이터만 추가
        if (messageData is Map<String, dynamic>) {
          _messages.add(messageData);
          print('New message added: $messageData'); // 추가된 메시지 확인
        } else {
          print('Invalid message format: $messageData');
        }
      });
    },  widget.roomCode,
      "gameroom", // Room 타입 지정 , GameRoom의 별도 RoomCode 사용
    );
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      // final username = "User1"; // 사용자 이름 수동 설정 방법
      final content = _messageController.text;

      _webSocketService.sendMessage("gameroom", widget.roomCode, username, content); // 메시지 전송
      _messageController.clear();
    }
  }

  //역할을 부여하는 부분. -> 수정 필요.
  void _assignRoles() {
    List<String> shuffledPlayers = List.from(_participants)..shuffle();
    int liberalCount = _participants.length ~/ 2; // 절반은 Liberal -> 현재는 절반을 기준으로 liberal을 했지만 인원 전달에 따른 룰 설정이 가능해지면 수정.
    for (int i = 0; i < _participants.length; i++) {
      playerRoles[shuffledPlayers[i]] = i < liberalCount ? "Liberal" : "Pacist";
    }
  }

  // 역할을 알려주는 팝업창. 5초 후에 자동으로 닫히도록 설정해두었습니다.
  void _showRolePopup() {
    String myRole = playerRoles[username] ?? "Unknown";
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("당신의 역할"),
          content: Text("당신은 $myRole 입니다."),
        );
      },
    );
    // 5초 후에 자동 닫기
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.of(context).pop();
        _selectPresident(); // 역할 팝업이 닫힌 후 대통령 선정
      }
    });
  }

  //자동으로 대통령을 선정 -> 수정 필요.
  void _selectPresident() {
    president = 'Bob';
    //president = _participants[Random().nextInt(_participants.length)]; //현재 있는 플레이어 중에서 선정되도록 해두었습니다.
    //테스트 중이라 현재 설정된 5개의 이름 중 하나로 해두었고, username이 전송가능해지는 경우부터는 수정하면 될 듯 합니다.

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("대통령 선정"),
          content: Text("이번 라운드의 대통령은 $president 입니다."),
        );
      },
    );

    // 3초 후에 자동 닫기
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pop();
        if (president == username) {
          _showChancellorSelectionPopup(); // 대통령이면 수상 선택창 띄우기
        }
        else {
          _showWaitingPopup(); //대통령이 아닌 사람은 수상 선택을 대기
        }
      }
    });
  }

  //대통령이 수상을 선택. -> 수정 필요. (이전에 수상이었던 사람이 다시 수상이 되지 않는 룰을 적용하지 않았음.)
  //현재 unexpected null 오류가 있어서 대통령이 아닌 인원이 대통령의 선택을 기다린 이후에 버그가 발생합니다.
  void _showChancellorSelectionPopup() {
    List<String> candidates = _participants.where((p) => p != president).toList();
    String? selectedChancellor;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("수상 선택"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var player in candidates)
                    RadioListTile(
                      title: Text(player),
                      value: player,
                      groupValue: selectedChancellor,
                      onChanged: (value) {
                        setState(() => selectedChancellor = value);
                      },
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (selectedChancellor != null) {
                      chancellor = selectedChancellor;
                      Navigator.of(context).pop();
                      _startVoting();
                    }
                  },
                  child: const Text("확인"),
                ),
              ],
            );
          },
        );
      },
    );
    // 10초 후 자동 랜덤 선택
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && chancellor == null) {
        chancellor = candidates[Random().nextInt(candidates.length)];
        Navigator.of(context).pop();
        _startVoting();
      }
    });
  }

  //대통령의 선택을 기다리는 화면.
  void _showWaitingPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("대기 중..."),
          content: Text("대통령 ($president)이 수상을 선택하고 있습니다."),
        );
      },
    );

    // 대통령이 수상을 선택하면 팝업 자동 닫기 -> 투표 진행가능하도록 설정.
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        Navigator.of(context).pop();
        _startVoting();
      }
    });
  }

  void _startVoting() {
    votes.clear();
    votingInProgress = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("수상 투표 (${chancellor!})"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [ //찬반 투표 진행.
              ElevatedButton(
                onPressed: () {
                  if (!votes.containsKey(username)) {
                    votes[username] = true;
                    Navigator.of(context).pop();
                    _waitResult();
                    _checkVoteResult();
                  }
                },
                child: const Text("ja!"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (!votes.containsKey(username)) {
                    votes[username] = false;
                    Navigator.of(context).pop();
                    _waitResult();
                    _checkVoteResult();
                  }
                },
                child: const Text("nein!"),
              ),
            ],
          ),
        );
      },
    );

    // 10초 후 자동 반대 처리 -> 지금 작동을 안하고 있어서 일단 열심히 해보겠습니다.
    Future.delayed(const Duration(seconds: 10), () {
      if (votes.length < _participants.length) {
        votes[username] ??= false;
        _checkVoteResult();
      }
    });
  }

  void _waitResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("투표 대기 중..."),
          content: const Text("다른 플레이어들이 투표를 완료할 때까지 기다려 주세요."),
        );
      },
    );
  }

  // 투표 결과 확인.
  void _checkVoteResult() {
    if (votes.length == _participants.length) {
      int approveCount = votes.values.where((v) => v).length;
      bool passed = approveCount > _participants.length / 2;

      if (mounted) {
        Navigator.of(context).pop();
      }

      if (passed) {
        print("<${chancellor}>수상선정이 승인되었습니다.");
        //_startPolicySelection(); //이후 대통령과 수상이 정책을 선정하는 과정이 필요함.
      } else {
        print("수상선정이 거부되었습니다.");
        _selectPresident();
      }
    }
  }

  //////////////////////////////////////현재 여기까지만 구현되었습니다. 이후에 생각하기로는 채팅 기능을 수상 선정의 찬반 투표 이전에 채팅 시간을 넣는게 좋지않을까 생각합니다.

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
            Flexible(
              flex: 2,
              child: ProgressCheck(
                currentRound: currentRound,
                electionTracker: electionTracker,
              ),
            ),
            const Divider(height: 1, color: Colors.grey),
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length, // 전체 메시지 개수
                reverse: true, // 최신 메시지가 아래에 표시되도록
                itemBuilder: (context, index) {
                  // 메시지를 Map<String, dynamic> 타입으로 캐스팅
                  final Map<String, dynamic> message = _messages[_messages.length - 1 - index];

                  return Align(
                    alignment: message['username'] == username
                        ? Alignment.centerRight // 본인의 메시지는 오른쪽
                        : Alignment.centerLeft, // 다른 사용자의 메시지는 왼쪽
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: message['username'] == username
                            ? Colors.brown[400] // 본인의 메시지는 브라운 색상
                            : Colors.grey[700], // 다른 사용자의 메시지는 회색
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "${message['username'] ??
                            'Unknown'}: ${message['content'] ?? 'No content'}",
                        style: const TextStyle(color: Colors.white), // 텍스트 색상은 흰색
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