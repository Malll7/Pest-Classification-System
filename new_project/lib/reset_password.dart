import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController(); // Controller for email input
  bool _isLoading = false; // Loading state for the reset password button

  @override
  void dispose() {
    _emailController.dispose(); // Dispose of the email controller when done
    super.dispose();
  }

  /// Validates the email format using a regular expression.
  bool isEmail(String email) {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+'); 
    return regex.hasMatch(email); // Returns true if the email matches the regex
  }

  /// Sends a password reset email to the user.
  Future<void> resetPassword() async {
    final email = _emailController.text.trim(); // Get the trimmed email from the input

    if (email.isEmpty) {
      _showSnackBar('Please enter your email.');
      return;
    }

    // Validate email format using isEmail
    if (!isEmail(email)) {
      _showSnackBar('Please enter a valid email address.'); 
      return;
    }

    setState(() {
      _isLoading = true; // Set loading state to true
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email); // Send password reset email
      _showSnackBar('Password reset email sent! Check your inbox.');
      
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An unexpected error occurred.'; // Default error message
      if (e.code == 'invalid-email' || e.code == 'user-not-found') {
        errorMessage = 'No account found with that email.'; // Specific error message for invalid email
      }
      _showSnackBar(errorMessage); // Show error message in snackbar
    } catch (e) {
      _showSnackBar('An unexpected error occurred.'); // Show error message for other exceptions
    } finally {
      setState(() {
        _isLoading = false; // Set loading state to false after operation completes
      });
    }
  }

  /// Displays a snackbar with the provided message.
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.black87,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Enter your email to receive a password reset link.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              // Email input field
              TextField(
                controller: _emailController, // Assign the controller for email input
                decoration: InputDecoration(
                  labelText: "Email", // Label for the input field
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 30),

              // Reset Password button
              ElevatedButton(
                onPressed: resetPassword, // Call resetPassword when the button is pressed
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D6A4F), // Button background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0), // Rounded corners for the button
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 16.0),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white) // Show loading spinner if in loading state
                    : const Text(
                        "Reset Password",
                        style: TextStyle(fontSize: 16.0, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: false, // Prevents the screen from resizing when the keyboard appears
    );
  }
}
