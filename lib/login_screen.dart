import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'main_navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  void goNext(String role) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MainNavigation(role: role),
      ),
    );
  }

  // ================= EMAIL =================
  Future<void> loginEmail() async {
    setState(() => loading = true);

    try {
      final user = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      print("LOGIN EMAIL: ${user.user?.email}");

      if (!mounted) return;
      goNext("admin");
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Email login error")),
      );
    }

    if (mounted) setState(() => loading = false);
  }

  // ================= GOOGLE =================
  Future<void> loginGoogle() async {
    setState(() => loading = true);

    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final user = await FirebaseAuth.instance.signInWithCredential(credential);

      print("GOOGLE LOGIN: ${user.user?.email}");

      if (!mounted) return;
      goNext("admin");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Google login failed")),
      );
    }

    if (mounted) setState(() => loading = false);
  }

  // ================= GUEST =================
  Future<void> loginGuest() async {
    setState(() => loading = true);

    try {
      final user = await FirebaseAuth.instance.signInAnonymously();

      print("GUEST LOGIN: ${user.user?.uid}");

      if (!mounted) return;
      goNext("guest");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Guest login failed")),
      );
    }

    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const Icon(Icons.eco, size: 80),
                const Text(
                  "Cacao Pest Detector",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: 280,
                  child: TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: 280,
                  child: TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: loginEmail,
                  child: const Text("Login Email"),
                ),

                ElevatedButton(
                  onPressed: loginGoogle,
                  child: const Text("Login Google"),
                ),

                ElevatedButton(
                  onPressed: loginGuest,
                  child: const Text("Guest Login"),
                ),
              ],
            ),
          ),

          if (loading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}