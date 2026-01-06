import '../api/api_client.dart';
import '../models/profile_model.dart';

class ProfileService {
  static Future<ProfileModel> getProfile() async {
    final response = await ApiClient.dio.get('/profile');
    return ProfileModel.fromJson(response.data);
  }

  static Future<void> updateProfile(Map<String, dynamic> payload) async {
    await ApiClient.dio.put('/profile', data: payload);
  }
}
