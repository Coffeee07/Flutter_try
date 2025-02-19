import 'dart:io';
import 'package:coffee_card/models/yolov5s.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'analyze_page.dart';

class HomeScreen extends StatefulWidget {
  final Yolov5sModel yoloModel;

  const HomeScreen({super.key, required this.yoloModel});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // File? _selectedImage;
  late Yolov5sModel _yoloModel;

  @override
  void initState() {
    super.initState();
    _yoloModel = widget.yoloModel;
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _navigateToAnalyzePage(File(pickedFile.path));
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);

      if (photo != null) {
        _navigateToAnalyzePage(File(photo.path));
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _checkCameraPermission() async {
    if (await Permission.camera.request().isGranted) {
      await _takePhoto();
    } else if (await Permission.camera.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  void _navigateToAnalyzePage(File image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalyzePage(
          image: image,
          yoloModel: _yoloModel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('home page');
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Color(0xFF832637),
      child: Column(
        children: [
          Expanded(child: _buildMainContent()),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLogo(),
        const SizedBox(height: 40),
        _buildButtons(),
      ],
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Image.asset(
          'assets/images/PODScan.png',
          height: 100,
        ),
        const SizedBox(height: 10),
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontFamily: 'CinzelDecorative',
              fontSize: 32,
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
      ]
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildButton(
            label: 'Take Photo',
            color: const Color(0xFFF1E6BB),
            textColor: Colors.black,
            onPressed: _checkCameraPermission,
          ),
          const SizedBox(height: 20),
          _buildButton(
            label: 'Upload Photo',
            color: const Color(0xFF628E6E),
            textColor: Colors.black,
            onPressed: _pickImageFromGallery,
          )
        ],
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        minimumSize: const Size(220, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.black.withOpacity(0.3),
      child: const Text(
        'Developed by: Bicol University Students',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

}
