import 'package:flutter/material.dart';
import 'GameRoom.dart';
import 'WebsocketService.dart';
import 'Lobby.dart';

class ReadyRoomPage extends StatefulWidget {
  final String roomName;
  final String roomCode;
  final VoidCallback onLeave;

  const ReadyRoomPage({super.key, required this.roomName,required this.roomCode,required this.onLeave});

  @override
  _ReadyRoomPageState createState() => _ReadyRoomPageState();
}

class _ReadyRoomPageState extends State<ReadyRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = []; // 메시지 리스트
  late WebSocketService _webSocketService; // WebSocketService 필드 정의
  late String username; // 사용자 이름
  final List<String> _participants = [
    "Alice",
    "Bob",
    "Charlie",
    "David",
    "Otto von Habsburg"
  ]; // 최대 12명 추가

  @override
  void initState() {
    super.initState();
    username = '';

    // 다이얼로그를 화면 로딩 후에 표시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showUsernameDialog();
      _showAvatarSelectionDialog();
    });
    _webSocketService = WebSocketService();
    _webSocketService.connect((messageData) {
      setState(() {
        // JSON 데이터만 추가
        if (messageData is Map<String, dynamic>) {
          _messages.add(messageData);
          print('_messages: $_messages'); // 추가된 메시지 확인
        } else {
          print('Invalid message format: $messageData');
        }
      });
    });
  }

  void _showUsernameDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 다이얼로그 외부를 눌러 닫을 수 없음
      builder: (BuildContext context) {
        final TextEditingController usernameController = TextEditingController();
        return AlertDialog(
          title: const Text('Enter your username'),
          content: TextField(
            controller: usernameController,
            decoration: const InputDecoration(hintText: 'Your username'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (usernameController.text.isNotEmpty) {
                  setState(() {
                    username = usernameController.text;
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showAvatarSelectionDialog() {
    int? selectedAvatarIndex; // 선택된 아바타의 인덱스를 저장할 변수

    showDialog(
      context: context,
      barrierDismissible: false, // 다이얼로그 외부 터치로 닫히지 않도록 설정
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Player Look"),
              content: SizedBox(
                width: double.maxFinite, // 다이얼로그의 가로 크기 제한
                child: GridView.builder(
                  shrinkWrap: true, // GridView가 콘텐츠 크기에 맞게 크기 조정
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // 한 줄에 3개
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1, // 정사각형 비율
                  ),
                  itemCount: 12, // 아바타 9개 예시
                  itemBuilder: (context, index) {
                    final isSelected = selectedAvatarIndex == index; // 현재 아바타가 선택되었는지 확인
                    return GestureDetector(
                      onTap: () {
                        // 아바타 선택 시 효과
                        setState(() {
                          selectedAvatarIndex = index; // 선택된 인덱스 저장
                        });
                        Future.delayed(const Duration(milliseconds: 150), () {
                          Navigator.of(context).pop(); // 다이얼로그 닫기
                        });
                      },
                      child: MouseRegion(
                        onEnter: (_) => setState(() {}),
                        onExit: (_) => setState(() {}),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.orange[300] // 선택된 상태 배경색
                                : Colors.grey[300], // 기본 배경색
                            border: Border.all(
                              color: isSelected
                                  ? Colors.orange // 선택된 상태 테두리색
                                  : Colors.transparent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: isSelected ? 10 : 5, // 선택된 상태에서 더 뚜렷한 그림자
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person, // 아바타 아이콘 예시
                              size: 40,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  } //내가 아바타를 선택하면 이걸 서버?로 전송해서 아바타를 저장한뒤,
  // 다른 참가자들 아바타와 함께 불러와서 화면에 표시해야함


  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      // final username = "User1"; // 사용자 이름 수동 설정 방법
      final content = _messageController.text;

      _webSocketService.sendMessage(username, content); // 메시지 전송
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; //화면의 크기를 변수로 가져오자
    return WillPopScope(
        onWillPop: () async {
          widget.onLeave();
          return true;
        },
    child: Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Text(widget.roomName),
        backgroundColor: Colors.brown[400],
      ),
      body: Column(
        children: [
          // 참가자 현황 섹션
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.brown[800],
            height: screenWidth * 0.5, // 높이 400
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Participants",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${_participants.length} Players",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    // 게임 시작 버튼
                    ElevatedButton(
                      onPressed: () {
                        // 게임 시작 로직 추가
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GameRoomPage(
                                roomName: '${widget.roomName}',
                                roomCode: '${widget.roomCode}',
                                ),
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('게임 스따또')),
                        );
                        print("게임 시작 버튼 클릭됨");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600], // 버튼 배경색
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Start Game",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, // 한 줄에 4명
                      childAspectRatio: 2, // 사각형 비율 (가로 / 세로)
                      mainAxisSpacing: 10, // 세로 간격
                      crossAxisSpacing: 10, // 가로 간격
                    ),
                    itemCount: _participants.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.brown[600],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // 사진 부분: 아직 정해지지 않았으므로 네모 박스로 표시
                            Container(
                              width: screenWidth * 0.1, // 화면 너비의 18% 크기
                              height: screenWidth * 0.1, // 화면 너비의 18% 크기
                              margin: const EdgeInsets.symmetric(horizontal: 5), // 사진과 텍스트 사이 여백
                              color: Colors.grey[700], // 사진 대체용 네모 박스
                              child: const Icon(
                                Icons.image, // 이미지 아이콘
                                color: Colors.white54,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // 이름 부분
                            Expanded(
                              child: Text(
                                _participants[index],
                                style: const TextStyle(color: Colors.white, fontSize: 10,),
                                overflow: TextOverflow.ellipsis, // 텍스트 길 경우 ... 표시
                                maxLines: 1, // 한 줄로 제한
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.grey),
          // 채팅 메시지 섹션
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length, // 전체 메시지 개수
              reverse: true, // 최신 메시지가 아래에 표시되도록
              itemBuilder: (context, index) {
                // 메시지를 Map<String, dynamic> 타입으로 캐스팅
                final Map<String, dynamic> message = _messages[_messages
                    .length - 1 - index];

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
                      style: const TextStyle(color: Colors
                          .white), // 텍스트 색상은 흰색
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: Colors.grey),
          // 메시지 입력 섹션
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
    ),
    );
  }
}
