import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/auth_api.dart';
import '../api/api_client.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  String errorMessage = "";

  Future<void> handleLogin() async {
    // 🔒 Empêche double clic / état incohérent en release
    if (loading) return;

    // ✅ Feedback visuel (fonctionne en release)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Tentative de connexion…")),
    );

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() {
        errorMessage = "Veuillez remplir tous les champs.";
      });
      return;
    }

    setState(() {
      loading = true;
      errorMessage = "";
    });

    try {
      final result = await AuthApi.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (result["success"] == true && result["token"] != null) {
        final token = result["token"];

        // 💾 Sauvegarde locale
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("auth_token", token);
        await prefs.setString('currentUserId', token);

        // 🔥 variable globale (router)
        globalToken = token;

        // 🔥 injection Dio
        ApiClient.setToken(token);

        // ➜ Home
        if (mounted) {
          context.go('/home');
        }
      } else {
        setState(() {
          errorMessage =
              result["message"] ?? "Email ou mot de passe incorrect";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Erreur réseau, veuillez réessayer.";
      });
    } finally {
      // ✅ Toujours réactiver le bouton (release-safe)
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Connexion")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Mot de passe",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
              ),

            const SizedBox(height: 20),

            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: handleLogin,
                    child: const Text("Se connecter"),
                  ),
          ],
        ),
      ),
    );
  }
}
