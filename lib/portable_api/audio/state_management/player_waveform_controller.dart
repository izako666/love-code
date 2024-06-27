import 'package:flutter/material.dart';

class PlayerWaveformController extends ChangeNotifier {
  bool _playing = false;
  Duration _playPosition = Duration();
  Duration _maxDuration = Duration();

  bool get playing => _playing;
  Duration get playPosition => _playPosition;
  Duration get maxDuration => _maxDuration;

  void setPlaying(bool val) {
    _playing = val;
    notifyListeners();
  }

  void setPlayingPosition(Duration pos) {
    _playPosition = pos;
    notifyListeners();
  }

  void setMaxDuration(Duration max) {
    _maxDuration = max;
    notifyListeners();
  }

  void start() {
    _playPosition = Duration();
    _playing = true;
    notifyListeners();
  }

  void pause() {
    _playing = false;
    notifyListeners();
  }
}
