import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../config.dart';
import '../models/launcher_app.dart';
import '../services/app_list_service.dart';
import '../services/favorites_service.dart';
import '../services/lock_service.dart';
import '../widgets/launcher_bottom_nav.dart';
import 'all_apps_screen.dart';
import 'chat_screen.dart';

/// The Zen Launcher Home screen — a minimal, text-based Android launcher.
///
/// Features:
/// - Paper-textured background with warm Zen palette
/// - Favorite apps list (text-only, reorderable)
/// - Apps icon to open the full app list
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
    try {
      final installedApps = await AppListService.fetchInstalledApps();
      final saved = await FavoritesService.loadWithDefaults(
        defaults: AppListService.defaultFavorites,
      );
      setState(() {
        // Match persisted favorites to installed apps (preserving order/stars)
        // and filter out any that are no longer installed.
        _favoriteApps = saved.map((savedFavorite) {
          final matchedApp = installedApps.cast<LauncherApp?>().firstWhere(
            (installedApp) =>
                installedApp!.packageName == savedFavorite.packageName,
            orElse: () => null,
          );
          if (matchedApp != null) {
            return matchedApp.copyWith(
              isFavorite: true,
              favoriteOrder: savedFavorite.favoriteOrder,
            );
          }
          return savedFavorite;
        }).toList();
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
    }
  }

  void _onFavoritesChanged(List<LauncherApp> newFavorites) {
    setState(() {
      _favoriteApps = List.from(newFavorites);
    });
    FavoritesService.saveFavorites(newFavorites);
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
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ChatScreen()));
        break;
    }
  }

  Future<void> _lockScreen() async {
    if (!mounted) return;
    final isRunning = await LockService.isServiceRunning();
    if (!isRunning) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Enable Zen Assistant in Accessibility to lock by double-tap',
          ),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () => LockService.requestEnableService(),
          ),
        ),
      );
      return;
    }
    LockService.lockScreen();
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
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                height: 28 / 20,
                color: ZenColors.ink,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Coming soon…',
              style: TextStyle(
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Apps icon at top-right
                            SafeArea(
                              bottom: false,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.apps,
                                        color: ZenColors.outline,
                                      ),
                                      onPressed: _openAllApps,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Golden-ratio spacer (5:8 ≈ 1:1.618)
                            Expanded(
                              flex: 5,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onDoubleTap: _lockScreen,
                                child: const SizedBox.expand(),
                              ),
                            ),

                            // Favorites list
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _favoriteApps
                                    .take(Config.maxFavoriteApps)
                                    .map(
                                      (app) => _AppTextButton(
                                        label: app.name,
                                        onTap: () {
                                          AppListService.launchApp(
                                            app.packageName,
                                          );
                                        },
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),

                            Expanded(
                              flex: 8,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onDoubleTap: _lockScreen,
                                child: const SizedBox.expand(),
                              ),
                            ),
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
      ),
    );
  }
}

/// A text-button for an app entry matching the "Text Only Edition" design.
class _AppTextButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AppTextButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            height: 32 / 24,
            color: ZenColors.ink,
          ),
        ),
      ),
    );
  }
}
