import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/feedback_model.dart';

class FeedbackService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  Future<void> sendFeedback(DishFeedback feedback) async {
    await _dio.post(
      '/feedback',
      data: feedback.toJson(),
    );
  }
}
