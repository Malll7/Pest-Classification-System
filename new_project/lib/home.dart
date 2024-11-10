import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:new_project/firestore_service.dart';

import 'list_screen.dart';
import 'login.dart';
import 'camera_screen.dart';
import 'control_screen.dart';
import 'edit_username_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.username});

  final String username;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _todoController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  String? _username;

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    String? username = await _firestoreService.getUsername(userId);
    setState(() {
      _username = username ?? widget.username;
    });
  }

  @override
  void dispose() {
    _todoController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  String getRandomGreeting() {
    final greetings = ['Hello!', 'Hola!', 'Welcome Back!'];
    final randomIndex = Random().nextInt(greetings.length);
    return greetings[randomIndex];
  }

  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (kDebugMode) {
        print('User signed out successfully');
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Sign-out error: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign out: $e')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _addTodoItem() {
    if (_todoController.text.isNotEmpty) {
      final title = _todoController.text;

      _firestoreService.addTodoItem(
          FirebaseAuth.instance.currentUser!.uid, title);
      _todoController.clear();
    }
  }

  void _submitFeedback() {
    if (_feedbackController.text.isNotEmpty) {
      _firestoreService.saveFeedback(
          FirebaseAuth.instance.currentUser!.uid, _feedbackController.text);
      _feedbackController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback submitted!')),
      );
    }
  }

  void _showTodoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('To-Do List',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _todoController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[200],
                    labelText: 'New To-Do',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 300.0,
                  ),
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _firestoreService
                        .getTodoList(FirebaseAuth.instance.currentUser!.uid),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final todos = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: todos.length,
                        itemBuilder: (context, index) {
                          final todo = todos[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            color: Color(0xFFFFFAD2),
                            elevation: 4,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16.0),
                              title: Text(
                                todo['title'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _firestoreService.deleteTodoItem(
                                      FirebaseAuth.instance.currentUser!.uid,
                                      todo['id']);
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // Center the buttons
            children: [
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(width: 16), // Add some spacing between the buttons
              ElevatedButton(
                onPressed: () {
                  _addTodoItem();
                  _todoController.clear();
                },
                child: const Text('Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Submit Feedback',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: _feedbackController,
            minLines: 1, // Minimum number of lines to display
            maxLines: null, // Allow the field to expand vertically
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[200],
              labelText: 'Your feedback',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // Center the buttons
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 16), // Add some spacing between the buttons
              ElevatedButton(
                onPressed: () {
                  _submitFeedback();
                  Navigator.of(context).pop();
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static const List<Widget> _widgetOptions = <Widget>[
    CameraScreen(),
    ListScreen(),
    ControlScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1B4332),
                Color(0xFF2D6A4F),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png', // Your logo file path
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 8),
            Text('PestWise', style: TextStyle(fontSize: 20, letterSpacing: 1)),
          ],
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    DrawerHeader(
                      decoration: const BoxDecoration(
                        color: Color(0xFF2D6A4F),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  getRandomGreeting(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight
                                        .w500, // Medium weight for a modern look
                                  ),
                                ),
                                const SizedBox(
                                    height:
                                        4), // Add some spacing between the lines
                                Text(
                                  _username ?? 'User',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        22, // Slightly larger font size for emphasis
                                    fontWeight: FontWeight
                                        .bold, // Bold text for emphasis
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => EditUsernameScreen(
                                    currentUsername: _username ?? '',
                                    onUsernameChanged: (String newUsername) {
                                      setState(() {
                                        _username = newUsername;
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.list),
                      title: const Text('To-Do List'),
                      onTap: () => _showTodoDialog(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.feedback),
                      title: const Text('Feedback'),
                      onTap: () => _showFeedbackDialog(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Log Out'),
                      onTap: () => _logout(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: _selectedIndex == 0
                  ? const Color(0xFF2D6A4F)
                  : Colors.transparent,
              width: 2.0,
            ),
          ),
        ),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedIndex == 0
                      ? const Color(0xFF2D6A4F).withOpacity(0.2)
                      : Colors.transparent,
                ),
                child: Image.asset(
                  'assets/camera.png',
                  width: 24,
                  height: 24,
                ),
              ),
              label: 'Camera',
            ),
            BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedIndex == 1
                      ? const Color(0xFF2D6A4F).withOpacity(0.2)
                      : Colors.transparent,
                ),
                child: Image.asset(
                  'assets/insect.png',
                  width: 24,
                  height: 24,
                ),
              ),
              label: 'List',
            ),
            BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedIndex == 2
                      ? const Color(0xFF2D6A4F).withOpacity(0.2)
                      : Colors.transparent,
                ),
                child: Image.asset(
                  'assets/pesticide.png',
                  width: 24,
                  height: 24,
                ),
              ),
              label: 'Control',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF2D6A4F),
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
