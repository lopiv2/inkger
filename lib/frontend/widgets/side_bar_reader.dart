import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inkger/frontend/dialogs/edit_library_dialog.dart';
import 'package:inkger/frontend/utils/constants.dart';
import 'package:inkger/l10n/app_localizations.dart';

class Sidebar extends StatelessWidget {
  final Function(String) onItemSelected;

  const Sidebar({Key? key, required this.onItemSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        border: Border.all(color: Colors.black, width: 2),
      ),
      width: 250,
      height:double.infinity,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildHoverMenuItem(Icons.home, 'Inicio', 'Home'),
            _buildHoverLibraryMenu(context),
            _buildHoverMenuItem(Icons.category, 'Categorías', 'categories'),
            _buildHoverMenuItem(Icons.list, 'Listas de lectura', 'lists'),
            _buildHoverMenuItem(Icons.collections_bookmark, 'Series', 'series'),
            _buildHoverMenuItem(Icons.book, 'Estanterías', 'shelves'),
            _buildHoverMenuItem(Icons.help_center, 'Tests', 'Tests'),
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
        title: const Text('Bibliotecas', style: TextStyle(color: Colors.white)),
        children: [
          _buildHoverNestedMenuItem(context, 'Comics', 'comics'),
          _buildHoverNestedMenuItem(context, AppLocalizations.of(context)!.books, 'books'),
          _buildHoverNestedMenuItem(context, AppLocalizations.of(context)!.audiobooks, 'audiobooks'),
        ],
      ),
    );
  }

  Widget _buildHoverNestedMenuItem(BuildContext context, String title, String libraryId) {
    IconData leadingIcon;
    switch (libraryId) {
      case 'comics': leadingIcon = Icons.question_answer; break;
      case 'books': leadingIcon = Icons.menu_book; break;
      case 'audiobooks': leadingIcon = Icons.headphones; break;
      default: leadingIcon = Icons.bubble_chart;
    }

    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(leadingIcon, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
        contentPadding: const EdgeInsets.only(left: 30, right: 10),
        minLeadingWidth: 30,
        hoverColor: Colors.blueGrey[700],
        onTap: () => context.go('/${libraryId.toLowerCase()}'),
        trailing: _buildPopupMenuButton(context, title, libraryId),
      ),
    );
  }

  Widget _buildHoverMenuItem(IconData icon, String title, String value) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        minLeadingWidth: 30,
        hoverColor: Colors.blueGrey[700],
        onTap: () => onItemSelected(value),
      ),
    );
  }

  PopupMenuButton<String> _buildPopupMenuButton(BuildContext context, String title, String libraryId) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onSelected: (value) => _handleMenuSelection(context, value, title, libraryId),
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

  void _handleMenuSelection(BuildContext context, String value, String title, String libraryId) {
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
      builder: (context) => EditLibraryDialog(
        libraryTitle: title,
        libraryId: libraryId,
      ),
    );
  }
}