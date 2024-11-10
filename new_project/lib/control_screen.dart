// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'control/AphidControl.dart';
import 'control/ArmywormControl.dart';
import 'control/BeetleControl.dart';
import 'control/MiteControl.dart';
import 'control/SawflyControl.dart';
import 'control/StemBorerControl.dart';
import 'control/StemflyControl.dart';
import 'favorite_control.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  _ControlScreenState createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  final List<Map<String, String>> items = [
    {'image': 'assets/aphids.jpg', 'name': 'Aphid'},
    {'image': 'assets/armyworms.jpeg', 'name': 'Armyworm'},
    {'image': 'assets/beetle.jpg', 'name': 'Beetle'},
    {'image': 'assets/mite.jpg', 'name': 'Mite'},
    {'image': 'assets/sawfly.jpg', 'name': 'Sawfly'},
    {'image': 'assets/stemborer.jpg', 'name': 'Stem Borer'},
    {'image': 'assets/stemfly.jpg', 'name': 'Stemfly'},
  ];

  final Set<String> _favorites = {}; // Set to keep track of favorite pests
  late final PageController _pageController;
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    items.sort((a, b) => a['name']!.compareTo(b['name']!));
    _pageController = PageController(initialPage: 0, viewportFraction: 0.8);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0;
      });
    });
    _loadFavorites(); // Load favorites on initialization
  }

  Future<void> _loadFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final favoritesRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorite_control');

      try {
        final snapshot = await favoritesRef.get();
        setState(() {
          _favorites.clear(); // Clear current favorites
          for (var doc in snapshot.docs) {
            _favorites.add(doc['name']); // Add fetched favorites
          }
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading favorites: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _addToFavorites(String pestName) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // You can choose to handle this case differently, such as showing an alert dialog.
      return;
    }

    final userId = user.uid;
    final favoritesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorite_control');

    try {
      final snapshot = await favoritesRef.doc(pestName).get();

      if (snapshot.exists) {
        // If it's already a favorite, remove it
        await favoritesRef.doc(pestName).delete();
        _favorites.remove(pestName); // Update the local set
      } else {
        // If it's not a favorite, add it
        await favoritesRef.doc(pestName).set({'name': pestName});
        _favorites.add(pestName); // Update the local set
      }
      setState(() {}); // Trigger a rebuild to update the icon color
    } catch (e) {
      // Handle errors silently or log them if necessary
      print('Error adding to favorites: $e');
    }
  }

  void _navigateToDetailScreen(BuildContext context, String pestName) {
    switch (pestName) {
      case 'Aphid':
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const AphidControl()));
        break;
      case 'Armyworm':
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ArmywormControl()));
        break;
      case 'Beetle':
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const BeetleControl()));
        break;
      case 'Mite':
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const MiteControl()));
        break;
      case 'Sawfly':
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const SawflyControl()));
        break;
      case 'Stem Borer':
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const StemBorerControl()));
        break;
      case 'Stemfly':
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const StemflyControl()));
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF50C878).withOpacity(0.9),
              const Color(0xFF2D6A4F).withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: PageView.builder(
              controller: _pageController,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final scale = (_currentPage - index).abs();
                final cardScale = (1 - scale).clamp(0.8, 1.0);
                final opacity = cardScale;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 53.0),
                  child: Transform.scale(
                    scale: cardScale,
                    child: Opacity(
                      opacity: opacity,
                      child: GestureDetector(
                        onTap: () =>
                            _navigateToDetailScreen(context, item['name']!),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.symmetric(horizontal: 10.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF2D6A4F).withOpacity(0.9),
                                const Color(0xFF1B4332).withOpacity(0.9),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 15,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Align the heart icon to the right
                              Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  icon: Icon(
                                    _favorites.contains(item['name'])
                                        ? Icons.favorite // Solid heart icon
                                        : Icons
                                            .favorite_border, // Outline heart icon
                                    color: _favorites.contains(item['name'])
                                        ? Colors.red // Red color if favorite
                                        : Colors.white, // Default color if not
                                    size: 24.0,
                                  ),
                                  onPressed: () =>
                                      _addToFavorites(item['name']!),
                                ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: Image.asset(
                                    item['image']!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                alignment: Alignment
                                    .topCenter, // Aligns text to the top center
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Text(
                                  item['name']!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const FavoriteControl()));
        },
        child: const Icon(Icons.favorite),
      ),
    );
  }
}
