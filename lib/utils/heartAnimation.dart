import 'dart:ffi';

import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

class HeartAnimationWidget extends StatefulWidget {
  final Widget child;
  final bool isAnimation;
  final Duration duration;
  final VoidCallback? onEnd;
  const HeartAnimationWidget(
      {super.key,
      required this.child,
      this.duration = const Duration(milliseconds: 150),
      required this.isAnimation,this.onEnd});

  @override
  State<HeartAnimationWidget> createState() => _HeartAnimationWidgetState();
}

class _HeartAnimationWidgetState extends State<HeartAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scale;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final halfDuration = widget.duration.inMilliseconds ~/ 2;

    controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: halfDuration));

     scale = Tween<double>(begin: 1,end: 1.3).animate(controller);
  }

  @override
  void didUpdateWidget(covariant HeartAnimationWidget oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if(widget.isAnimation != oldWidget.isAnimation){
      doAnimation();
      // print("Did Update call");
    }
  }
  Future doAnimation() async{
    if(widget.isAnimation) {
      await controller.forward();
      await controller.reverse();
      await Future.delayed(const Duration(milliseconds: 400));
      if (widget.onEnd != null) {
        print("End is call");
        widget.onEnd!();
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: scale ,child: widget.child,);
  }


}
