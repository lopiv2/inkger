import 'package:flutter/material.dart';
import 'package:inkger/frontend/widgets/import_file.dart';

class ImportIconButton extends StatefulWidget {
  final double iconSize;
  final Color iconColor;
  final Color? hoverColor;
  final String tooltipText;
  final EdgeInsetsGeometry padding;
  final bool showBadge;

  const ImportIconButton({
    super.key,
    this.iconSize = 24,
    this.iconColor = Colors.blue,
    this.hoverColor,
    this.tooltipText = 'Importar archivo',
    this.padding = const EdgeInsets.all(8),
    this.showBadge = false,
  });

  @override
  State<ImportIconButton> createState() => _ImportIconButtonState();
}

class _ImportIconButtonState extends State<ImportIconButton> {
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
                Icons.upload_file,
                color: _isHovering 
                    ? Theme.of(context).primaryColor 
                    : widget.iconColor,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    contentPadding: EdgeInsets.zero,
                    content: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 600,
                        maxHeight: 400,
                      ),
                      child: const ImportFile(),
                    ),
                  ),
                );
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