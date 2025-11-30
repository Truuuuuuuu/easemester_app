import 'package:easemester_app/data/notifiers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // exit

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Top header
          DrawerHeader(
            child: Image.asset(
              'assets/images/easemester_logo.png',
              fit: BoxFit.contain,
            ),
          ),

          // Menu items
          ValueListenableBuilder(
            valueListenable: isDarkModeNotifier,
            builder: (context, isDarkMode, child) {
              return SwitchListTile(
                secondary: Icon(Icons.dark_mode),
                title: const Text("Dark Mode"),
                value: isDarkMode,
                onChanged: (value) => toggleTheme(),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.headset_mic_rounded),
            title: const Text('Support'),
            onTap: () {
              Navigator.pushNamed(context, '/support');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About us'),
            onTap: () {
              Navigator.pushNamed(context, '/about_us');
            },
          ),
        ],
      ),
    );
  }
}
