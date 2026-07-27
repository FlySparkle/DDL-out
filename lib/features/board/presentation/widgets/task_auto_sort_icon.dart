import 'package:flutter/material.dart';

class TaskAutoSortIcon extends StatelessWidget {
  const TaskAutoSortIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size.square(24),
      painter: _TaskAutoSortIconPainter(
        color: IconTheme.of(context).color ?? Colors.black,
      ),
    );
  }
}

class _TaskAutoSortIconPainter extends CustomPainter {
  const _TaskAutoSortIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas
      ..drawLine(const Offset(3, 5), const Offset(19, 5), linePaint)
      ..drawLine(const Offset(3, 11), const Offset(15, 11), linePaint)
      ..drawLine(const Offset(3, 17), const Offset(10, 17), linePaint);

    final arrowPaint = Paint()
      ..color = color
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(18.5, 13)
      ..lineTo(18.5, 22)
      ..moveTo(18.5, 13)
      ..lineTo(16, 15.5)
      ..moveTo(18.5, 13)
      ..lineTo(21, 15.5)
      ..moveTo(18.5, 22)
      ..lineTo(16, 19.5)
      ..moveTo(18.5, 22)
      ..lineTo(21, 19.5);
    canvas.drawPath(path, arrowPaint);
  }

  @override
  bool shouldRepaint(_TaskAutoSortIconPainter oldDelegate) =>
      oldDelegate.color != color;
}
