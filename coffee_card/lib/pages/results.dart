import 'package:PODScan/models/resnetVariety.dart';
import 'package:flutter/material.dart';
import 'package:PODScan/models/yolov5s.dart';
import 'package:PODScan/models/resnetDisease.dart';
import 'home_screen.dart';

class ResultsScreen extends StatefulWidget {
  final String cacaoVariety;
  final String diseaseType;
  final String pestType;
  final String severityLevel;
  final Image analyzedImage; // Image with bounding box

  final Yolov5sModel yoloModel;
  final ResNetDiseaseModel resnetDiseaseModel;
  final ResNetVarietyModel resnetVarietyModel;

  const ResultsScreen({
    super.key,
    required this.cacaoVariety,
    required this.diseaseType,
    required this.pestType,
    required this.severityLevel,
    required this.analyzedImage,
    required this.yoloModel,
    required this.resnetDiseaseModel,
    required this.resnetVarietyModel,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF832637),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: screenHeight * 0.3,
            collapsedHeight: screenHeight * 0.2,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Image
                    Image(
                      image: widget.analyzedImage.image,
                      fit: BoxFit.cover,
                    ),
                    // Bottom Gradient Effect
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 350, // Adjust as needed
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.8), // Dark at bottom
                              Colors.transparent, // Fades upward
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 15),
              _buildContent(),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          _buildVarietyBox(), //for Cacao Variety
          const SizedBox(height: 10),
          _buildDescriptionBox(), // for Description
          const SizedBox(height: 10),
          _buildResultsBox(), // for Results
          const SizedBox(height: 15),
          _buildHomeButton(context),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  //cacao variety NSIC info
  Map<String, String> cacaoNSICNumbers = {
    'BR25': 'NSIC 2000 Cc05',
    'UF18': 'NSIC 1997 Cc01',
    'PBC123': 'NSIC 2014 Cc 11',
  };

  Widget _buildVarietyBox() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              widget.cacaoVariety,
              style: const TextStyle(
                fontFamily: 'CinzelDecorative',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(),
          Center(
            child: Text(
              cacaoNSICNumbers[widget.cacaoVariety] ?? 'Unknown NSIC Number',
              style: const TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 100, 100, 100),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionBox() {
    String description = _getCacaoDescription(widget.cacaoVariety);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description:',
            style: TextStyle(
              fontFamily: 'CinzelDecorative',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          Text(
            description,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsBox() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Results:',
            style: TextStyle(
              fontFamily: 'CinzelDecorative',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          _buildInfoRow('Disease Type:', widget.diseaseType),
          _buildInfoRow('Pest Type:', widget.pestType),
          _buildInfoRow('Severity Level:', widget.severityLevel),
          const SizedBox(height: 10),
          _buildExpandableSection(),
        ],
      ),
    );
  }

  Widget _buildHomeButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF628E6E),
          foregroundColor: Colors.white,
          minimumSize: const Size(200, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5,
        ),
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                yoloModel: widget.yoloModel,
                resnetDiseaseModel: widget.resnetDiseaseModel,
                resnetVarietyModel: widget.resnetVarietyModel,
              ),
            ),
            (route) => false, // Clears all previous screens
          );
        },
        child: const Text(
          'Home',
          style: TextStyle(
            fontFamily: 'CinzelDecorative',
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  //cacao description
  String _getCacaoDescription(String variety) {
    switch (variety.toLowerCase()) {
      case 'uf18':
        return 'UF18 (Upper Amazon Forastero 18) is characterized by its maroon-colored pods and early fruiting, typically within 1-2 years.'
            'It belongs to the Trinitario group, renowned for its high productivity and resistance to diseases.';
      case 'br25':
        return 'BR25 (Bahia Reale) is cacao variety with reddish pods that turn yellow when mature,'
            'elliptical leaves with wavy margins. It begins flowering at around 16 months and fruits by 17.7 months.';
      case 'pbc123':
        return 'PBC123 (Pound B-Clone 123) is a cacao variety recognized for its high yield and disease resistance.'
            'Its pods are red when young and transition to orange-red upon maturity, with medium to large size.'
            'The trees are vigorous and well-suited to diverse growing conditions.';
      default:
        return 'No specific description available for this cacao variety.';
    }
  }

  //put under this comment the pest and disease description

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 17,
            color: Colors.black,
          ),
          children: [
            TextSpan(
              text: label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: ' $value'),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'What to do?',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontFamily: 'CinzelDecorative',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[300],
            child: const Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed tempor incididunt.'
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed tempor incididunt.'
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed tempor incididunt.'
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed tempor incididunt.'
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed tempor incididunt.',
              style: TextStyle(fontSize: 15),
            ),
          ),
      ],
    );
  }
}
