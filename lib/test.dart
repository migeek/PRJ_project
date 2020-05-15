import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AnimationTest extends StatefulWidget {
  @override
  _AnimationTestState createState() => _AnimationTestState();
}

class _AnimationTestState extends State<AnimationTest> {
  final _animationDuration = Duration(seconds: 2);
  Timer _timer;
  Color _color;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_animationDuration, (timer) => _changeColor);
    _color = Colors.blue;
  }

  void _changeColor() {
    final newColor = _color == Colors.blue ? Colors.blueGrey : Colors.blue;
    setState(() {
      _color = newColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      width: 100,
      height: 100,
      duration: _animationDuration,
      color: _color,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }
}