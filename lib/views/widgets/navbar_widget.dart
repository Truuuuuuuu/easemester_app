import 'package:easemester_app/data/notifiers.dart';
import 'package:flutter/material.dart';

class NavbarWidget extends StatelessWidget {
  const NavbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedPage, child) {
        final bool showFab = selectedPage != 3;

        // Map for icon paths (normal and selected)
        final icons = [
          {
            'default': 'assets/images/icons/home_icon.png',
            'selected': 'assets/images/icons/home_icon.png',
          },
          {
            'default': 'assets/images/icons/notes_icon.png',
            'selected': 'assets/images/icons/notes_icon.png',
          },
          {
            'default': 'assets/images/icons/checklist_icon.png',
            'selected': 'assets/images/icons/checklist_icon.png',
          },
          {
            'default': 'assets/images/icons/profile_icon.png',
            'selected': 'assets/images/icons/profile_icon.png',
          },
        ];

        Widget navItem(int index) {
          final isSelected = selectedPage == index;
          return GestureDetector(
            onTap: () => selectedPageNotifier.value = index,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                    : Colors.transparent,
              ),
              child: Center(
                child: Image.asset(
                  isSelected
                      ? icons[index]['selected']!
                      : icons[index]['default']!,
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        }

        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                bottom: 20.0,
                left: 16,
                right: 16,
              ),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(30),
                color: Theme.of(context).cardColor,
                child: SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      navItem(0),
                      navItem(1),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        width: showFab ? 60 : 0,
                      ),
                      navItem(2),
                      navItem(3),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
