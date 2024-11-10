// ignore_for_file: avoid_print, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AphidControl extends StatelessWidget {
  const AphidControl({super.key});

  // Function to fetch the aphid control measures document from Firestore
  Future<Map<String, dynamic>?> _fetchControlMeasuresData() async {
    try {
      // Fetching the 'aphid control measure' document from the 'pests' collection
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection('pests')
              .doc('aphid control measure')
              .get();

      if (documentSnapshot.exists) {
        return documentSnapshot.data();
      } else {
        print('Document does not exist');
        return null;
      }
    } catch (e) {
      print('Error fetching data: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aphid Control Measure', style: TextStyle(fontSize: 20, letterSpacing: 1)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
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
        future: _fetchControlMeasuresData(),
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, dynamic>?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data available'));
          } else {
            // Extract data from Firestore document
            Map<String, dynamic> controlMeasuresData = snapshot.data!;

            // Get and sort keys alphabetically
            List<String> sortedKeys = controlMeasuresData.keys.toList()..sort();

            return Padding(
              padding: const EdgeInsets.all(20.0), // Consistent padding
              child: Scrollbar(
                trackVisibility: true,
                thickness: 6,
                radius: const Radius.circular(20),
                interactive: true,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: sortedKeys.map((key) {
                      var content = controlMeasuresData[key];

                      // Check if content is a nested map or a simple value
                      if (content is Map<String, dynamic>) {
                        // Handle nested map by iterating over subcategories
                        return _buildNestedCard(context, key, content);
                      } else {
                        // Handle if it's just a string or simple content
                        return _buildInfoCard(
                          context,
                          title: key,
                          content: content.toString(),
                        );
                      }
                    }).toList(),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  // Handle nested map content and build info cards for subcategories
  Widget _buildNestedCard(
      BuildContext context, String key, Map<String, dynamic> content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0), // Spacing around nested cards
      child: _buildInfoCard(
        context,
        title: key,
        content: content.entries.map((subEntry) {
          String subCategory = subEntry.key;
          List<dynamic> subContent = subEntry.value;

          // Join list items as a single string for display
          String joinedContent = subContent.join('\n- ');

          return '$subCategory:\n- $joinedContent';
        }).join('\n\n'),
      ),
    );
  }

  // Reusable Card Widget for displaying information sections
  Widget _buildInfoCard(BuildContext context,
      {required String title, required String content}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // More subtle rounded corners
      ),
      elevation: 4, // Softer shadow for a more modern look
      color: const Color(0xFFFFFAD2), // Background color
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Comfortable padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: const Color(0xFF2D6A4F), // Title color
                    fontWeight: FontWeight.bold,
                    fontSize: 20, // Reduced for a cleaner look
                  ),
            ),
            const SizedBox(height: 8), // Adjusted spacing
            const Divider(
              color: Color(0xFF2D6A4F),
              thickness: 1.5,
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                fontSize: 16.0, // Modern, clean font size
                fontWeight: FontWeight.normal, // Regular weight for simplicity
                height: 1.5, // Clear line spacing
                color: Colors.black87,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}
