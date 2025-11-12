import 'dart:math';
import 'package:flutter/material.dart';

// LumiPlant - Interactive Glowing Plant
// Paste into DartPad (Flutter) and Run.

void main() => runApp(LumiPlantApp());

class LumiPlantApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LumiPlant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF0B1020),
      ),
      home: LumiPlantHome(),
    );
  }
}

class LumiPlantHome extends StatefulWidget {
  @override
  _LumiPlantHomeState createState() => _LumiPlantHomeState();
}

class _LumiPlantHomeState extends State<LumiPlantHome>
    with TickerProviderStateMixin {
  double growth = 0.35; // 0.0 - 1.0
  bool isBloom = false;
  bool isDay = true;
  List<String> log = [];

  late AnimationController swayController;
  late AnimationController particleController;
  Random random = Random();

  @override
  void initState() {
    super.initState();
    swayController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 1500))
          ..repeat(reverse: true);
    particleController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2400))
      ..repeat();
    _addLog("Welcome to LumiPlant 🌱");
  }

  @override
  void dispose() {
    swayController.dispose();
    particleController.dispose();
    super.dispose();
  }

  void _addLog(String t) {
    setState(() {
      log.insert(0, "${DateTime.now().toLocal().toIso8601String().substring(11,19)} • $t");
      if (log.length > 6) log.removeLast();
    });
  }

  void waterPlant() {
    setState(() {
      growth += 0.12;
      if (growth > 1) growth = 1;
      if (growth > 0.7 && !isBloom) {
        isBloom = true;
        _addLog("Plant bloomed 🌸");
      } else {
        _addLog("Watered the plant 💧");
      }
    });
  }

  void shakeLeaves() {
    // quick pulse in sway
    _addLog("You shook the plant 🍃");
    swayController.forward(from: 0.0);
  }

  void longPressAction() {
    setState(() {
      if (isBloom) {
        isBloom = false;
        growth = max(0.4, growth - 0.22);
        _addLog("Pruned the bloom ✂");
      } else {
        isBloom = true;
        growth = min(1.0, growth + 0.18);
        _addLog("Triggered bloom 🌺");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bgGradient = isDay
        ? LinearGradient(colors: [Color(0xFF88E0FF), Color(0xFFB9E6FF)], begin: Alignment.topCenter, end: Alignment.bottomCenter)
        : LinearGradient(colors: [Color(0xFF07102A), Color(0xFF0B2540)], begin: Alignment.topCenter, end: Alignment.bottomCenter);

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          AnimatedContainer(
            duration: Duration(milliseconds: 600),
            decoration: BoxDecoration(
              gradient: bgGradient,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(child: _buildPlantArea()),
                  _buildControls(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white24,
            child: Icon(Icons.spa, color: Colors.greenAccent),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("LumiPlant", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                SizedBox(height: 2),
                Text(isDay ? "Sunlit Grove" : "Moonlit Grove",
                    style: TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(isDay ? Icons.nightlight_round : Icons.wb_sunny),
            onPressed: () {
              setState(() {
                isDay = !isDay;
                _addLog(isDay ? "Switched to Day 🌞" : "Switched to Night 🌙");
              });
            },
          )
        ],
      ),
    );
  }

  Widget _buildPlantArea() {
    return GestureDetector(
      onTap: () {
        waterPlant();
      },
      onLongPress: () {
        longPressAction();
      },
      onPanUpdate: (d) {
        if (d.delta.distance > 3) shakeLeaves();
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // The 'center' variable was defined but not used. Removing it.
          // final center = Offset(constraints.maxWidth / 2, constraints.maxHeight * 0.55);
          final potWidth = constraints.maxWidth * 0.42;
          final potHeight = constraints.maxHeight * 0.16;

          return Stack(
            children: [
              // glowing particles
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: particleController,
                  builder: (_, __) {
                    return CustomPaint(
                      painter: ParticlePainter(
                          seed: 1234,
                          progress: particleController.value,
                          isDay: isDay,
                          growth: growth),
                    );
                  },
                ),
              ),

              // Plant painter
              Positioned(
                left: 0,
                right: 0,
                top: 40,
                bottom: potHeight + 40,
                child: AnimatedBuilder(
                  animation: swayController,
                  builder: (_, __) {
                    return CustomPaint(
                      painter: PlantPainter(
                          sway: swayController.value,
                          growth: growth,
                          bloom: isBloom,
                          timeSeed: DateTime.now().millisecond),
                    );
                  },
                ),
              ),

              // Pot
              Positioned(
                left: (constraints.maxWidth - potWidth) / 2,
                bottom: 30,
                child: Container(
                  width: potWidth,
                  height: potHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.brown.shade800, Colors.brown.shade600],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0,6))],
                  ),
                  child: Center(
                      child: Text("Tap to Water • Hold to Bloom • Swipe to Shake",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.white70))),
                ),
              ),

              // action log (bottom-left)
              Positioned(
                left: 14,
                bottom: 14,
                child: Container(
                  width: 220,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha((255 * 0.28).round()), // Fixed
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: log.map((e) => Text(e, style: TextStyle(fontSize: 11))).toList(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 18),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: Icon(Icons.opacity),
              label: Text("Water"),
              onPressed: () {
                waterPlant();
              },
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
          SizedBox(width: 12),
          Container(
            width: 56,
            height: 48,
            child: ElevatedButton(
              child: Icon(Icons.auto_fix_high),
              onPressed: () {
                setState(() {
                  growth = min(1.0, growth + 0.24);
                  if (growth > 0.7) isBloom = true;
                  _addLog("Fertilized 🌿");
                });
              },
              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          )
        ],
      ),
    );
  }
}

// ---- Custom Painters ----

class PlantPainter extends CustomPainter {
  final double sway; // 0.0 - 1.0
  final double growth; // 0.0 - 1.0
  final bool bloom;
  final int timeSeed;

  PlantPainter({required this.sway, required this.growth, required this.bloom, required this.timeSeed});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final baseY = size.height * 0.92;
    final stemHeight = lerpDouble(80, size.height * 0.55, growth)!;
    final stemTop = Offset(centerX, baseY - stemHeight);

    // background glow under plant
    final glowPaint = Paint()
      ..shader = RadialGradient(colors: [
        Colors.greenAccent.withAlpha(((0.06 + growth * 0.18) * 255).round()), // Fixed
        Colors.transparent
      ]).createShader(Rect.fromCircle(center: stemTop, radius: 120));
    canvas.drawCircle(stemTop, 120 * (0.6 + growth * 0.6), glowPaint);

    // draw stem
    _drawStem(canvas, Offset(centerX, baseY), stemTop);

    // leaves
    _drawLeaves(canvas, stemTop, stemHeight);

    // bloom
    if (bloom) _drawBloom(canvas, stemTop, growth);
  }

  void _drawStem(Canvas canvas, Offset base, Offset top) {
    final path = Path();
    final control1 = Offset((base.dx + top.dx) / 2 + sin(sway * pi * 2 + timeSeed) * 18, base.dy - (base.dy - top.dy) * 0.4);
    final control2 = Offset((base.dx + top.dx) / 2 + cos(sway * pi * 2 + timeSeed/10) * 12, base.dy - (base.dy - top.dy) * 0.7);
    path.moveTo(base.dx, base.dy);
    path.cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, top.dx, top.dy);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8 * (0.8 + growth * 0.9)
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(colors: [Colors.green.shade700, Colors.green.shade300])
          .createShader(Rect.fromLTRB(base.dx - 40, base.dy - 200, base.dx + 40, base.dy));
    canvas.drawPath(path, paint);
  }

  void _drawLeaves(Canvas canvas, Offset top, double stemHeight) {
    final leafCount = (3 + (growth * 6)).floor();
    for (int i = 0; i < leafCount; i++) {
      final t = i / max(1, leafCount - 1);
      final along = Offset(top.dx + (t - 0.5) * 40 + (i.isEven ? 1 : -1) * 20, top.dy + t * stemHeight * 0.6);
      _drawLeaf(canvas, along, i.isEven ? -1 : 1, 0.5 + (growth * 0.8));
    }
  }

  void _drawLeaf(Canvas canvas, Offset pos, int side, double scale) {
    final leafPath = Path();
    final w = 24 * scale;
    final h = 48 * scale;
    leafPath.moveTo(pos.dx, pos.dy);
    leafPath.quadraticBezierTo(pos.dx + side * w * 0.9, pos.dy - h * 0.3, pos.dx + side * w * 1.6, pos.dy - h * 0.9);
    leafPath.quadraticBezierTo(pos.dx + side * w * 0.9, pos.dy - h * 1.2, pos.dx, pos.dy);
    final paint = Paint()
      ..shader = LinearGradient(colors: [Colors.green.shade400, Colors.green.shade800])
          .createShader(Rect.fromCircle(center: pos, radius: 40))
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawPath(leafPath, paint);

    final vein = Paint()
      ..color = Colors.green.shade900.withAlpha((255 * 0.8).round()) // Fixed
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(pos, Offset(pos.dx + side * w * 1.1, pos.dy - h * 0.7), vein);
  }

  void _drawBloom(Canvas canvas, Offset top, double growth) {
    final bloomRadius = 22 + growth * 24;
    final center = top.translate(0, -bloomRadius * 0.6);
    final petalPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 6; i++) {
      final angle = i * pi * 2 / 6 + sin(growth * pi * 2) * 0.08;
      final p1 = Offset(center.dx + cos(angle) * bloomRadius, center.dy + sin(angle) * bloomRadius);
      final p2 = Offset(center.dx + cos(angle + 0.2) * bloomRadius * 0.5, center.dy + sin(angle + 0.2) * bloomRadius * 0.5);
      final path = Path();
      path.moveTo(center.dx, center.dy);
      path.quadraticBezierTo((center.dx + p1.dx) / 2, (center.dy + p1.dy) / 2 - 10, p1.dx, p1.dy);
      path.quadraticBezierTo(p2.dx, p2.dy, center.dx, center.dy);
      petalPaint.shader = RadialGradient(colors: [
        Colors.pinkAccent.withAlpha((255 * 0.95).round()), // Fixed
        Colors.deepOrangeAccent.withAlpha((255 * 0.9).round()), // Fixed
      ]).createShader(Rect.fromCircle(center: center, radius: bloomRadius * 1.2));
      canvas.drawPath(path, petalPaint);
    }

    final core = Paint()..color = Colors.yellow.shade600;
    canvas.drawCircle(center, max(6.0, 6 + growth * 6), core);
  }

  @override
  bool shouldRepaint(covariant PlantPainter oldDelegate) {
    return oldDelegate.sway != sway ||
        oldDelegate.growth != growth ||
        oldDelegate.bloom != bloom;
  }
}

class ParticlePainter extends CustomPainter {
  final double progress;
  final bool isDay;
  final double growth;
  final int seed;

  ParticlePainter({required this.progress, required this.isDay, required this.growth, this.seed = 42});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.45);
    final rnd = Random(seed);
    final count = (30 + growth * 60).toInt();

    for (int i = 0; i < count; i++) {
      final t = ((i * 0.73) + progress) % 1.0;
      final angle = (i * 23.0 + progress * 360) % 360;
      final rad = lerpDouble(30, min(size.width, size.height) * 0.55, (i / count))!;
      final x = center.dx + cos(angle * pi / 180) * rad * (0.4 + 0.6 * t);
      final y = center.dy + sin(angle * pi / 180) * rad * (0.4 + 0.6 * t);
      final sz = (rnd.nextDouble() * 2.2 + growth * 3.4) * (0.6 + 0.8 * (1 - t));
      final opacity = (0.12 + (1 - t) * 0.6) * (isDay ? 1.0 : 0.65);

      final p = Paint()
        ..color = (isDay ? Colors.yellowAccent.withAlpha((opacity * 255).round()) : Colors.cyanAccent.withAlpha((opacity * 255).round())) // Fixed
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 * (0.4 + growth * 0.8));
      canvas.drawCircle(Offset(x, y), sz, p);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.growth != growth || oldDelegate.isDay != isDay;
  }
}

double? lerpDouble(num a, num b, double t) => a + (b - a) * t;