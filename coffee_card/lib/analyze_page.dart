import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// Import the segmentation service
import 'cacao_segmentation_service.dart';

class AnalyzePage extends StatefulWidget {
  final File image;

  const AnalyzePage({Key? key, required this.image}) : super(key: key);

  @override
  State<AnalyzePage> createState() => _AnalyzePageState();
}

class _AnalyzePageState extends State<AnalyzePage> {
  final CacaoSegmentationService _segmentationService = CacaoSegmentationService();
  bool _isAnalyzing = false;
  File? _segmentedImage;

  @override
  void initState() {
    super.initState();
    // Load the model when the page initializes
    _segmentationService.loadModel();
  }

  @override
  void dispose() {
    _segmentationService.dispose();
    super.dispose();
  }

  Future<void> _analyzeImage() async {
    setState(() {
      _isAnalyzing = true;
    });

    try {
      final segmentedImage = await _segmentationService.processImage(widget.image);
      
      if (segmentedImage != null) {
        setState(() {
          _segmentedImage = segmentedImage;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to segment image')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/back.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'PodScan',
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.all(16),
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _segmentedImage != null
                    ? Image.file(
                        _segmentedImage!,
                        fit: BoxFit.contain,
                      )
                    : Image.file(
                        widget.image,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(height: 20),
            _isAnalyzing
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF1E6BB)),
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF1E6BB),
                      foregroundColor: Colors.black,
                      minimumSize: const Size(200, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 8,
                    ),
                    onPressed: _segmentedImage == null ? _analyzeImage : null,
                    child: Text(
                      _segmentedImage == null ? 'Analyze' : 'Analyzed',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
            if (_segmentedImage != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF628E6E),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 8,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}