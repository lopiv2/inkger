import 'package:flutter/material.dart';
import 'package:inkger/frontend/services/common_services.dart';
import 'package:inkger/frontend/widgets/import_file.dart';

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
              icon: Icon(
                Icons.document_scanner,
                color: _isHovering
                    ? Theme.of(context).primaryColor
                    : widget.iconColor,
              ),
              onPressed: () {
                CommonServices.scanPendingFolder();
              },
            ),
            if (widget.showBadge)
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
