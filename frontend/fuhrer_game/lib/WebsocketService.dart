import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'dart:convert'; // JSON 파싱

class WebSocketService {
  // EC2 Public IP 할당
  final String webSocketUrl = 'ws://192.168.0.2:8080/ws';
  late StompClient stompClient;

  void connect(Function(Map<String, dynamic>) onMessageReceived, String roomCode, String roomType) {
    String topicPath = '/topic/$roomType/$roomCode'; // Room별 topicPath 생성
    // print('Subscribing to: $topicPath'); //확인 문구

    stompClient = StompClient(
      config: StompConfig( //클라이언트 설정 지정
        url: webSocketUrl,
        onConnect: (StompFrame frame) { // 서버 연결 성공시 호출
          print('Connected to WebSocket');
          stompClient.subscribe(
            // destination: '/topic/messages', //구 경로 설정
            destination: topicPath, // 동적으로 구독할 경로 설정
            callback: (StompFrame frame) {
              if (frame.body != null) {
                try {
                  final Map<String, dynamic> messageData = json.decode(frame.body!);
                  print('Received message: $messageData'); // 수신된 메시지 확인
                  onMessageReceived(messageData); // 파싱된 데이터를 콜백으로 전달
                } catch (error) {
                  print('Error parsing message: $error');
                }
              }
            },
          );
        },
        onWebSocketError: (dynamic error) {
          print('WebSocket error: $error');
          // 연결 실패 시 5초 후 재시도
          Future.delayed(Duration(seconds: 5), () => connect(onMessageReceived, roomCode, roomType));
        },
        // 서버 연결 끊어질경우, 호출
        onDisconnect: (StompFrame frame) => print('Disconnected from WebSocket'),
      ),
    );

    stompClient.activate(); // WebSocket 연결 활성화, STOMP 메시지 브로커 통신 시작
  }

  void sendMessage(String roomType, String roomCode, String username,String content) {
    if (stompClient.connected) { // WebSockt 연결이 유지 된다면,
      String destination = '/app/$roomType/$roomCode'; // Room별 메시지 전송 경로 생성
      // print('Sending message to: $destination'); test 문구

      stompClient.send( // 메시지 전송
        // destination: '/app/chat',
        destination: destination,
        body: json.encode({
          "username": username,
          "content": content,
          "timestamp": DateTime.now().toIso8601String(),
        }),
      );
      print('Message sent: $content'); // 메시지 전송 로그 추가
    } else {
      print('Cannot send message. WebSocket is not connected.');
    }
  }

  void sendParticipants(String roomType, String roomCode, List<String> participants) {
    if(stompClient.connected) {
      String destination = '/app/$roomType/$roomCode/participants'; // Room별 참가자 전송 경로 생성
      // print('Sending participants to: $destination'); //test 문구

      stompClient.send(
        // destination: '/app/game/start',
        destination: destination,
        body: json.encode({
          "roomCode": roomCode,
          "playerCount": participants.length,
          "players": participants,
        }),
      );
      print("Participants sent to server: $participants");
    } else {
      print('Cannot send participants. WebSocket is not connected.');
    }
  }
}
