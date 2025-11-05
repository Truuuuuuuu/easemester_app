import 'package:easemester_app/data/notifiers.dart';
import 'package:easemester_app/helpers/dialog_helpers.dart';
import 'package:easemester_app/models/profile_model.dart';
import 'package:easemester_app/services/firestore_service.dart';
import 'package:easemester_app/routes/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easemester_app/views/widgets/app_drawer.dart';
import 'package:easemester_app/data/constant.dart'; // ✅ For AppFonts

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirestoreService _firestoreService =
      FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? user;
  bool isLoading = true;

  String college = '';
  String course = '';
  String address = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final doc = await _firestoreService.getUser(
          currentUser.uid,
        );
        final data = doc.data() as Map<String, dynamic>?;

        if (data != null && mounted) {
          setState(() {
            user = UserModel.fromMap(currentUser.uid, data);
            college = data['college'] ?? '';
            course = data['course'] ?? '';
            address = data['address'] ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching user data: $e'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _signOut() async {
    final confirm = await confirmSignOut(context);
    if (confirm == true) {
      await _auth.signOut();
      currentUserNotifier.value = null;
      if (mounted) NavigationHelper.goToLogin(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const AppDrawer(),

      body: SafeArea(
        child: Container(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    24.0,
                    24.0,
                    24.0,
                    24.0,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.center,
                    children: [
                      // Profile header
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 32,
                        ),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  width: 4,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 70,
                                backgroundImage:
                                    user != null &&
                                        user!
                                            .profileImageUrl
                                            .isNotEmpty
                                    ? NetworkImage(
                                        user!
                                            .profileImageUrl,
                                      )
                                    : const AssetImage(
                                            'assets/images/default_profile.png',
                                          )
                                          as ImageProvider,
                                backgroundColor:
                                    Colors.grey[200],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              user?.name ?? 'No Name',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight:
                                        FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                            ),
                            //const SizedBox(height: 1),
                            Text(
                              user?.email ?? 'No Email',
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                // Smaller Edit Button
                                ElevatedButton.icon(
                                  icon: const Icon(
                                    Icons.edit,
                                  ),
                                  label: const Text('Edit'),
                                  onPressed: () async {
                                    final updated =
                                        await NavigationHelper.goToEditProfile(
                                          context,
                                          user!,
                                        );
                                    if (updated == true) {
                                      _fetchUserData();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context)
                                            .colorScheme
                                            .secondaryContainer,
                                    foregroundColor:
                                        Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer,
                                    padding:
                                        const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                            10,
                                          ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // Wider Photo Button
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(
                                      Icons.emoji_events,
                                    ),
                                    label: const Text(
                                      'Achievements',
                                    ),
                                    onPressed: () {
                                      // achievement page
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color.fromARGB(255, 9, 35, 64),  // fixed blue
                                      foregroundColor: Colors
                                          .white, // white text/icon
                                      padding:
                                          const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(
                                              10,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Additional Info Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: EdgeInsets.zero,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surface,
                          borderRadius:
                              BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).dividerColor.withOpacity(0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment:
                                  Alignment.centerLeft,
                              child: Text(
                                'Details',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight:
                                          FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            _buildInfoTile(
                              icon: Icons.school,
                              title: "College/University",
                              subtitle: college.isNotEmpty
                                  ? college
                                  : "Not set",
                            ),
                            const SizedBox(height: 24),

                            _buildInfoTile(
                              icon: Icons.menu_book,
                              title: "Course",
                              subtitle: course.isNotEmpty
                                  ? course
                                  : "Not set",
                            ),
                            const SizedBox(height: 24),

                            _buildInfoTile(
                              icon: Icons.location_on,
                              title: "Address",
                              subtitle: address.isNotEmpty
                                  ? address
                                  : "Not set",
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Sign Out Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.logout),
                          label: const Text('Sign Out'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.red[500],
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _signOut,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withOpacity(0.1),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
