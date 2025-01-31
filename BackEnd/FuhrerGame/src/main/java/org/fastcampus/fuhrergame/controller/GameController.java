package org.fastcampus.fuhrergame.controller;

import org.fastcampus.fuhrergame.dto.ProgressGameRequest;
import org.fastcampus.fuhrergame.dto.StartGameRequest;
import org.fastcampus.fuhrergame.entity.GameState;
import org.fastcampus.fuhrergame.service.GameService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/game")
public class GameController {

    @Autowired
    private GameService gameService;

    //게임 시작
    @PostMapping("/start")
    public String startGame(@RequestBody StartGameRequest request) {
        gameService.startGame(request.getPlayersCount());
        return  request.getPlayersCount() + "명의 플레이어와 게임을 시작합니다.";
    }

    //게임 진행
    @PostMapping("/progress")
    public String progressgame(@RequestBody ProgressGameRequest request) {
        gameService.progressGame(request.getDescription());
        return request.getDescription() + "진행되었습니다.";
    }

    // 현재 상태 조회
    @GetMapping("/status")
    public GameState getGameState() {
        return gameService.getCurrentGameState();
    }
}
