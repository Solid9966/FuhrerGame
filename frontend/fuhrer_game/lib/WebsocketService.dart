import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class WebSocketService {
  // //192.168.0.2 이부분은 현재 에뮬레이터 사용으로, 개인 컴퓨터 IP 다른 환경 실행시, 따로 지정해줘야함
  final String webSocketUrl = 'ws://192.168.0.2:8080/ws';
  late StompClient stompClient;

  void connect(Function onMessageReceived) {
    stompClient = StompClient(
      config: StompConfig( //클라이언트 설정 지정
        url: webSocketUrl,
        onConnect: (StompFrame frame) { // 서버 연결 성공시 호출
          print('Connected to WebSocket');
          stompClient.subscribe(
            destination: '/topic/messages',
            callback: (StompFrame frame) {
              if (frame.body != null) {
                onMessageReceived(frame.body!);
              }
            },
          );
        },
        onWebSocketError: (dynamic error) {
          print('WebSocket error: $error');
          // 연결 실패 시 5초 후 재시도
          Future.delayed(Duration(seconds: 5), () => connect(onMessageReceived));
        },
        // 서버 연결 끊어질경우, 호출
        onDisconnect: (StompFrame frame) => print('Disconnected from WebSocket'),
      ),
    );

    stompClient.activate(); // WebSocket 연결 활성화, STOMP 메시지 브로커 통신 시작
  }

  void sendMessage(String content) {
    if (stompClient.connected) { // WebSockt 연결이 유지 된다면,
      stompClient.send( // 메시지 전송
        destination: '/app/chat',
        body: '{"message": "$content"}', // JSON 형식으로 메시지 전송
      );
    } else {
      print('Cannot send message. WebSocket is not connected.');
    }
  }
}
