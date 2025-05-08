import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'register_page.dart';
import 'Home_page.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '857082234698-50e42f0mpovfvdig2oga7485cibrpqol.apps.googleusercontent.com',
  );

  bool _obscurePassword = true; // 👁️ Controls visibility

  String? emailError;
  String? passwordError;

  // Sign out the user from Google and Firebase
  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
    print("User signed out from Google and Firebase.");
  }

  Future<User?> signInWithGoogle() async {
    try {
      // Sign out first to ensure a fresh login
      await signOutGoogle();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled the sign-in

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) return null;

      // Save user data in Firestore if it doesn't already exist
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        await userRef.set({
          'email': user.email,
          'name': user.displayName,
          'profilePic': user.photoURL,
        }, SetOptions(merge: true));
      }

      // Automatically sign in the user if everything is successful
      return user;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  Future<void> login() async {
    setState(() {
      emailError = null;
      passwordError = null;
    });

    if (!_formKey.currentState!.validate()) {
      return; // Stop if validation fails
    }

    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Login Successful!"),
        backgroundColor: Colors.green,
      ));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      print("🔥 FirebaseAuthException caught with code: ${e.code}");
      setState(() {
        if (e.code == 'user-not-found') {
          emailError = "No account found with this email.";
        } else if (e.code == 'wrong-password') {
          passwordError = "Incorrect password. Please try again.";
        } else if (e.code == 'invalid-email') {
          emailError = "Please enter a valid email address.";
        } else {
          passwordError = "Invalid login credentials. Please try again.";
        }
      });
    } catch (e) {
      print("🛑 Unexpected error: $e"); // Add this line
      setState(() {
        passwordError = "Something went wrong. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
                    const Text(
                      "Log In",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Email Field
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email),
                        labelText: "Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        errorText: emailError, // Show error below field
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your email.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Password Field
                    TextFormField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock),
                        labelText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        errorText: passwordError,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: passwordError != null
                                ? Colors.black
                                : Colors.black, // Set color based on error
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "The Password field is required.";
                        }
                        return null;
                      },
                    ),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ForgotPasswordPage()),
                          );
                        },
                        child: const Text("Forgot Password?"),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                        ),
                        child: const Text(
                          "Sign In",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Google Button - Full Width
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await signOutGoogle(); // Sign out before logging in again
                          User? user = await signInWithGoogle();
                          if (user != null) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage()),
                            );
                          } else {
                            // Handle failed sign-in
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "Google Sign-In failed! Please try again."),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: Image.asset(
                          "lib/images/images-removebg-preview (3).png",
                          height: 20,
                        ),
                        label: const Text("Sign In With Google",
                            style: TextStyle(color: Colors.black)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Don't have an account? Sign Up
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const RegisterPage()),
                            );
                          },
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
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