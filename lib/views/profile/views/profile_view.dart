import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taskora/core/theme/app_colors.dart';
import '../view_models/profile_view_model.dart';

class ProfileView extends StatefulWidget {
  final Future<void> Function() onLogout;

  const ProfileView({super.key, required this.onLogout});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final ProfileViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;

    _viewModel = ProfileViewModel(userId: user?.uid ?? '');
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _editName() async {
    final controller = TextEditingController(
      text: _viewModel.profile?.name ?? '',
    );

    final formKey = GlobalKey<FormState>();

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Name'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().length < 2) {
                  return 'Please enter a valid name.';
                }

                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext, controller.text.trim());
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (newName == null || !mounted) return;

    await _viewModel.updateName(newName);

    if (!mounted) return;

    _showMessage();
  }

  Future<void> _changePhoto() async {
    await _viewModel.pickProfilePhoto();

    if (!mounted) return;

    _showMessage();
  }

  void _showMessage() {
    final message = _viewModel.successMessage ?? _viewModel.errorMessage;

    if (message == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _viewModel.errorMessage != null
            ? AppColors.danger
            : AppColors.success,
      ),
    );
  }

  Widget _buildAvatar() {
    final photo = _viewModel.profile?.photoBase64;

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 55,
          backgroundColor: AppColors.primary.withValues(alpha: 0.10),
          backgroundImage: photo != null && photo.isNotEmpty
              ? MemoryImage(base64Decode(photo))
              : null,
          child: photo == null || photo.isEmpty
              ? Text(
                  (_viewModel.profile?.name.isNotEmpty ?? false)
                      ? _viewModel.profile!.name[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                )
              : null,
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white, width: 3),
          ),
          child: IconButton(
            onPressed: _viewModel.isSaving ? null : _changePhoto,
            icon: const Icon(
              Icons.camera_alt_outlined,
              color: AppColors.white,
              size: 19,
            ),
            constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
            padding: EdgeInsets.zero,
            tooltip: 'Change profile photo',
          ),
        ),
      ],
    );
  }

  Widget _buildInformationTile({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      subtitle: Text(
        value.isEmpty ? 'Not provided' : value,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: onTap != null
          ? const Icon(
              Icons.edit_outlined,
              color: AppColors.mutedText,
              size: 19,
            )
          : null,
    );
  }

  Widget _buildProfileContent() {
    final profile = _viewModel.profile;

    if (profile == null) {
      return const Center(
        child: Text(
          'Profile information not found.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 30),
      child: Column(
        children: [
          _buildAvatar(),

          const SizedBox(height: 16),

          Text(
            profile.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            profile.email,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 30),

          _buildSectionTitle('Account Information'),

          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _buildInformationTile(
                  icon: Icons.person_outline,
                  title: 'Full Name',
                  value: profile.name,
                  onTap: _editName,
                ),
                const Divider(
                  height: 1,
                  indent: 70,
                  endIndent: 16,
                  color: AppColors.border,
                ),
                _buildInformationTile(
                  icon: Icons.email_outlined,
                  title: 'Email Address',
                  value: profile.email,
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          _buildSectionTitle('Settings'),

          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text('Edit Profile'),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.mutedText,
                  ),
                  onTap: _editName,
                ),
                const Divider(height: 1, color: AppColors.border),
                ListTile(
                  leading: const Icon(
                    Icons.photo_camera_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text('Change Profile Photo'),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.mutedText,
                  ),
                  onTap: _viewModel.isSaving ? null : _changePhoto,
                ),
                const Divider(height: 1, color: AppColors.border),
                ListTile(
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.danger,
                  ),
                  title: const Text(
                    'Log Out',
                    style: TextStyle(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.danger,
                  ),
                  onTap: () async {
                    await widget.onLogout();
                  },
                ),
              ],
            ),
          ),

          if (_viewModel.isSaving) ...[
            const SizedBox(height: 20),
            const LinearProgressIndicator(color: AppColors.primary),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            if (_viewModel.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (_viewModel.errorMessage != null && _viewModel.profile == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    _viewModel.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ),
              );
            }

            return _buildProfileContent();
          },
        ),
      ),
    );
  }
}
