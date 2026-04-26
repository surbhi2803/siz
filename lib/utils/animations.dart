import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AppAnimations {
  static Widget fadeInSlide({
    required Widget child,
    Duration duration = const Duration(milliseconds: 600),
    Duration delay = Duration.zero,
    Offset begin = const Offset(0, 0.3),
    Offset end = Offset.zero,
  }) {
    return child
        .animate()
        .fadeIn(duration: duration, delay: delay)
        .slideY(begin: begin.dy, end: end.dy)
        .slideX(begin: begin.dx, end: end.dx);
  }

  static Widget bounceIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 600),
    Duration delay = Duration.zero,
  }) {
    return child
        .animate()
        .scale(
          duration: duration,
          delay: delay,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: duration, delay: delay);
  }

  static Widget shimmer({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1000),
    Duration delay = Duration.zero,
  }) {
    return child
        .animate()
        .shimmer(
          duration: duration,
          delay: delay,
          color: Colors.white.withOpacity(0.3),
        );
  }

  static Widget pulse({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1000),
    Duration delay = Duration.zero,
  }) {
    return child
        .animate()
        .scale(
          duration: duration,
          delay: delay,
          curve: Curves.easeInOut,
        )
        .then()
        .scale(
          duration: duration,
          curve: Curves.easeInOut,
        );
  }

  static Widget stagger({
    required List<Widget> children,
    Duration duration = const Duration(milliseconds: 600),
    Duration staggerDelay = const Duration(milliseconds: 100),
  }) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        return child
            .animate()
            .fadeIn(
              duration: duration,
              delay: staggerDelay * index,
            )
            .slideY(
              begin: 0.3,
              end: 0,
              duration: duration,
              delay: staggerDelay * index,
            );
      }).toList(),
    );
  }
}

