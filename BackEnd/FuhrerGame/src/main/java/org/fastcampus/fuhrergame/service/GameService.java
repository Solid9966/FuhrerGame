package org.fastcampus.fuhrergame.service;

import org.fastcampus.fuhrergame.entity.GameState;
import org.fastcampus.fuhrergame.repository.GameStateRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class GameService {

    @Autowired
    private GameStateRepository gameStateRepository;

    // 게임 시작
    public void startGame(int playersCount) {
        GameState gameState = new GameState();
        gameState.setPlayersCount(playersCount);
        gameState.setCurrentAction("Game Started");
        gameStateRepository.save(gameState);
    }

    // 게임 진행
    public void progressGame(String actionDescription) {
        GameState gameState = gameStateRepository.findTopByOrderByIdDesc();
        gameState.setCurrentAction(actionDescription);
        gameStateRepository.save(gameState);
    }

    // 현재 게임 상태 조회
    public GameState getCurrentGameState() {
        return gameStateRepository.findTopByOrderByIdDesc();
    }
}
