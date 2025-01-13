package org.fastcampus.fuhrergame.controller;

import org.fastcampus.fuhrergame.entity.Message;
import org.fastcampus.fuhrergame.repository.MessageRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/messages")
public class MessageController {

    // 의존성 연결
    @Autowired
    private MessageRepository messageRepository;

    @GetMapping
    public List<Message> getMessages() {
        return messageRepository.findAll(); // 모든 메시지 조회
    }


    @PostMapping
    public Message saveMessage(@RequestBody Message message) {
        return messageRepository.save(message); // 메시지 저장
    }
}

