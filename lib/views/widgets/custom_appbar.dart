import 'package:flutter/material.dart';
import 'package:easemester_app/data/notifiers.dart';
import 'package:easemester_app/models/profile_model.dart';

class CustomAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedPage, child) {
        // if (selectedPage == 3)
        //   return const SizedBox.shrink();
        if (selectedPage == 3) {
          return SafeArea(
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(
                horizontal: 18.0,
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  Builder(
                    builder: (context) {
                      return IconButton(
                        icon: const Icon(Icons.menu),
                        color: Theme.of(
                          context,
                        ).iconTheme.color,
                        iconSize: 40,
                        onPressed: () {
                          Scaffold.of(
                            context,
                          ).openEndDrawer();
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 18.0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Reactive avatar and name
                ValueListenableBuilder<UserModel?>(
                  valueListenable: currentUserNotifier,
                  builder: (context, user, child) {
                    if (user == null) {
                      // Show default avatar & "Guest" while loading
                      return Row(
                        children: [
                          const CircleAvatar(
                            radius: 35,
                            backgroundImage: AssetImage(
                              'assets/images/default_profile.png',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Guest',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Let’s make today productive',
                                style: TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }

                    // Display actual user info
                    final image =
                        (user.profileImageUrl.isNotEmpty)
                        ? NetworkImage(user.profileImageUrl)
                        : const AssetImage(
                                'assets/images/default_profile.png',
                              )
                              as ImageProvider;

                    return Row(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundImage: image,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Text(
                              'Hello, ${user.name.split(' ').first}!',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Let’s make today productive',
                              style: TextStyle(
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),

                const Spacer(),
                Builder(
                  builder: (context) {
                    return IconButton(
                      icon: const Icon(Icons.menu),
                      color: Theme.of(
                        context,
                      ).iconTheme.color,
                      iconSize: 40,
                      onPressed: () {
                        Scaffold.of(
                          context,
                        ).openEndDrawer();
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
