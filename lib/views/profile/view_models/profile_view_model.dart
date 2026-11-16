import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/profile_model.dart';
import '../services/profile_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final String userId;
  final ProfileService _profileService;
  final ImagePicker _imagePicker = ImagePicker();

  StreamSubscription<ProfileModel?>? _profileSubscription;

  ProfileModel? profile;

  bool isLoading = true;
  bool isSaving = false;

  String? errorMessage;
  String? successMessage;

  ProfileViewModel({required this.userId, ProfileService? profileService})
    : _profileService = profileService ?? ProfileService() {
    _listenToProfile();
  }

  void _listenToProfile() {
    _profileSubscription = _profileService
        .watchProfile(userId)
        .listen(
          (userProfile) {
            profile = userProfile;
            isLoading = false;
            errorMessage = null;
            notifyListeners();
          },
          onError: (error) {
            isLoading = false;
            errorMessage = 'Could not load profile information.';
            notifyListeners();

            debugPrint('PROFILE LOAD ERROR: $error');
          },
        );
  }

  Future<bool> updateName(String name) async {
    final trimmedName = name.trim();

    if (trimmedName.length < 2) {
      errorMessage = 'Name must contain at least 2 characters.';
      successMessage = null;
      notifyListeners();
      return false;
    }

    try {
      isSaving = true;
      errorMessage = null;
      successMessage = null;
      notifyListeners();

      await _profileService.updateName(userId: userId, name: trimmedName);

      successMessage = 'Name updated successfully.';
      return true;
    } catch (error) {
      errorMessage = 'Could not update name. Please try again.';
      debugPrint('PROFILE NAME ERROR: $error');
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> pickProfilePhoto() async {
    try {
      errorMessage = null;
      successMessage = null;

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 35,
        maxWidth: 320,
        maxHeight: 320,
      );

      if (pickedFile == null) return false;

      final bytes = await pickedFile.readAsBytes();

      final encodedImage = base64Encode(bytes);

      // Keep the encoded image safely below Firestore's
      // maximum document size.
      if (encodedImage.length > 700000) {
        errorMessage = 'Image is too large. Please choose a smaller image.';
        notifyListeners();
        return false;
      }

      isSaving = true;
      notifyListeners();

      await _profileService.updateProfilePhoto(
        userId: userId,
        photoBase64: encodedImage,
      );

      successMessage = 'Profile photo updated successfully.';
      return true;
    } catch (error) {
      errorMessage = 'Could not update profile photo.';
      debugPrint('PROFILE PHOTO ERROR: $error');
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }
}
