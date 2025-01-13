package org.fastcampus.fuhrergame.repository;

import org.fastcampus.fuhrergame.entity.Message;
import org.springframework.data.jpa.repository.JpaRepository;

// JpaRepository는 기본적인 CRUD 메서드를 제공
public interface MessageRepository extends JpaRepository<Message, Long> {
}
