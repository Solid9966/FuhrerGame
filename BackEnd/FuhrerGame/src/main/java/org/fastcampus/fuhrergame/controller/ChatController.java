package org.fastcampus.fuhrergame.controller;

import org.fastcampus.fuhrergame.entity.Message;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.stereotype.Controller;

@Controller
public class ChatController {

    @MessageMapping("/chat") // 클라이언트가 "/app/chat"으로 메시지를 보낼 때 호출
    @SendTo("/topic/messages") // 서버가 클라이언트로 메시지를 브로드캐스트할 경로
    public Message sendMessage(@Payload Message message) {
        System.out.println("Received message: " + message.getContent());
        return message; // 클라이언트로 메시지 반환
    }
}
