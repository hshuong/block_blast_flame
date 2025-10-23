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
    
    // Listen for game over
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
            child: Stack(
              children: [
                // Game canvas - Không rebuild khi state thay đổi
                GameWidget(game: game),
                
                // UI Overlay - Chỉ rebuild phần cần thiết
                Positioned(
                  top: 20,
                  left: 20,
                  right: 20,
                  child: _buildHeader(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Chỉ rebuild khi score thay đổi
        Selector<GameStateManager, int>(
          selector: (_, state) => state.score,
          builder: (_, score, __) => _buildStatCard(
            title: 'SCORE',
            value: '$score',
            gradient: [Colors.blue.shade600, Colors.blue.shade800],
          ),
        ),
        
        // Chỉ rebuild khi level thay đổi
        Selector<GameStateManager, int>(
          selector: (_, state) => state.level,
          builder: (_, level, __) => _buildStatCard(
            title: 'LEVEL',
            value: '$level',
            gradient: [Colors.purple.shade600, Colors.purple.shade800],
          ),
        ),
        
        // Chỉ rebuild khi highScore thay đổi
        Selector<GameStateManager, int>(
          selector: (_, state) => state.highScore,
          builder: (_, highScore, __) => _buildStatCard(
            title: 'BEST',
            value: '$highScore',
            gradient: [Colors.amber.shade600, Colors.orange.shade800],
          ),
        ),
        
        IconButton(
          onPressed: _showResetDialog,
          icon: const Icon(Icons.refresh, color: Colors.white, size: 32),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required List<Color> gradient,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(colors: gradient),
            boxShadow: [
              BoxShadow(
                color: gradient[0].withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
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