import '../../api/api_client.dart';

/// Appels API pour les notifications géolocalisées (opt-in).
class NotificationsApi {
  /// POST /api/notifications/opt-in
  /// Body: { enabled: bool, fcmToken?: string }
  static Future<void> optIn({
    required bool enabled,
    String? fcmToken,
  }) async {
    final body = <String, dynamic>{'enabled': enabled};
    if (enabled && fcmToken != null && fcmToken.isNotEmpty) {
      body['fcmToken'] = fcmToken;
    }
    await ApiClient.dio.post(
      '/notifications/opt-in',
      data: body,
      options: await ApiClient.optionsWithUserId(),
    );
  }
}
