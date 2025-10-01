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

    final uploadedUrl = await CloudinaryService()
        .uploadFile(file);

    setState(() {
      isUploadingPhoto = false;
      if (uploadedUrl != null) {
        newProfileImageUrl = uploadedUrl;
      }
    });

    if (uploadedUrl == null) {
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        style: TextStyle(color: colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
          filled: true,
          fillColor: colorScheme.surface,
          prefixIcon: hint == "Name"
              ? Icon(
                  Icons.person,
                  color: colorScheme.onSurface,
                )
              : hint == "College"
              ? Icon(
                  Icons.school,
                  color: colorScheme.onSurface,
                )
              : hint == "Course"
              ? Icon(
                  Icons.menu_book,
                  color: colorScheme.onSurface,
                )
              : Icon(
                  Icons.location_on,
                  color: colorScheme.onSurface,
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
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
              _buildTextField(
                controller: nameController,
                hint: "Name",
              ),
              _buildTextField(
                controller: collegeController,
                hint: "College",
              ),
              _buildTextField(
                controller: courseController,
                hint: "Course",
              ),
              _buildTextField(
                controller: addressController,
                hint: "Address",
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
