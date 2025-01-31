import 'package:flutter/material.dart';

class ProgressCheck extends StatefulWidget {
  final int currentRound; // 현재 라운드
  final int electionTracker; // 선거 트래커 상태
  const ProgressCheck({super.key, required this.currentRound, required this.electionTracker});

  @override
  _ProgressCheckState createState() => _ProgressCheckState();
}

class _ProgressCheckState extends State<ProgressCheck> {
  late int currentRound;
  late int electionTracker;

  @override
  void initState() {
    super.initState();
    currentRound = widget.currentRound; // 초기 라운드 설정
    electionTracker = widget.electionTracker; // 초기 선거 트래커 설정
  }

  Widget _buildProgressIndicator(String title, int progress, Color activeColor, {bool showElectionTracker = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 부모의 공간에 맞게 크기 제한
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              return Expanded(
                child: Container(
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: index < progress ? activeColor : Colors.grey[600],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
        if (showElectionTracker) ...[
          const SizedBox(height: 16),
          // 선거 트래커 표시
          Text(
            "선거 트래커",
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              return Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index < electionTracker ? activeColor : Colors.grey[600],
                ),
              );
            }),
          ),
        ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: currentRound == 2 ? 200 : 130, // 자유당원일 때 높이 200, 아니면 150
      child: PageView(
        children: [
          _buildProgressIndicator("공산당원 진척도", currentRound, Colors.red),
          _buildProgressIndicator(
            "자유당원 진척도",
            currentRound,
            Colors.blue,
            showElectionTracker: true, // 선거 트래커 표시
          ),
          _buildProgressIndicator("파시즘 진척도", currentRound, Colors.orange),
        ],
      ),
    );
  }
}
