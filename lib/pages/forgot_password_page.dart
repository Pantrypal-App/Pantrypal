import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String? emailError;
  bool isLoading = false;
  bool emailSent = false;

  Future<void> resetPassword() async {
    setState(() {
      emailError = null;
      isLoading = true;
    });

    if (!_formKey.currentState!.validate()) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      
      setState(() {
        isLoading = false;
        emailSent = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Password reset email sent successfully!"),
        backgroundColor: Colors.green,
      ));
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
        if (e.code == 'user-not-found') {
          emailError = "No account found with this email.";
        } else if (e.code == 'invalid-email') {
          emailError = "Please enter a valid email address.";
        } else {
          emailError = "Error sending reset email. Please try again.";
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        emailError = "Something went wrong. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Same background image as login page
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/images/iPhone 14 & 15 Pro - 31.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    const Text(
                      "Reset Password",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Description
                    const Text(
                      "Enter your email address and we'll send you a link to reset your password.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Email Field
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email),
                        labelText: "Email",
                        labelStyle: const TextStyle(color: Colors.black87),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        errorText: emailError,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your email.";
                        }
                        // Basic email validation
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return "Please enter a valid email address.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),

                    // Send Reset Email Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading || emailSent ? null : resetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[300],
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                        ),
                        child: isLoading 
                          ? const CircularProgressIndicator(color: Colors.green)
                          : Text(
                              emailSent ? "EMAIL SENT" : "SEND RESET LINK",
                              style: TextStyle(
                                color: emailSent ? Colors.green : Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Back to Login
                    TextButton.icon(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      label: const Text(
                        "Back to Login", 
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}