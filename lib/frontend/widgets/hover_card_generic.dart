import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HoverCardGeneric extends StatefulWidget {
  final Widget child;
  final String title;
  final String coverPath; // Default cover path

  const HoverCardGeneric({super.key, required this.child, required this.title, required this.coverPath});

  @override
  _HoverCardGenericState createState() => _HoverCardGenericState();
}

class _HoverCardGenericState extends State<HoverCardGeneric> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push(
          '/series/${Uri.encodeComponent(widget.title)}',
          extra: widget.coverPath,
        );
      },
      splashColor: Colors.black.withOpacity(0.1),
      highlightColor: Colors.transparent,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Stack(
          children: [
            widget.child,
            if (_isHovered)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.yellow, width: 4),
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
