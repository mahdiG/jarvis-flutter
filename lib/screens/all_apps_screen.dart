import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/launcher_app.dart';
import '../services/app_list_service.dart';

/// Full list of all installed apps with favorite/unfavorite controls.
///
/// Opens as a full-screen modal route from the launcher.
class AllAppsScreen extends StatefulWidget {
  final List<LauncherApp> currentFavorites;
  final ValueChanged<List<LauncherApp>> onFavoritesChanged;

  const AllAppsScreen({
    super.key,
    required this.currentFavorites,
    required this.onFavoritesChanged,
  });

  @override
  State<AllAppsScreen> createState() => _AllAppsScreenState();
}

class _AllAppsScreenState extends State<AllAppsScreen> {
  List<LauncherApp> _allApps = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadApps() async {
    final apps = await AppListService.fetchInstalledApps();
    setState(() {
      _allApps = apps.map((app) {
        final match = widget.currentFavorites.cast<LauncherApp?>().firstWhere(
              (f) => f!.packageName == app.packageName,
              orElse: () => null,
            );
        if (match != null) {
          app.isFavorite = true;
          app.favoriteOrder = match.favoriteOrder;
        }
        return app;
      }).toList();
      _allApps.sort((a, b) {
        // Favorites first, then alphabetical
        if (a.isFavorite && !b.isFavorite) return -1;
        if (!a.isFavorite && b.isFavorite) return 1;
        if (a.isFavorite && b.isFavorite) {
          return a.favoriteOrder.compareTo(b.favoriteOrder);
        }
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
      _isLoading = false;
    });
  }

  void _toggleFavorite(LauncherApp app) {
    setState(() {
      app.isFavorite = !app.isFavorite;
      if (app.isFavorite) {
        app.favoriteOrder = widget.currentFavorites.length;
      } else {
        app.favoriteOrder = -1;
      }
    });
    _emitFavorites();
  }

  void _emitFavorites() {
    final favorites = _allApps
        .where((a) => a.isFavorite)
        .toList()
      ..sort((a, b) => a.favoriteOrder.compareTo(b.favoriteOrder));
    widget.onFavoritesChanged(favorites);
  }

  List<LauncherApp> get _filteredApps {
    if (_searchQuery.isEmpty) return _allApps;
    final q = _searchQuery.toLowerCase();
    return _allApps
        .where((app) => app.name.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZenColors.paperBg,
      appBar: AppBar(
        backgroundColor: ZenColors.paperBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: ZenColors.ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'All Apps',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: ZenColors.surfaceContainer,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: ZenColors.surfaceContainerHighest.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: ZenColors.outline,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Search apps...',
                        hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: ZenColors.outline.withValues(alpha: 0.7),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        isDense: true,
                      ),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: ZenColors.ink,
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: ZenColors.outline,
                      ),
                    ),
                ],
              ),
            ),
          ),
          // App list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredApps.isEmpty
                    ? Center(
                        child: Text(
                          'No apps found',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                        itemCount: _filteredApps.length,
                        separatorBuilder: (_, _) => const Divider(
                          height: 1,
                          color: ZenColors.surfaceContainerHighest,
                        ),
                        itemBuilder: (context, index) {
                          final app = _filteredApps[index];
                          final isFavorite = app.isFavorite;
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: ZenColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  app.name.isNotEmpty
                                      ? app.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: ZenColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              app.name,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: ZenColors.ink,
                              ),
                            ),
                            trailing: GestureDetector(
                              onTap: () => _toggleFavorite(app),
                              child: Icon(
                                isFavorite
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                size: 24,
                                color: isFavorite
                                    ? ZenColors.onSecondaryContainer
                                    : ZenColors.outline,
                              ),
                            ),
                            onTap: () {
                              AppListService.launchApp(app.packageName);
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}