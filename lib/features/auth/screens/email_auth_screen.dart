import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../api/api_client.dart';
import '../../../api/auth_api.dart';
import '../../../main.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import '../../onboarding/providers/auth_provider.dart';
import '../../onboarding/providers/onboarding_provider.dart';

enum EmailAuthMode {
  signUp,
  signIn,
}

class EmailAuthScreen extends StatefulWidget {
  final EmailAuthMode mode;

  const EmailAuthScreen({super.key, required this.mode});

  @override
  State<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends State<EmailAuthScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _loading = false;
  /// Garde contre double soumission (tap rapide ou double fire).
  bool _isSubmitting = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    return _firstNameController.text.trim().isNotEmpty &&
        _lastNameController.text.trim().isNotEmpty;
  }

  Future<void> _submit() async {
    if (!_canSubmit || _loading || _isSubmitting) return;
    // Garde synchrone immédiate : évite deux appels en vol (double-tap ou double fire).
    _isSubmitting = true;
    _loading = true;
    setState(() {});
    if (mounted) ScaffoldMessenger.of(context).clearSnackBars();

    try {
      if (widget.mode == EmailAuthMode.signUp) {
        final result = await AuthApi.registerWithEmail(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
        );
        if (!mounted) return;
        if (result['success'] == true && result['token'] != null) {
          final hasCompletedOnboarding = _readHasCompletedOnboarding(result);
          await _persistAndGoHome(
            result['token'] as String,
            User.fromLoginResponse(Map<String, dynamic>.from(result)),
            hasCompletedOnboarding: hasCompletedOnboarding,
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
          );
          return;
        }
        _loading = false;
        _isSubmitting = false;
        if (mounted) setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message']?.toString() ?? 'Inscription impossible.',
            ),
          ),
        );
      } else {
        final result = await AuthApi.loginWithEmail(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
        );
        if (!mounted) return;
        if (result['success'] == true && result['token'] != null) {
          final hasCompletedOnboarding = _readHasCompletedOnboarding(result);
          await _persistAndGoHome(
            result['token'] as String,
            User.fromLoginResponse(Map<String, dynamic>.from(result)),
            hasCompletedOnboarding: hasCompletedOnboarding,
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
          );
          return;
        }
        _loading = false;
        _isSubmitting = false;
        if (mounted) setState(() {});
        if (result['notFound'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aucun compte trouvé avec ce nom.'),
            ),
          );
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message']?.toString() ?? 'Connexion impossible.',
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      _loading = false;
      _isSubmitting = false;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur réseau. Réessayez.'),
        ),
      );
    }
  }

  /// Lit hasCompletedOnboarding depuis la réponse register/login (backend Render).
  bool _readHasCompletedOnboarding(Map<String, dynamic> result) {
    final user = result['user'];
    if (user is Map<String, dynamic>) {
      final v = user['hasCompletedOnboarding'];
      if (v is bool) return v;
    }
    final v = result['hasCompletedOnboarding'];
    if (v is bool) return v;
    return true;
  }

  Future<void> _persistAndGoHome(
    String token,
    User? user, {
    bool hasCompletedOnboarding = true,
    String? firstName,
    String? lastName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    if (user != null) {
      await User.persist(user);
      if (mounted) context.read<UserProvider>().setUser(user);
    } else {
      await prefs.setString('currentUserId', token);
    }
    globalToken = token;
    ApiClient.setToken(token);
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();
    authProvider.setAuthMethod(AuthMethod.email);
    authProvider.authenticate(AuthMethod.email);
    if (hasCompletedOnboarding) {
      authProvider.completeOnboarding();
    } else {
      authProvider.setHasCompletedOnboarding(false);
      // Préremplir l'onboarding avec les noms saisis (évite double saisie)
      final first = (firstName?.trim().isNotEmpty == true)
          ? firstName!.trim()
          : (user?.firstName ?? '').trim();
      final last = (lastName?.trim().isNotEmpty == true)
          ? lastName!.trim()
          : (user?.lastName ?? '').trim();
      if (first.isNotEmpty || last.isNotEmpty) {
        final onboarding = context.read<OnboardingProvider>();
        onboarding.setNamesIfEmpty(first, last);
        onboarding.skipStep1IfNamesFilled();
      }
    }
    // Une seule navigation : le redirect du routeur envoie vers /onboarding/flow si besoin
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final isSignUp = widget.mode == EmailAuthMode.signUp;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF223041)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isSignUp) ...[
              Row(
                children: const [
                  Text(
                    'Étape 1 sur 16',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3B4A58),
                    ),
                  ),
                  Spacer(),
                  Text(
                    '6%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3B4A58),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3E6EA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: 0.1,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00A57A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Passer →',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5B6A78),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFDFF8EF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.person_outline,
                size: 32,
                color: Color(0xFF00A57A),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Faisons connaissance',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0B1B2B),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Comment souhaitez-vous qu\'on vous appelle ?',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF5A6A78),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Prénom',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2A37),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _firstNameController,
              keyboardType: TextInputType.name,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Marie',
                hintStyle: const TextStyle(color: Color(0xFF8B97A3)),
                filled: true,
                fillColor: const Color(0xFFF4F5F7),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nom',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2A37),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _lastNameController,
              keyboardType: TextInputType.name,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Dupont',
                hintStyle: const TextStyle(color: Color(0xFF8B97A3)),
                filled: true,
                fillColor: const Color(0xFFF4F5F7),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: (_canSubmit && !_loading && !_isSubmitting) ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A57A),
                  disabledBackgroundColor: const Color(0xFFB0BEC5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        isSignUp ? 'Continuer' : 'Se connecter',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Barre de progression à largeur fractionnaire (style onboarding).
class FractionallySizedBox extends StatelessWidget {
  final double widthFactor;
  final Widget child;

  const FractionallySizedBox({
    super.key,
    required this.widthFactor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth * widthFactor,
          child: child,
        );
      },
    );
  }
}
