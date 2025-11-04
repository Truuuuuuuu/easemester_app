// lib/ui/widgets/custom_app_bar.dart

import 'package:easemester_app/services/network_status_service.dart';
import 'package:flutter/material.dart';
import 'package:easemester_app/data/notifiers.dart';
import 'package:easemester_app/models/profile_model.dart';
import 'dart:async';

class CustomAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  final NetworkStatusService _networkService =
      NetworkStatusService();
  bool _isConnected = true;
  late StreamSubscription<bool> _connectionSubscription;

  @override
  void initState() {
    super.initState();
    _initConnectionStatus();
  }

  Future<void> _initConnectionStatus() async {
    final hasInternet = await _networkService
        .checkConnection();
    setState(() => _isConnected = hasInternet);

    _connectionSubscription = _networkService.onStatusChange
        .listen((status) {
          setState(() => _isConnected = status);
        });
  }

  @override
  void dispose() {
    _connectionSubscription.cancel();
    _networkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedPage, child) {
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
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu),
                      color: Theme.of(
                        context,
                      ).iconTheme.color,
                      iconSize: 40,
                      onPressed: () => Scaffold.of(
                        context,
                      ).openEndDrawer(),
                    ),
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
                // ✅ Reactive avatar and name
                ValueListenableBuilder<UserModel?>(
                  valueListenable: currentUserNotifier,
                  builder: (context, user, child) {
                    if (user == null) {
                      return Row(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const CircleAvatar(
                                radius: 35,
                                backgroundImage: AssetImage(
                                  'assets/images/default_profile.png',
                                ),
                              ),
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child:
                                    _buildConnectionIndicator(),
                              ),
                            ],
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

                    final image =
                        (user.profileImageUrl.isNotEmpty)
                        ? NetworkImage(user.profileImageUrl)
                        : const AssetImage(
                                'assets/images/default_profile.png',
                              )
                              as ImageProvider;

                    return Row(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundImage: image,
                            ),
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child:
                                  _buildConnectionIndicator(),
                            ),
                          ],
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
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu),
                    color: Theme.of(
                      context,
                    ).iconTheme.color,
                    iconSize: 40,
                    onPressed: () => Scaffold.of(
                      context,
                    ).openEndDrawer(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildConnectionIndicator() {
    return _isConnected
        ? Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
          )
        : Container(
            padding: const EdgeInsets.all(
              2,
            ), // optional inner padding
            decoration: BoxDecoration(
              color: Colors
                  .white, // background to make border visible
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2, // border thickness
              ),
            ),
            child: const Icon(
              Icons.wifi_off,
              color: Colors.red,
              size:
                  14, // slightly smaller to fit within border
            ),
          );
    ;
  }
}
