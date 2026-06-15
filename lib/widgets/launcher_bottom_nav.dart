import 'package:flutter/material.dart';
import '../app_theme.dart';

/// Bottom navigation dock for the Zen Launcher.
///
/// Matches the Stitch design: 4 tabs (Tasks, Journal, Timeline, Chat)
/// with Material Symbols icons and secondary-container chip for the
/// currently active tab.
class LauncherBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const LauncherBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      decoration: const BoxDecoration(
        color: ZenColors.paperSheet,
        border: Border(
          top: BorderSide(
            color: ZenColors.surfaceContainerHighest,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavTab(
              icon: Icons.check_box_outlined,
              activeIcon: Icons.check_box,
              label: 'Tasks',
              index: 0,
              isSelected: currentIndex == 0,
              onTap: () => onTabSelected(0),
            ),
            _NavTab(
              icon: Icons.edit_note_outlined,
              activeIcon: Icons.edit_note,
              label: 'Journal',
              index: 1,
              isSelected: currentIndex == 1,
              onTap: () => onTabSelected(1),
            ),
            _NavTab(
              icon: Icons.auto_stories_outlined,
              activeIcon: Icons.auto_stories,
              label: 'Timeline',
              index: 2,
              isSelected: currentIndex == 2,
              onTap: () => onTabSelected(2),
            ),
            _NavTab(
              icon: Icons.chat_bubble_outline,
              activeIcon: Icons.chat_bubble,
              label: 'Chat',
              index: 3,
              isSelected: currentIndex == 3,
              onTap: () => onTabSelected(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 64,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 32,
              width: 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? ZenColors.secondaryContainer
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                size: 22,
                color: isSelected
                    ? ZenColors.onSecondaryContainer
                    : ZenColors.outline,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 14 / 11,
                letterSpacing: 0.02,
                color: isSelected
                    ? ZenColors.onSecondaryContainer
                    : ZenColors.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}