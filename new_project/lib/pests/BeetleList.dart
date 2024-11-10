// ignore_for_file: file_names, non_constant_identifier_names, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BeetleList extends StatelessWidget {
  const BeetleList({super.key});

  // Function to fetch brown marmorated stink bugs data from Firestore
  Future<Map<String, dynamic>?> _fetchBeetleData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection('pests')
              .doc('beetle')
              .get();

      if (documentSnapshot.exists) {
        return documentSnapshot.data(); // Return the data as a map
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beetle Information', style: TextStyle(fontSize: 20, letterSpacing: 1)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchBeetleData(),
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, dynamic>?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data available'));
          } else {
            // Extract data from snapshot
            Map<String, dynamic> beetleData = snapshot.data!;
            String description =
                beetleData['description'] ?? 'No description available';
            String habitat =
                beetleData['habitat'] ?? 'No habitat information available';
            String impact =
                beetleData['impact'] ?? 'No impact information available';

            return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Scrollbar(
                  trackVisibility: true,
                  thickness: 6,
                  radius: Radius.circular(20),
                  interactive: true,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header Section with Aphid Image
                        _buildImageSection(),

                        const SizedBox(height: 20),

                        // Modular Cards for description, habitat, and impact
                        _buildInfoBlock(
                          context,
                          title: 'Description',
                          content: description,
                          color: const Color(0xFF2D6A4F),
                        ),
                        const SizedBox(height: 16),

                        _buildInfoBlock(
                          context,
                          title: 'Habitat',
                          content: habitat,
                          color: const Color(0xFF1B4332),
                        ),
                        const SizedBox(height: 16),

                        _buildInfoBlock(
                          context,
                          title: 'Impact',
                          content: impact,
                          color: const Color(0xFF4CAF50),
                        ),
                      ],
                    ),
                  ),
                ));
          }
        },
      ),
    );
  }

  // Modular Card Widget for displaying information sections
  Widget _buildInfoBlock(BuildContext context,
      {required String title, required String content, required Color color}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 5,
      color: color.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with bold, modern font and flat design look
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 10),

            // Content with a clean, flat typography
            Text(
              content,
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.white70,
                height: 1.6,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  // Header Section with BMSB Image and a flat, modern look
  Widget _buildImageSection() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        image: const DecorationImage(
          image: AssetImage('assets/beetle.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
