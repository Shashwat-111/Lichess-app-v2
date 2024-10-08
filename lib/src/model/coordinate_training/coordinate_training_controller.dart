import 'dart:async';
import 'dart:math';

import 'package:dartchess/dartchess.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'coordinate_training_controller.freezed.dart';
part 'coordinate_training_controller.g.dart';

enum Guess { correct, incorrect }

@riverpod
class CoordinateTrainingController extends _$CoordinateTrainingController {
  final _random = Random(DateTime.now().millisecondsSinceEpoch);

  final _stopwatch = Stopwatch();

  Timer? _updateTimer;

  @override
  CoordinateTrainingState build() {
    ref.onDispose(() {
      _updateTimer?.cancel();
    });
    return const CoordinateTrainingState();
  }

  void startTraining(Duration? timeLimit) {
    final currentCoord = _randomCoord();
    state = state.copyWith(
      currentCoord: currentCoord,
      nextCoord: _randomCoord(previous: currentCoord),
      score: 0,
      timeLimit: timeLimit,
      elapsed: Duration.zero,
      lastGuess: null,
    );

    _updateTimer?.cancel();
    _stopwatch.reset();
    _stopwatch.start();
    _updateTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (state.timeLimit != null && _stopwatch.elapsed > state.timeLimit!) {
        _finishTraining();
      } else {
        state = state.copyWith(
          elapsed: _stopwatch.elapsed,
        );
      }
    });
  }

  void _finishTraining() {
    // TODO save score in local storage here (and display high score and/or average score in UI)

    stopTraining();
  }

  void stopTraining() {
    _updateTimer?.cancel();
    state = const CoordinateTrainingState();
  }

  /// Generate a random square that is not the same as the [previous] square
  Square _randomCoord({Square? previous}) {
    while (true) {
      final square = Square.values[_random.nextInt(Square.values.length)];
      if (square != previous) {
        return square;
      }
    }
  }

  void guessCoordinate(Square coord) {
    final correctGuess = coord == state.currentCoord;

    if (correctGuess) {
      state = state.copyWith(
        currentCoord: state.nextCoord,
        nextCoord: _randomCoord(previous: state.nextCoord),
        score: state.score + 1,
      );
    }

    state = state.copyWith(
      lastGuess: correctGuess ? Guess.correct : Guess.incorrect,
    );
  }
}

@freezed
class CoordinateTrainingState with _$CoordinateTrainingState {
  const CoordinateTrainingState._();

  const factory CoordinateTrainingState({
    @Default(null) Square? currentCoord,
    @Default(null) Square? nextCoord,
    @Default(0) int score,
    @Default(null) Duration? timeLimit,
    @Default(null) Duration? elapsed,
    @Default(null) Guess? lastGuess,
  }) = _CoordinateTrainingState;

  bool get trainingActive => elapsed != null;

  double? get timeFractionElapsed => (elapsed != null && timeLimit != null)
      ? elapsed!.inMilliseconds / timeLimit!.inMilliseconds
      : null;
}
