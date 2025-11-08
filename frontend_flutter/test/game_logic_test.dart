import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_flutter/game/game.dart';

void main() {
  group('GameLogic basic invariants', () {
    test('newGame creates a 4x4 board with exactly two tiles', () {
      final rng = Random(42);
      final board = GameLogic.newGame(rng);
      int tileCount = 0;
      for (var r = 0; r < Board.size; r++) {
        for (var c = 0; c < Board.size; c++) {
          if (board.getAt(r, c) != null) tileCount++;
        }
      }
      expect(Board.size, 4);
      expect(tileCount, 2);
    });

    test('move returns no change for impossible direction on empty-like board', () {
      final rng = Random(1);
      // Construct a board with a single tile at [0,0]
      final start = Board.empty().spawnAt(row: 0, col: 0, value: 2);
      final res = GameLogic.move(start, MoveDirection.up, rng);
      // Moving up should not change since tile is already at top
      expect(res.changed, false);
      // No steps since no movement
      expect(res.moves, isEmpty);
      expect(res.merges, isEmpty);
      // win/over flags reflect state
      expect(res.hasWon, false);
    });

    test('merge increases score and produces a merge step', () {
      // Build a board with two adjacent tiles 2 and 2 in the first row.
      final board = Board.empty()
          .placeTile(Tile(id: 1, value: 2, row: 0, col: 0))
          .placeTile(Tile(id: 2, value: 2, row: 0, col: 1));
      final res = GameLogic.move(board, MoveDirection.left, Random(7));
      expect(res.changed, true);
      expect(res.scoreGained, 4);
      expect(res.merges.length, 1);
    });
  });

  group('Board basic helpers', () {
    test('emptyCells and hasAnyMove on empty board', () {
      final b = Board.empty();
      expect(b.emptyCells().length, Board.size * Board.size);
      expect(b.hasAnyMove(), true);
      expect(b.containsValue(2048), false);
    });

    test('placeTile and removeAt behavior', () {
      var b = Board.empty();
      b = b.placeTile(const Tile(id: 10, value: 4, row: 1, col: 2));
      expect(b.getAt(1, 2)?.value, 4);
      b = b.removeAt(1, 2);
      expect(b.getAt(1, 2), isNull);
    });
  });
}
