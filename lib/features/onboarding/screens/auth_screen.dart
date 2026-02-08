import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

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
                onTap: () {
                  authProvider.authenticate(AuthMethod.google);
                  context.go('/onboarding/flow');
                },
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
                onTap: () {
                  authProvider.authenticate(AuthMethod.apple);
                  context.go('/onboarding/flow');
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
  final VoidCallback onTap;
  final Widget leading;
  final String title;
  final String subtitle;

  const _AuthOptionCard({
    required this.onTap,
    required this.leading,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
          ],
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
