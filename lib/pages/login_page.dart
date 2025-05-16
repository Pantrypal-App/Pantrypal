import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'register_page.dart';
import 'package:pantrypal/pages/Home_page.dart';
import 'forgot_password_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

Future<void> checkLoginStatus(BuildContext context) async {
  try {
    // First check if Firebase has a cached user session
    User? currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser != null) {
      // Firebase says user is already logged in, redirect to home
      print("User already signed in: ${currentUser.email}");
      
      // Update SharedPreferences to match Firebase state
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      
      // No need to refresh the token or reauth - Firebase handles token refresh automatically
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
      return;
    }
    
    // If no active Firebase session, check SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    
    if (isLoggedIn) {
      // User was previously logged in but Firebase session expired
      // This can happen after app updates or after long periods
      
      // If they last used Google sign-in, we don't want to force them to sign in manually
      // Firebase will attempt to refresh the token silently
      
      // Wait briefly to see if Firebase auto-restores the session
      await Future.delayed(const Duration(seconds: 1));
      
      // Check again if Firebase auto-restored the session
      currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser != null) {
        // Session was restored automatically
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        // Force the user to sign in again - their session truly expired
        // This is expected behavior when user explicitly logged out
        await prefs.setBool('isLoggedIn', false);
      }
    }
  } catch (e) {
    print("Error checking login status: $e");
    // Stay on login page if there's any error
  }
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _obscurePassword = true;
  String? emailError;
  String? passwordError;
  bool _isLoading = false;
  bool _isCheckingLogin = true; // Add flag to track initial login check

  @override
  void initState() {
    super.initState();
    // Check login status when the page initializes
    _checkPreviousLogin();
  }
  
  Future<void> _checkPreviousLogin() async {
    setState(() {
      _isCheckingLogin = true;
    });
    
    try {
      await checkLoginStatus(context);
    } catch (e) {
      print("Error during initial login check: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingLogin = false;
        });
      }
    }
  }

  Future<User?> signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Begin Google sign-in flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in
        setState(() {
          _isLoading = false;
        });
        return null;
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create Firebase credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Save user data in Firestore if it doesn't already exist
        await _saveUserToFirestore(user);
        
        // Save login state with provider type so we know they used Google
        await _saveLoginState(isGoogleSignIn: true);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Google Sign-In Successful!"),
          backgroundColor: Colors.green,
        ));
      }

      return user;
    } catch (e, stackTrace) {
      print("Google Sign-In Error: $e");
      print("Stack trace: $stackTrace");
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to sign in with Google. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
      
      return null;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUserToFirestore(User user) async {
    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        await userRef.set({
          'email': user.email,
          'name': user.displayName,
          'profilePic': user.photoURL,
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        // Update last login timestamp
        await userRef.update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print("Error saving user data: $e");
      // Continue with the login process even if Firestore update fails
    }
  }

  Future<void> _saveLoginState({bool isGoogleSignIn = false}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      
      // Track if the user logged in with Google
      if (isGoogleSignIn) {
        await prefs.setBool('usedGoogleSignIn', true);
      }
      
      // Also store the user ID for additional verification
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await prefs.setString('userId', currentUser.uid);
      }
    } catch (e) {
      print("Error saving login state: $e");
    }
  }

  Future<void> login() async {
    setState(() {
      emailError = null;
      passwordError = null;
      _isLoading = true;
    });

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = false;
      });
      return; // Stop if validation fails
    }

    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Store login state with email provider specified
      await _saveLoginState(isGoogleSignIn: false);

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
      print("🛑 Unexpected error: $e"); 
      setState(() {
        passwordError = "Something went wrong. Please try again.";
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
          // Show a loading screen while checking login status
          if (_isCheckingLogin)
            Container(
              color: Colors.white.withOpacity(0.7),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          if (!_isCheckingLogin)
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
                      keyboardType: TextInputType.emailAddress,
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
                                builder: (context) =>
                                    const ForgotPasswordPage()),
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
                        onPressed: _isLoading ? null : login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                          // Dim the button when loading
                          foregroundColor: _isLoading ? Colors.grey[400] : null,
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
                        onPressed: _isLoading
                            ? null
                            : () async {
                                User? user = await signInWithGoogle();
                                if (user != null) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HomePage()),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          // Dim the button when loading
                          foregroundColor: _isLoading ? Colors.grey[400] : null,
                        ),
                        icon: Image.asset(
                          "lib/images/images-removebg-preview.png",
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

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}