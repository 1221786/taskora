import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/profile_model.dart';

class ProfileService {
  final FirebaseFirestore _firestore;

  ProfileService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDocument(String userId) {
    return _firestore.collection('users').doc(userId);
  }

  Stream<ProfileModel?> watchProfile(String userId) {
    return _userDocument(userId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;

      final data = snapshot.data();

      if (data == null) return null;

      return ProfileModel.fromMap(data);
    });
  }

  Future<void> updateName({
    required String userId,
    required String name,
  }) async {
    await _userDocument(
      userId,
    ).set({'name': name.trim()}, SetOptions(merge: true));
  }

  Future<void> updateProfilePhoto({
    required String userId,
    required String photoBase64,
  }) async {
    await _userDocument(
      userId,
    ).set({'photoBase64': photoBase64}, SetOptions(merge: true));
  }
}
