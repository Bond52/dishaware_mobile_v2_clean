import 'dart:async';
import 'package:flutter/material.dart';
import '../../profile/models/share_target.dart';
import '../../../services/profile_share_service.dart';
import '../../../services/share_target_service.dart';
import '../../../theme/da_colors.dart';

class ShareProfileScreen extends StatefulWidget {
  const ShareProfileScreen({super.key});

  @override
  State<ShareProfileScreen> createState() => _ShareProfileScreenState();
}

class _ShareProfileScreenState extends State<ShareProfileScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  bool _isSearching = false;
  List<ShareTarget> _results = [];
  String _query = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partager mon profil'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileInfoCard(),
            const SizedBox(height: 16),
            _buildSearchField(),
            const SizedBox(height: 8),
            const Text(
              'Une personne ou un organisateur pourra comparer ses menus à votre profil.',
              style: TextStyle(
                fontSize: 12,
                color: DAColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Résultats (${_results.length})',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0B1B2B),
              ),
            ),
            const SizedBox(height: 8),
            if (_results.isEmpty && !_isSearching)
              _buildEmptyState()
            else
              ListView.builder(
                itemCount: _results.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final target = _results[index];
                  return _ShareTargetTile(
                    target: target,
                    isLoading: _isLoading,
                    onShare: () => _shareProfile(target),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _controller,
      onChanged: _onQueryChanged,
      decoration: InputDecoration(
        hintText: 'Rechercher une personne ou un événement',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: const Color(0xFFF4F5F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: _query.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _controller.clear();
                  _onQueryChanged('');
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E4E8)),
      ),
      child: Column(
        children: const [
          CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFFE8F9F2),
            child: Icon(Icons.people, color: Color(0xFF00A57A)),
          ),
          SizedBox(height: 12),
          Text(
            'Recherchez qui peut voir votre profil',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0B1B2B),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Entrez le nom d’une personne ou d’un événement pour partager votre profil gustatif de manière contrôlée.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: DAColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  void _onQueryChanged(String value) {
    _query = value.trim();
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (_query.length < 2) {
        setState(() {
          _results = [];
          _isSearching = false;
        });
        return;
      }
      _searchTargets(_query);
    });
  }

  Future<void> _searchTargets(String query) async {
    setState(() => _isSearching = true);
    try {
      final results = await ShareTargetService.searchShareTargets(query);
      if (!mounted) return;
      setState(() {
        _results = results;
      });
    } catch (e) {
      debugPrint('❌ Erreur recherche partage: $e');
      if (!mounted) return;
      setState(() => _results = []);
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _shareProfile(ShareTarget target) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      await ProfileShareService.createProfileShare(
        targetId: target.id,
        targetType: target.type,
      );
      if (!mounted) return;
      _showSnack(
        'Profil partagé avec succès (24h)',
        const Color(0xFF00A57A),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      final message = e.toString().toLowerCase();
      if (message.contains('déjà') || message.contains('already')) {
        _showSnack(
          'Accès déjà accordé pour cette personne',
          const Color(0xFF0EA5E9),
        );
      } else {
        _showSnack(
          'Impossible de partager le profil',
          const Color(0xFFEF4444),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F9F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBEEAD9)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFDFF7EE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person,
              color: Color(0xFF00A57A),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Votre profil gustatif DishAware',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B1B2B),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Préférences alimentaires, régimes, allergies et habitudes',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF5A6A78),
                  ),
                ),
                SizedBox(height: 6),
              ],
            ),
          ),
          Column(
            children: const [
              Icon(Icons.lock, size: 16, color: Color(0xFF00A57A)),
              SizedBox(height: 6),
              _ReadonlyBadge(),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReadonlyBadge extends StatelessWidget {
  const _ReadonlyBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBEEAD9)),
      ),
      child: Row(
        children: const [
          Icon(Icons.timer, size: 12, color: Color(0xFF00A57A)),
          SizedBox(width: 4),
          Text(
            'Lecture seule – accès contrôlé',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF00A57A),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareTargetTile extends StatelessWidget {
  final ShareTarget target;
  final bool isLoading;
  final VoidCallback onShare;

  const _ShareTargetTile({
    required this.target,
    required this.isLoading,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = target.type == ShareTargetType.user;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE1E4E8)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F9F2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isUser ? Icons.person : Icons.event,
              color: const Color(0xFF00A57A),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  target.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0B1B2B),
                  ),
                ),
                if (target.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    target.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: DAColors.mutedForeground,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F9F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isUser ? 'Personne' : 'Événement',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00A57A),
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: isLoading ? null : onShare,
            icon: Icon(
              Icons.share,
              color: isLoading ? DAColors.mutedForeground : DAColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
