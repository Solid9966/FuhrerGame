package org.fastcampus.fuhrergame.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.WebSecurityConfigurer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .authorizeHttpRequests(authorize -> authorize
                .requestMatchers("/ws/**", "/api/game/**").permitAll() // WebSocket 및 Game API 경로 허용,WebSocket 경로는 인증 없이 허용
                .anyRequest().authenticated() // 나머지 모든 요청은 인증 필요
        )
                .csrf(csrf -> csrf.disable()); //CSRF 보호 비활성화 (WebSocket 요청에서 문제 방지)

            return http.build();
    }

}
