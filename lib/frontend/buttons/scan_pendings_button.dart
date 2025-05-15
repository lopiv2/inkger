import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inkger/frontend/services/common_services.dart';
import 'package:inkger/frontend/utils/book_provider.dart';
import 'package:inkger/frontend/utils/comic_provider.dart';
import 'package:inkger/frontend/utils/preferences_provider.dart';
import 'package:inkger/frontend/widgets/custom_snackbar.dart';
import 'package:inkger/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanPendingFilesButton extends StatefulWidget {
  final double iconSize;
  final Color iconColor;
  final Color? hoverColor;
  final String tooltipText;
  final EdgeInsetsGeometry padding;
  final bool showBadge;

  const ScanPendingFilesButton({
    super.key,
    this.iconSize = 24,
    this.iconColor = Colors.blue,
    this.hoverColor,
    this.tooltipText = 'Importar archivo',
    this.padding = const EdgeInsets.all(8),
    this.showBadge = false,
  });

  @override
  State<ScanPendingFilesButton> createState() => _ScanPendingFilesButtonState();
}

class _ScanPendingFilesButtonState extends State<ScanPendingFilesButton> {
  bool _isHovering = false;
  bool hasPending = false;
  bool _isImporting = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    final preferencesProvider = Provider.of<PreferencesProvider>(
      context,
      listen: false,
    );
    checkPending();
    timer = Timer.periodic(
      Duration(minutes: preferencesProvider.preferences.scanInterval.round()),
      (_) => checkPending(),
    );
  }

  Future<void> checkPending() async {
    try {
      final res = await CommonServices.checkIfPendingFiles();
      final data = res.data;
      setState(() {
        hasPending = data["hasPending"];
      });
    } catch (e) {
      debugPrint("Error checking pending files: $e");
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Tooltip(
        message: widget.tooltipText,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              iconSize: widget.iconSize,
              padding: widget.padding,
              color: widget.iconColor,
              hoverColor: widget.hoverColor ?? Colors.blue.withOpacity(0.1),
              icon: _isImporting
                  ? SizedBox(
                      width: widget.iconSize,
                      height: widget.iconSize,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.document_scanner,
                      color: _isHovering
                          ? Theme.of(context).primaryColor
                          : widget.iconColor,
                    ),
              onPressed: _isImporting
                  ? null
                  : () async {
                      setState(() {
                        _isImporting = true;
                      });
                      final start = DateTime.now();
                      await CommonServices.scanPendingFolder();
                      final prefs = await SharedPreferences.getInstance();
                      final id = prefs.getInt('id');
                      if (!mounted) return;
                      final provider = Provider.of<ComicsProvider>(
                        context,
                        listen: false,
                      );
                      final providerBooks = Provider.of<BooksProvider>(
                        context,
                        listen: false,
                      );
                      setState(() {
                        hasPending = false;
                      });
                      CustomSnackBar.show(
                        context,
                        AppLocalizations.of(context)!.filesImportedSuccess,
                        Colors.green,
                        duration: Duration(seconds: 4),
                      );
                      context.go('/comics');
                      await provider.loadcomics(id ?? 0);
                      await providerBooks.loadBooks(id ?? 0);
                      final elapsed = DateTime.now().difference(start);
                      final remaining = Duration(seconds: 5) - elapsed;
                      if (remaining > Duration.zero) {
                        await Future.delayed(remaining);
                      }
                      if (mounted) {
                        setState(() {
                          _isImporting = false;
                        });
                      }
                    },
            ),
            if (hasPending)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
