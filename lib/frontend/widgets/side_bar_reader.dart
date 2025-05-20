import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inkger/frontend/dialogs/edit_library_dialog.dart';
import 'package:inkger/frontend/utils/feeds_provider.dart';
import 'package:inkger/frontend/utils/constants.dart';
import 'package:inkger/frontend/utils/preferences_provider.dart';
import 'package:inkger/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class Sidebar extends StatefulWidget {
  final Function(String) onItemSelected;

  const Sidebar({Key? key, required this.onItemSelected}) : super(key: key);

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFeeds();
    });
  }

  Future<void> _loadFeeds() async {
    final feedsProvider = Provider.of<FeedsProvider>(context, listen: false);
    await feedsProvider.loadFeeds();
  }

  @override
  Widget build(BuildContext context) {
    late Color themeColor = Colors.blueGrey;
    final preferencesProvider = Provider.of<PreferencesProvider>(
      context,
      listen: false,
    );
    themeColor = Color(preferencesProvider.preferences.themeColor);
    return Container(
      decoration: BoxDecoration(
        color: themeColor,
        border: Border.all(color: Colors.black, width: 2),
      ),
      width: 250,
      height: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildHoverMenuItem(
              context,
              Icons.home,
              AppLocalizations.of(context)!.home,
              '/home',
            ),
            _buildHoverLibraryMenu(context),
            _buildHoverMenuItem(
              context,
              Icons.category,
              AppLocalizations.of(context)!.categories,
              'categories',
            ),
            _buildHoverMenuItem(
              context,
              Icons.list,
              AppLocalizations.of(context)!.readingLists,
              '/reading-lists',
            ),
            _buildHoverMenuItem(
              context,
              Icons.collections_bookmark,
              'Series',
              '/series',
            ),
            _buildHoverMenuItem(
              context,
              Icons.calendar_month,
              AppLocalizations.of(context)!.calendar,
              '/calendar',
            ),
            _buildHoverFeedsMenu(
              context,
              feedsCount: context.watch<FeedsProvider>().totalFeeds,
            ),
            _buildHoverMenuItem(context, Icons.help_center, 'Tests', 'Tests'),
          ],
        ),
      ),
    );
  }

  Widget _buildHoverLibraryMenu(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        hoverColor: Colors.blueGrey[700],
        splashColor: Colors.transparent,
      ),
      child: ExpansionTile(
        leading: const Icon(Icons.library_books, color: Colors.white),
        title: Text(
          AppLocalizations.of(context)!.libraries,
          style: TextStyle(color: Colors.white),
        ),
        children: [
          _buildHoverNestedMenuItem(context, 'Comics', 'comics'),
          _buildHoverNestedMenuItem(
            context,
            AppLocalizations.of(context)!.books,
            'books',
          ),
          _buildHoverNestedMenuItem(
            context,
            AppLocalizations.of(context)!.audiobooks,
            'audiobooks',
          ),
        ],
      ),
    );
  }

  Widget _buildHoverFeedsMenu(BuildContext context, {int feedsCount = 0}) {
    final isLoading = context.watch<FeedsProvider>().feeds.isEmpty;
    return Theme(
      data: Theme.of(context).copyWith(
        hoverColor: Colors.blueGrey[700],
        splashColor: Colors.transparent,
      ),
      child: ExpansionTile(
        leading: const Icon(Icons.rss_feed, color: Colors.white),
        title: Row(
          children: [
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.feeds,
                style: TextStyle(color: Colors.white),
              ),
            ),
            if (!isLoading && feedsCount > 0)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$feedsCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
        children: [
          Material(
            color: Colors.transparent,
            child: ListTile(
              leading: const Icon(
                Icons.visibility,
                color: Colors.white,
                size: 20,
              ),
              title: Text(
                'Ver Feeds',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              contentPadding: const EdgeInsets.only(left: 30, right: 10),
              minLeadingWidth: 30,
              hoverColor: Colors.blueGrey[700],
              onTap: () => context.go('/feeds'),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: ListTile(
              leading: const Icon(Icons.edit, color: Colors.white, size: 20),
              title: Text(
                'Editar Feeds',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              contentPadding: const EdgeInsets.only(left: 30, right: 10),
              minLeadingWidth: 30,
              hoverColor: Colors.blueGrey[700],
              onTap: () => context.go('/feeds/edit'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoverNestedMenuItem(
    BuildContext context,
    String title,
    String libraryId,
  ) {
    IconData leadingIcon;
    switch (libraryId) {
      case 'comics':
        leadingIcon = Icons.question_answer;
        break;
      case 'books':
        leadingIcon = Icons.menu_book;
        break;
      case 'audiobooks':
        leadingIcon = Icons.headphones;
        break;
      default:
        leadingIcon = Icons.bubble_chart;
    }

    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(leadingIcon, color: Colors.white),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        contentPadding: const EdgeInsets.only(left: 30, right: 10),
        minLeadingWidth: 30,
        hoverColor: Colors.blueGrey[700],
        onTap: () => context.go('/${libraryId.toLowerCase()}'),
        trailing: _buildPopupMenuButton(context, title, libraryId),
      ),
    );
  }

  Widget _buildHoverMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        minLeadingWidth: 30,
        hoverColor: Colors.blueGrey[700],
        onTap: () => context.go(value),
      ),
    );
  }

  PopupMenuButton<String> _buildPopupMenuButton(
    BuildContext context,
    String title,
    String libraryId,
  ) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onSelected: (value) =>
          _handleMenuSelection(context, value, title, libraryId),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              const Icon(Icons.edit, color: Colors.black),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.edit),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'scan',
          child: Row(
            children: [
              const Icon(Icons.scanner, color: Colors.black),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.scan),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'update_metadata',
          child: Row(
            children: [
              const Icon(Icons.update, color: Colors.black),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.updateMetadata),
            ],
          ),
        ),
      ],
    );
  }

  void _handleMenuSelection(
    BuildContext context,
    String value,
    String title,
    String libraryId,
  ) {
    switch (value) {
      case 'edit':
        _showEditDialog(context, title, libraryId);
        break;
      case 'scan':
        Constants.logger.info('Scan $title');
        break;
      case 'update_metadata':
        Constants.logger.info('Update metadata of $title');
        break;
    }
  }

  void _showEditDialog(BuildContext context, String title, String libraryId) {
    showDialog(
      context: context,
      builder: (context) =>
          EditLibraryDialog(libraryTitle: title, libraryId: libraryId),
    );
  }
}
