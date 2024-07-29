import 'package:flutter/material.dart';

class SpinnerWidget extends StatefulWidget {
  final Widget? child;
  final bool isPlaying;

  const SpinnerWidget({Key? key, required this.child, required this.isPlaying}) : super(key: key);

  @override
  State<SpinnerWidget> createState() => _SpinnerWidgetState();
}

class _SpinnerWidgetState extends State<SpinnerWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Adjust duration for speed
    );

    // Start or stop spinning based on isPlaying
    if (widget.isPlaying) {
      _controller.repeat(); // Repeat the animation
    }
  }

  @override
  void didUpdateWidget(SpinnerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Start or stop spinning based on isPlaying
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _controller.repeat();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller, // Use the controller for continuous rotation
      child: widget.child,
    );
  }
}
