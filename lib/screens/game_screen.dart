// lib/screens/game_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flame/game.dart';
import '../game/block_blast_game.dart';
import '../game/game_state_manager.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameStateManager gameState;
  late BlockBlastGame game;
  bool _gameOverShown = false;

  @override
  void initState() {
    super.initState();
    gameState = GameStateManager();
    game = BlockBlastGame(gameState: gameState);
    
    gameState.addListener(_checkGameOver);
  }

  void _checkGameOver() {
    if (gameState.isGameOver && !_gameOverShown && mounted) {
      _gameOverShown = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _showGameOverDialog();
        }
      });
    }
    
    if (!gameState.isGameOver) {
      _gameOverShown = false;
    }
  }

  @override
  void dispose() {
    gameState.removeListener(_checkGameOver);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: gameState,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0F2027),
                Color(0xFF203A43),
                Color(0xFF2C5364),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // 1. Best Score (Hàng 1)
                _buildBestScoreSection(),
                
                const SizedBox(height: 8),
                
                // 2. Current Score (Hàng 2)
                _buildCurrentScoreSection(),
                
                const SizedBox(height: 16),
                
                // 3. Board 8x8 + 4. 3 Blocks (Hàng 3 & 4 - Flame Game Area)
                Expanded(
                  child: GameWidget(game: game),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBestScoreSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'BEST SCORE',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Selector<GameStateManager, int>(
                selector: (_, state) => state.highScore,
                builder: (_, highScore, __) => Text(
                  '$highScore',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentScoreSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Current Score
          Expanded(
            child: _buildStatItem(
              label: 'SCORE',
              selector: (GameStateManager state) => state.score,
              gradient: [const Color(0xFF667EEA), const Color(0xFF764BA2)],
            ),
          ),
          
          Container(width: 1, height: 40, color: Colors.white24),
          
          // Level
          Expanded(
            child: _buildStatItem(
              label: 'LEVEL',
              selector: (GameStateManager state) => state.level,
              gradient: [const Color(0xFFF093FB), const Color(0xFFF5576C)],
            ),
          ),
          
          Container(width: 1, height: 40, color: Colors.white24),
          
          // Reset Button
          Expanded(
            child: Center(
              child: IconButton(
                onPressed: _showResetDialog,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                iconSize: 32,
                tooltip: 'Reset Game',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required int Function(GameStateManager) selector,
    required List<Color> gradient,
  }) {
    return Selector<GameStateManager, int>(
      selector: (_, state) => selector(state),
      builder: (_, value, __) => Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(colors: gradient),
            ),
            child: Text(
              '$value',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Consumer<GameStateManager>(
        builder: (context, state, child) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFF2C3E50),
          title: const Text(
            'GAME OVER',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber, size: 80),
              const SizedBox(height: 20),
              const Text(
                'Your Score',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                '${state.score}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              if (state.score == state.highScore && state.score > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Colors.amber, Colors.orange],
                    ),
                  ),
                  child: const Text(
                    '🏆 NEW HIGH SCORE! 🏆',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _gameOverShown = false;
                  state.resetGame();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'PLAY AGAIN',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => Consumer<GameStateManager>(
        builder: (context, state, child) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFF2C3E50),
          title: const Text(
            'Reset Game?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Your current progress will be lost.\nScore: ${state.score}',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCEL', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _gameOverShown = false;
                state.resetGame();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('RESET', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}