import 'dart:ui';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Shader Playground',
      home: ShaderBackground(),
    );
  }
}

class ShaderBackground extends StatefulWidget {
  const ShaderBackground({Key? key}) : super(key: key);

  @override
  State<ShaderBackground> createState() => _ShaderBackgroundState();
}

class _ShaderBackgroundState extends State<ShaderBackground>
    with SingleTickerProviderStateMixin {
  int _startTime = 0;

  late final _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))
        ..repeat();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: FutureBuilder<FragmentShader>(
          future: _load(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final shader = snapshot.data!;
              _startTime = DateTime.now().millisecondsSinceEpoch;
              shader.setFloat(1, MediaQuery.sizeOf(context).width);
              shader.setFloat(2, MediaQuery.sizeOf(context).height);
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  shader.setFloat(0, _elapsedTimeInSeconds);
                  return CustomPaint(
                    painter: ShaderPainter(shader),
                  );
                },
              );
            } else {
              return const CircularProgressIndicator();
            }
          }),
    );
  }

  double get _elapsedTimeInSeconds =>
      (_startTime - DateTime.now().millisecondsSinceEpoch) / 1000.0;

  Future<FragmentShader> _load() async {
    FragmentProgram program =
        await FragmentProgram.fromAsset('shaders/stars.frag');
    return program.fragmentShader();
  }
}

class ShaderPainter extends CustomPainter {
  final FragmentShader fragmentShader;

  ShaderPainter(this.fragmentShader);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = fragmentShader,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
