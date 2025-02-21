//analyze_page.dart
import 'package:flutter/material.dart';
import 'nocacao.dart';
import 'dart:io';
import 'objectdetection.dart'; // Add this import
import 'detectionresult.dart'; // Add this import

class AnalyzePage extends StatefulWidget {
  // Changed to StatefulWidget
  final File image;

  const AnalyzePage({Key? key, required this.image}) : super(key: key);

  @override
  State<AnalyzePage> createState() => _AnalyzePageState();
}

class _AnalyzePageState extends State<AnalyzePage> {
  final ObjectDetectionService _detectionService = ObjectDetectionService();
  bool _isAnalyzing = false;
  bool _isInitialized = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    try {
      await _detectionService.initialize();
      setState(() {
        _isInitialized = true;
        _initError = null;
      });
    } catch (e) {
      setState(() {
        _isInitialized = false;
        _initError = e.toString();
      });
      print('Initialization error: $e');
    }
  }

  Future<void> _analyzeImage() async {
    if (!_isInitialized) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Model not initialized. Error: $_initError'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final results = await _detectionService.detectObjects(widget.image);

      if (!mounted) return;

      if (results['detections'].isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetectionResultScreen(
              image: widget.image,
              detections: results['detections'],
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NoCacaoScreen(image: widget.image),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('An error occurred while analyzing the image: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF832637),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15.0, top: 100.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/PODScan.png',
                    height: 70,
                  ),
                  const SizedBox(width: 8),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontFamily: 'CinzelDecorative',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: 'POD',
                          style: TextStyle(color: Color(0xFF7ED957)),
                        ),
                        TextSpan(
                          text: 'SCAN',
                          style: TextStyle(color: Color(0xFFFFDE59)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.all(16),
              height: 500,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.file(
                  widget.image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: _isAnalyzing
                  ? const CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF628E6E)),
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF628E6E),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(200, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                      ),
                      onPressed:
                          _analyzeImage, // Changed to use new analyze function
                      child: const Text(
                        'Analyze',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
