import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' hide Config;
import '../app_theme.dart';
import '../config.dart';
import '../models/launcher_app.dart';
import '../services/app_list_service.dart';
import '../widgets/launcher_bottom_nav.dart';
import 'all_apps_screen.dart';
import 'chat_screen.dart';

/// The Zen Launcher Home screen — a minimal, text-based Android launcher.
///
/// Features:
/// - Paper-textured background with warm Zen palette
/// - Greeting + clock
/// - Favorite apps list (text-only, reorderable)
/// - "More" button to open the full app list
/// - Bottom navigation dock (Tasks, Journal, Timeline, Chat)
class ZenLauncherScreen extends StatefulWidget {
  const ZenLauncherScreen({super.key});

  @override
  State<ZenLauncherScreen> createState() => _ZenLauncherScreenState();
}

class _ZenLauncherScreenState extends State<ZenLauncherScreen> {
  List<LauncherApp> _favoriteApps = [];
  bool _isLoading = true;
  int _bottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final apps = await AppListService.fetchInstalledApps();
    setState(() {
      // Use default favorites, or try to match from installed apps
      final defaults = AppListService.defaultFavorites;
      _favoriteApps = defaults.map((fav) {
        final match = apps.cast<LauncherApp?>().firstWhere(
              (a) => a!.packageName == fav.packageName,
              orElse: () => null,
            );
        return match ?? fav;
      }).toList();
      _isLoading = false;
    });
  }

  void _onFavoritesChanged(List<LauncherApp> newFavorites) {
    setState(() {
      _favoriteApps = List.from(newFavorites);
    });
  }

  void _openAllApps() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AllAppsScreen(
          currentFavorites: _favoriteApps,
          onFavoritesChanged: _onFavoritesChanged,
        ),
      ),
    );
  }

  void _onBottomNavTabSelected(int index) {
    setState(() => _bottomNavIndex = index);

    switch (index) {
      case 0: // Tasks — placeholder
        _showPlaceholderSheet('Tasks');
        break;
      case 1: // Journal — placeholder
        _showPlaceholderSheet('Journal');
        break;
      case 2: // Timeline — placeholder
        _showPlaceholderSheet('Timeline');
        break;
      case 3: // Chat — navigate to chat screen
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ChatScreen()),
        );
        break;
    }
  }

  void _showPlaceholderSheet(String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ZenColors.paperSheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: GoogleFonts.sourceSerif4(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                height: 28 / 20,
                color: ZenColors.ink,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Coming soon…',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 20 / 14,
                color: ZenColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZenColors.paperBg,
      body: Column(
        children: [
          // Main content area
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(flex: 2),

                          // Greeting
                          Text(
                            _greeting(),
                            style: GoogleFonts.sourceSerif4(
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                              height: 38 / 30,
                              letterSpacing: -0.01,
                              color: ZenColors.ink,
                            ),
                          ),

                          const SizedBox(height: 48),

                          // Favorites list
                          ..._favoriteApps.take(Config.maxFavoriteApps).map(
                                (app) => _AppTextButton(
                                  label: app.name,
                                  onTap: () {
                                    AppListService.launchApp(app.packageName);
                                  },
                                ),
                              ),

                          const SizedBox(height: 16),

                          // More button
                          GestureDetector(
                            onTap: _openAllApps,
                            child: Text(
                              'More',
                              style: GoogleFonts.sourceSerif4(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                height: 28 / 20,
                                color: ZenColors.outline,
                              ),
                            ),
                          ),

                          const Spacer(flex: 3),
                        ],
                      ),
              ),
            ),
          ),

          // Bottom navigation dock
          LauncherBottomNav(
            currentIndex: _bottomNavIndex,
            onTabSelected: _onBottomNavTabSelected,
          ),
        ],
      ),
    );
  }
}

/// A text-button for an app entry matching the "Text Only Edition" design.
class _AppTextButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AppTextButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          label,
          style: GoogleFonts.sourceSerif4(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            height: 28 / 20,
            color: ZenColors.ink,
          ),
        ),
      ),
    );
  }
}