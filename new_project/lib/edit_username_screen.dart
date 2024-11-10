import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditUsernameScreen extends StatefulWidget {
  final String currentUsername;
  final Function(String) onUsernameChanged;

  const EditUsernameScreen({
    super.key,
    required this.currentUsername,
    required this.onUsernameChanged,
  });

  @override
  _EditUsernameScreenState createState() => _EditUsernameScreenState();
}

class _EditUsernameScreenState extends State<EditUsernameScreen> {
  late TextEditingController _usernameController;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.currentUsername);
  }

  Future<void> _saveUsername() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String newUsername = _usernameController.text.trim();

      if (newUsername.isEmpty) {
        throw Exception('Username cannot be empty');
      }

      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Update the username in Firestore
      await FirebaseFirestore.instance
          .collection(
              'users') // Make sure this matches your Firestore structure
          .doc(userId)
          .update({'username': newUsername});

      // Call the callback function to update the parent UI
      widget.onUsernameChanged(newUsername);

      // Go back to the previous screen
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Username'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'New Username'),
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _saveUsername,
                child: const Text('Save'),
              ),
          ],
        ),
      ),
    );
  }
}
