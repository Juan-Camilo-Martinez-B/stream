import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/uml_models.dart';

class RelationsPainter extends CustomPainter {
  final UmlState state;

  RelationsPainter(this.state);

  @override
  void paint(Canvas canvas, Size size) {
    for (var relation in state.relations) {
      final source = state.getClassById(relation.sourceClassId);
      final target = state.getClassById(relation.targetClassId);

      if (source != null && target != null) {
        final sourceHeight = _getEstimatedHeight(source);
        final targetHeight = _getEstimatedHeight(target);

        // Calculate actual centers based on dynamic height
        final p1Center = Offset(
          source.position.dx + 100,
          source.position.dy + sourceHeight / 2,
        );
        final p2Center = Offset(
          target.position.dx + 100,
          target.position.dy + targetHeight / 2,
        );

        // Calculate intersection with class bounding box dynamically
        final p1Edge = _getIntersectionPoint(
          p1Center,
          p2Center,
          Size(200, sourceHeight),
        );
        final p2Edge = _getIntersectionPoint(
          p2Center,
          p1Center,
          Size(300, targetHeight),
        );

        final paint = Paint()
          ..color = const Color(0xFF00FFC4)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

        if (relation.type == RelationType.realization ||
            relation.type == RelationType.dependency) {
          _drawDashedLine(canvas, p1Edge, p2Edge, paint);
        } else {
          canvas.drawLine(p1Edge, p2Edge, paint);
        }

        _drawRelationshipSymbol(canvas, p1Edge, p2Edge, paint, relation.type);
      }
    }
  }

  Offset _getIntersectionPoint(Offset center, Offset target, Size size) {
    final double dx = target.dx - center.dx;
    final double dy = target.dy - center.dy;

    if (dx == 0 && dy == 0) return center;

    final double width = size.width / 2;
    final double height = size.height / 2;

    double x = 0;
    double y = 0;

    if (dx.abs() * height > dy.abs() * width) {
      x = dx > 0 ? width : -width;
      y = x * dy / dx;
    } else {
      y = dy > 0 ? height : -height;
      x = y * dx / dy;
    }

    return Offset(center.dx + x, center.dy + y);
  }

  double _getEstimatedHeight(UmlClass c) {
    double height = 70.0; // Header + Buttons + minimum paddings
    if (c.attributes.isNotEmpty) {
      height += 18.0 + (c.attributes.length * 20.0);
    }
    if (c.methods.isNotEmpty) {
      height += 18.0 + (c.methods.length * 20.0);
    }
    return height;
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    final double distance = (p2 - p1).distance;
    final double dashWidth = 6.0;
    final double dashSpace = 4.0;
    final double dx = (p2.dx - p1.dx) / distance;
    final double dy = (p2.dy - p1.dy) / distance;

    double currentDistance = 0.0;
    while (currentDistance < distance) {
      final double endDistance = math.min(
        currentDistance + dashWidth,
        distance,
      );
      final Offset start = Offset(
        p1.dx + dx * currentDistance,
        p1.dy + dy * currentDistance,
      );
      final Offset end = Offset(
        p1.dx + dx * endDistance,
        p1.dy + dy * endDistance,
      );
      canvas.drawLine(start, end, paint);
      currentDistance += dashWidth + dashSpace;
    }
  }

  void _drawRelationshipSymbol(
    Canvas canvas,
    Offset p1,
    Offset p2,
    Paint paint,
    RelationType type,
  ) {
    final double dx = p2.dx - p1.dx;
    final double dy = p2.dy - p1.dy;
    final double angle = math.atan2(dy, dx);

    // Save original style
    final originalStyle = paint.style;
    final originalColor = paint.color;

    if (type == RelationType.inheritance || type == RelationType.realization) {
      // Hollow triangle at target
      final Path path = Path();
      final double arrowLength = 16.0;
      final double arrowWidth = 10.0;

      path.moveTo(p2.dx, p2.dy);
      path.lineTo(
        p2.dx - arrowLength * math.cos(angle) + arrowWidth * math.sin(angle),
        p2.dy - arrowLength * math.sin(angle) - arrowWidth * math.cos(angle),
      );
      path.lineTo(
        p2.dx - arrowLength * math.cos(angle) - arrowWidth * math.sin(angle),
        p2.dy - arrowLength * math.sin(angle) + arrowWidth * math.cos(angle),
      );
      path.close();

      paint.style = PaintingStyle.fill;
      paint.color = const Color(
        0xFF0D0D14,
      ); // Background color so it's "hollow"
      canvas.drawPath(path, paint);

      paint.style = PaintingStyle.stroke;
      paint.color = const Color(0xFF00FFC4);
      canvas.drawPath(path, paint);
    } else if (type == RelationType.aggregation ||
        type == RelationType.composition) {
      // Diamond at source
      final Path path = Path();
      final double diamondLength = 16.0;
      final double diamondWidth = 8.0;

      path.moveTo(p1.dx, p1.dy); // attach to source
      path.lineTo(
        p1.dx +
            (diamondLength / 2) * math.cos(angle) -
            diamondWidth * math.sin(angle),
        p1.dy +
            (diamondLength / 2) * math.sin(angle) +
            diamondWidth * math.cos(angle),
      );
      path.lineTo(
        p1.dx + diamondLength * math.cos(angle),
        p1.dy + diamondLength * math.sin(angle),
      );
      path.lineTo(
        p1.dx +
            (diamondLength / 2) * math.cos(angle) +
            diamondWidth * math.sin(angle),
        p1.dy +
            (diamondLength / 2) * math.sin(angle) -
            diamondWidth * math.cos(angle),
      );
      path.close();

      if (type == RelationType.composition) {
        paint.style = PaintingStyle.fill;
        paint.color = const Color(0xFF00FFC4); // Filled diamond
        canvas.drawPath(path, paint);
      } else {
        paint.style = PaintingStyle.fill;
        paint.color = const Color(0xFF0D0D14); // Hollow diamond
        canvas.drawPath(path, paint);

        paint.style = PaintingStyle.stroke;
        paint.color = const Color(0xFF00FFC4);
        canvas.drawPath(path, paint);
      }
    } else if (type == RelationType.directedAssociation ||
        type == RelationType.dependency) {
      // Open arrow at target
      final Path path = Path();
      final double arrowLength = 12.0;
      final double arrowWidth = 8.0;

      path.moveTo(
        p2.dx - arrowLength * math.cos(angle) + arrowWidth * math.sin(angle),
        p2.dy - arrowLength * math.sin(angle) - arrowWidth * math.cos(angle),
      );
      path.lineTo(p2.dx, p2.dy);
      path.lineTo(
        p2.dx - arrowLength * math.cos(angle) - arrowWidth * math.sin(angle),
        p2.dy - arrowLength * math.sin(angle) + arrowWidth * math.cos(angle),
      );

      canvas.drawPath(path, paint..style = PaintingStyle.stroke);
    }

    paint.style = originalStyle;
    paint.color = originalColor;
  }

  @override
  bool shouldRepaint(covariant RelationsPainter oldDelegate) {
    return oldDelegate.state != state;
  }
}
