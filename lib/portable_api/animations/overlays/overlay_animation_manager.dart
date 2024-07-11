import 'package:flutter/material.dart';

class OverlayAnimationManager {
  static startAnimation(BuildContext context, OverlayEntry overlayEntry) {
    OverlayState overlayState = Overlay.of(context);
    overlayState.insert(overlayEntry);
  }

  static endAnimation(OverlayEntry overlayEntry) {
    overlayEntry.remove();
  }
}
