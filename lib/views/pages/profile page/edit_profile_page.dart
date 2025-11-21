import 'dart:io' show File;

import 'package:easemester_app/data/notifiers.dart';
import 'package:easemester_app/helpers/dialog_helpers.dart';
import 'package:easemester_app/services/cloudinary_service.dart';
import 'package:flutter/material.dart';
import 'package:easemester_app/models/profile_model.dart';
import 'package:easemester_app/services/firestore_service.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  final UserModel user;
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() =>
      _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  late TextEditingController collegeController;
  late TextEditingController courseController;
  late TextEditingController addressController;

  String? newProfileImageUrl;
  bool isUploadingPhoto = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
      text: widget.user.name,
    );
    collegeController = TextEditingController(
      text: widget.user.college ?? '',
    );
    courseController = TextEditingController(
      text: widget.user.course ?? '',
    );
    addressController = TextEditingController(
      text: widget.user.address ?? '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    collegeController.dispose();
    courseController.dispose();
    addressController.dispose();
    super.dispose();
  }

  /// Picks an image and uploads it to Cloudinary
  Future<void> pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (pickedFile == null) return;

    final file = File(pickedFile.path);

    setState(() => isUploadingPhoto = true);

    final uploadResult = await CloudinaryService()
        .uploadFile(file);

    setState(() => isUploadingPhoto = false);

    if (uploadResult != null) {
      final fileUrl = uploadResult['url'];
      final publicId = uploadResult['public_id'];

      // Save URL for preview or Firestore update
      setState(() {
        newProfileImageUrl = fileUrl;
      });

      print('✅ Uploaded successfully: $fileUrl');
      print('📦 Cloudinary public_id: $publicId');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to upload image'),
        ),
      );
    }
  }

  /// Saves the profile to Firestore
  Future<void> saveProfile() async {
    final confirmed = await confirmChanges(context);
    if (confirmed != true) return;

    setState(() => isSaving = true);

    Map<String, dynamic> updatedData = {
      'name': nameController.text.trim(),
      'college': collegeController.text.trim(),
      'course': courseController.text.trim(),
      'address': addressController.text.trim(),
    };

    if (newProfileImageUrl != null) {
      updatedData['profileImageUrl'] = newProfileImageUrl;
    }

    await FirestoreService().updateUser(
      widget.user.uid,
      updatedData,
    );
    // After Firestore update
    final updatedUser = widget.user.copyWith(
      name: nameController.text.trim(),
      college: collegeController.text.trim(),
      course: courseController.text.trim(),
      address: addressController.text.trim(),
      profileImageUrl:
          newProfileImageUrl ?? widget.user.profileImageUrl,
    );

    // Update the global notifier so app bar and other listeners refresh
    currentUserNotifier.value = updatedUser;

    if (mounted) Navigator.pop(context, true);
  }

  Widget _buildLabeledField({
    required String label,
    required TextEditingController controller,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: "Enter $label",
              hintStyle: TextStyle(
                color: colorScheme.onSurface.withOpacity(
                  0.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.grey,
                  width: 1.2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.grey,
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: colorScheme.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Edit Profile"),
        centerTitle: true,
        foregroundColor: colorScheme.onSurface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        newProfileImageUrl != null
                        ? NetworkImage(newProfileImageUrl!)
                        : widget
                              .user
                              .profileImageUrl
                              .isNotEmpty
                        ? NetworkImage(
                            widget.user.profileImageUrl,
                          )
                        : const AssetImage(
                                'assets/images/default_profile.png',
                              )
                              as ImageProvider,
                    backgroundColor: colorScheme.surface,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: isUploadingPhoto
                          ? null
                          : pickAndUploadPhoto,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor:
                            colorScheme.primary,
                        child: isUploadingPhoto
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                              )
                            : Icon(
                                Icons.camera_alt,
                                size: 20,
                                color:
                                    colorScheme.onPrimary,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildLabeledField(
                label: "Name",
                controller: nameController,
              ),
              _buildLabeledField(
                label: "College",
                controller: collegeController,
              ),
              _buildLabeledField(
                label: "Course",
                controller: courseController,
              ),
              _buildLabeledField(
                label: "Address",
                controller: addressController,
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: width,
                height: 50,
                child: ElevatedButton(
                  onPressed: isSaving || isUploadingPhoto
                      ? null
                      : saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                  child: isSaving
                      ? CircularProgressIndicator(
                          color: colorScheme.onPrimary,
                        )
                      : const Text(
                          "Save",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
