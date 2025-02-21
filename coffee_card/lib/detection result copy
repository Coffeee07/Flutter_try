//detectionresult.dart
import 'dart:io';
import 'package:flutter/material.dart';

class DetectionResultScreen extends StatelessWidget {
  final File image;
  final List<Map<String, dynamic>> detections;

  const DetectionResultScreen({
    Key? key,
    required this.image,
    required this.detections,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF832637),
      body: Column(
        children: [
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                // Display the image
                Image.file(image),
                // Draw bounding boxes
                CustomPaint(
                  size: Size(MediaQuery.of(context).size.width - 32,
                      MediaQuery.of(context).size.width - 32),
                  painter: BoundingBoxPainter(detections),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Detected ${detections.length} cacao pods',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF628E6E),
              foregroundColor: Colors.white,
              minimumSize: const Size(200, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }
}

class BoundingBoxPainter extends CustomPainter {
  final List<Map<String, dynamic>> detections;

  BoundingBoxPainter(this.detections);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );

    for (final detection in detections) {
      final bbox = detection['bbox'] as List<dynamic>;
      final score = detection['score'] as double;

      final rect = Rect.fromLTRB(
        bbox[0].toDouble(),
        bbox[1].toDouble(),
        bbox[2].toDouble(),
        bbox[3].toDouble(),
      );

      canvas.drawRect(rect, paint);

      // Draw score
      textPainter.text = TextSpan(
        text: '${(score * 100).toStringAsFixed(1)}%',
        style: const TextStyle(
          color: Colors.green,
          fontSize: 14,
          backgroundColor: Colors.black54,
        ),
      );

      textPainter.layout();
      textPainter.paint(
          canvas, Offset(bbox[0].toDouble(), bbox[1].toDouble() - 20));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
