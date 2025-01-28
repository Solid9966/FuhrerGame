package org.fastcampus.fuhrergame.repository;

import org.fastcampus.fuhrergame.entity.GameState;
import org.springframework.data.jpa.repository.JpaRepository;

public interface GameStateRepository extends JpaRepository<GameState, Long> {
    GameState findTopByOrderByIdDesc();
}
