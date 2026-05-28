import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/app_user.dart';
import '../services/user_service.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider({required UserService userService, ImagePicker? imagePicker})
    : _userService = userService,
      _imagePicker = imagePicker ?? ImagePicker();

  final UserService _userService;
  final ImagePicker _imagePicker;

  AppUser? _user;
  bool _isLoading = false;
  String? _error;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProfile() async {
    _setLoading(true);
    _error = null;

    try {
      _user = await _userService.getProfile();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load profile';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfile({
    required String username,
    required String? gender,
    required String? dateOfBirth,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      _user = await _userService.updateProfile(
        username: username,
        gender: gender,
        dateOfBirth: dateOfBirth,
      );
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update profile';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> takeProfilePhoto() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 900,
      imageQuality: 82,
    );

    if (image == null) return;

    _setLoading(true);
    _error = null;

    try {
      _user = await _userService.uploadProfilePhoto(image);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to upload profile photo';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void clearSessionData() {
    _user = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
