import 'package:flutter/material.dart';

class TransitionUtil {
  static Route createFadeTransition(Widget widget) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.linear;
        final fadeTween = Tween(begin: 0.0, end: 1.0);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );
        return FadeTransition(
            opacity: fadeTween.animate(curvedAnimation), child: child);
      },
    );
  }

  static Route createSlideInTransition(Widget widget) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeOut;
        const startOffset = Offset(1, 0);
        const endOffset = Offset(0, 0);
        final tween = Tween(begin: startOffset, end: endOffset);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );
        return SlideTransition(
            position: tween.animate(curvedAnimation), child: child);
      },
    );
  }
}
