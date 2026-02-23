import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../api/api_client.dart';
import '../../../features/auth/google_auth_service.dart';
import '../../../main.dart';
import '../providers/auth_provider.dart';

/// Persiste un userId mock (auth_token + currentUserId) pour que les appels API
/// (ex. createProfile) fonctionnent après l'onboarding, puis navigue.
Future<void> _persistMockUserIdAndGo(BuildContext context, String route) async {
  final mockId = 'mock_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(0x7FFFFFFF)}';
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('auth_token', mockId);
  await prefs.setString('currentUserId', mockId);
  globalToken = mockId;
  ApiClient.setToken(mockId);
  if (context.mounted) context.go(route);
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _googleLoading = false;

  Future<void> _handleGoogleSignIn() async {
    if (_googleLoading) return;
    setState(() => _googleLoading = true);
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connexion en cours…')),
      );
    }

    final status = await GoogleAuthService.signInWithGoogle();

    if (!mounted) return;
    setState(() => _googleLoading = false);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    switch (status) {
      case GoogleAuthStatus.success:
        context.read<AuthProvider>().authenticate(AuthMethod.google);
        context.go('/home');
        break;
      case GoogleAuthStatus.cancelled:
        break;
      case GoogleAuthStatus.networkError:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur réseau. Vérifiez votre connexion et réessayez.'),
          ),
        );
        break;
      case GoogleAuthStatus.invalidToken:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connexion refusée. Veuillez réessayer.'),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.arrow_back, size: 18, color: Color(0xFF223041)),
                    SizedBox(width: 6),
                    Text(
                      'Retour',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF223041),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Commençons !',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0B1B2B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choisissez votre méthode de connexion',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF5A6A78),
                ),
              ),
              const SizedBox(height: 28),
              _AuthOptionCard(
                onTap: _googleLoading ? null : _handleGoogleSignIn,
                loading: _googleLoading,
                leading: _IconTile(
                  background: Colors.white,
                  borderColor: const Color(0xFFE5E7EB),
                  child: const Text(
                    'G',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4285F4),
                    ),
                  ),
                ),
                title: 'Continuer avec Google',
                subtitle: 'Connexion rapide et sécurisée',
              ),
              const SizedBox(height: 16),
              _AuthOptionCard(
                onTap: () async {
                  authProvider.authenticate(AuthMethod.apple);
                  await _persistMockUserIdAndGo(context, '/onboarding/flow');
                },
                leading: _IconTile(
                  background: Colors.black,
                  borderColor: Colors.black,
                  child: const Icon(Icons.apple, color: Colors.white),
                ),
                title: 'Continuer avec Apple',
                subtitle: 'Confidentialité renforcée',
              ),
              const SizedBox(height: 16),
              _AuthOptionCard(
                onTap: () {
                  authProvider.setAuthMethod(AuthMethod.email);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bientôt disponible')),
                  );
                },
                leading: _IconTile(
                  background: const Color(0xFF00A57A),
                  borderColor: const Color(0xFF00A57A),
                  child: const Icon(Icons.email, color: Colors.white),
                ),
                title: 'Continuer avec Email',
                subtitle: 'Inscription classique par email',
              ),
              const Spacer(),
              const Text(
                'En continuant, vous acceptez nos Conditions d’utilisation et notre Politique de confidentialité',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: Color(0xFF6B7A88),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthOptionCard extends StatelessWidget {
  final VoidCallback? onTap;
  final bool loading;
  final Widget leading;
  final String title;
  final String subtitle;

  const _AuthOptionCard({
    required this.onTap,
    this.loading = false,
    required this.leading,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Opacity(
        opacity: (onTap == null || loading) ? 0.7 : 1,
        child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE1E4E8)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0B1B2B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7A88),
                    ),
                  ),
                ],
              ),
            ),
            if (loading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
      ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  final Color background;
  final Color borderColor;
  final Widget child;

  const _IconTile({
    required this.background,
    required this.borderColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
