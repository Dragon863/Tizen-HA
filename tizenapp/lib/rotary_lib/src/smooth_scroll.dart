import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'rotary_base.dart';

/// A [ScrollController] that responds to [RotaryEvent]s.
class SmoothRotaryScrollController extends ScrollController {
  /// Constructor
  SmoothRotaryScrollController({this.maxIncrement = 50});

  StreamSubscription<RotaryEvent>? _subscription;

  /// The maximum amount a [RotaryEvent] can increment the scroll position.
  ///
  /// Also the fallback increment if [RotaryEvent.magnitude] is null.
  final double maxIncrement;

  void _onRotaryEvent(RotaryEvent event) {
    final double increment = min(event.magnitude ?? maxIncrement, maxIncrement);

    final double newOffset;
    if (event.direction == RotaryDirection.clockwise) {
      newOffset = min(offset + increment, position.maxScrollExtent);
    } else {
      newOffset = max(offset - increment, position.minScrollExtent);
    }
    animateTo(newOffset,
        duration: const Duration(milliseconds: 100), curve: Curves.easeIn);
  }

  @override
  void attach(ScrollPosition position) {
    _subscription ??= rotaryEvents.listen(_onRotaryEvent);
    super.attach(position);
  }

  @override
  void detach(ScrollPosition position) {
    _subscription?.cancel();
    super.detach(position);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
