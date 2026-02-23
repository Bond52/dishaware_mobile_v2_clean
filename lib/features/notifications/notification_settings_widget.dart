import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'location_service.dart';
import 'notification_initializer.dart';
import 'notification_service.dart';
import 'notifications_api.dart';

const String _keyFirstTimeSheetShown = 'notifications_geoloc_first_time_sheet';

/// Toggle "Recevoir des suggestions personnalisées près de moi" + première activation (bottom sheet).
class NotificationSettingsWidget extends StatefulWidget {
  const NotificationSettingsWidget({super.key});

  @override
  State<NotificationSettingsWidget> createState() =>
      _NotificationSettingsWidgetState();
}

class _NotificationSettingsWidgetState extends State<NotificationSettingsWidget> {
  bool _enabled = false;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final enabled = await NotificationInitializer.isOptInActive();
    if (mounted) {
      setState(() {
        _enabled = enabled;
        _loading = false;
      });
    }
  }

  Future<bool> _requestLocationPermission() async {
    var status = await Permission.locationWhenInUse.status;
    if (status.isGranted) return true;
    if (status.isDenied) {
      status = await Permission.locationWhenInUse.request();
      return status.isGranted;
    }
    return false;
  }

  Future<void> _enableOptIn() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final notifOk = await NotificationService.requestNotificationPermission();
      if (!notifOk) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Autorisez les notifications pour activer.')),
          );
        }
        setState(() => _saving = false);
        return;
      }
      final locationOk = await _requestLocationPermission();
      if (!locationOk) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Autorisez la localisation pour activer.')),
          );
        }
        setState(() => _saving = false);
        return;
      }
      await NotificationService.initialize();
      final token = await NotificationService.getToken();
      await NotificationsApi.optIn(enabled: true, fcmToken: token);
      await NotificationInitializer.setOptIn(true);
      LocationService.startPolling();
      if (mounted) {
        setState(() {
          _enabled = true;
          _saving = false;
        });
        debugPrint('[flutterNotification] opt-in enabled');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _disableOptIn() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await NotificationsApi.optIn(enabled: false);
      await NotificationInitializer.setOptIn(false);
      LocationService.stopPolling();
      if (mounted) {
        setState(() {
          _enabled = false;
          _saving = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _onToggleChanged(bool value) async {
    if (value) {
      final prefs = await SharedPreferences.getInstance();
      final firstTime = !(prefs.getBool(_keyFirstTimeSheetShown) ?? false);
      if (firstTime) {
        final confirmed = await _showFirstTimeSheet();
        if (!confirmed || !mounted) return;
        await prefs.setBool(_keyFirstTimeSheetShown, true);
      }
      await _enableOptIn();
    } else {
      await _disableOptIn();
    }
  }

  Future<bool> _showFirstTimeSheet() async {
    return await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Suggestions près de vous',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B1B2B),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'DishAware peut vous prévenir lorsque vous restez quelques minutes dans un endroit où un restaurant correspond à votre profil alimentaire.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF5A6A78)),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Pas maintenant'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00A57A),
                        ),
                        child: const Text('Activer'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const ListTile(
        title: Text('Suggestions près de moi'),
        trailing: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    return SwitchListTile(
      value: _enabled,
      onChanged: _saving
          ? null
          : (value) => _onToggleChanged(value),
      title: const Text(
        'Recevoir des suggestions personnalisées près de moi',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF0B1B2B),
        ),
      ),
      subtitle: _saving
          ? const Text('Enregistrement...', style: TextStyle(fontSize: 12))
          : null,
      activeColor: const Color(0xFF00A57A),
    );
  }
}
