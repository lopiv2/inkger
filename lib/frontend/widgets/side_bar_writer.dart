import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SidebarWriter extends StatefulWidget {
  final Function(String) onItemSelected;

  const SidebarWriter({Key? key, required this.onItemSelected})
    : super(key: key);

  @override
  _SidebarWriterState createState() => _SidebarWriterState();
}

class _SidebarWriterState extends State<SidebarWriter> {
  final Map<String, bool> _expandedItems = {
    'drafts': true,
    'research': false,
    'trash': false,
    'templates': false,
    'generators': false,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        border: Border.all(color: Colors.grey[700]!, width: 1),
      ),
      width: 250,
      height: double.infinity,
      child: Column(
        children: [
          // Área desplazable: encabezado y secciones principales
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Título del proyecto
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'MY NOVEL',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Divisor
                  Container(height: 1, color: Colors.grey[700]),
                  const SizedBox(height: 8),
                  // Sección: DRAFTS (Ejemplo)
                  _buildTreeSection(
                    title: 'DRAFTS',
                    icon: Icons.description,
                    sectionKey: 'drafts',
                    children: [
                      _buildTreeItem(
                        title: 'Manuscript',
                        level: 1,
                        isSelected: true,
                        onTap: () => widget.onItemSelected('manuscript'),
                      ),
                      _buildTreeItem(
                        title: 'Chapter 1',
                        level: 2,
                        onTap: () => widget.onItemSelected('chapter1'),
                      ),
                      _buildTreeItem(
                        title: 'Chapter 2',
                        level: 2,
                        onTap: () => widget.onItemSelected('chapter2'),
                      ),
                      _buildTreeItem(
                        title: 'Outline',
                        level: 1,
                        onTap: () => widget.onItemSelected('outline'),
                      ),
                      _buildTreeItem(
                        title: 'Character Sketches',
                        level: 1,
                        onTap: () => widget.onItemSelected('characters'),
                      ),
                    ],
                  ),
                  // Sección: RESEARCH
                  _buildTreeSection(
                    title: 'RESEARCH',
                    icon: Icons.search,
                    sectionKey: 'research',
                    children: [
                      _buildTreeItem(
                        title: 'World Building',
                        level: 1,
                        onTap: () => widget.onItemSelected('worldbuilding'),
                      ),
                      _buildTreeItem(
                        title: 'Historical Notes',
                        level: 1,
                        onTap: () => widget.onItemSelected('history'),
                      ),
                    ],
                  ),
                  // Sección: TEMPLATES
                  _buildTreeSection(
                    title: 'TEMPLATES',
                    icon: Icons.copy,
                    sectionKey: 'templates',
                    children: [
                      _buildTreeItem(
                        title: 'Chapter Template',
                        level: 1,
                        onTap: () => widget.onItemSelected('chapter_template'),
                      ),
                      _buildTreeItem(
                        title: 'Scene Template',
                        level: 1,
                        onTap: () => widget.onItemSelected('scene_template'),
                      ),
                    ],
                  ),
                  // Espaciado para evitar que el contenido se solape con la zona fija
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Área fija en la parte inferior
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTreeSection(
                title: 'NAME GENERATORS',
                icon: Icons.generating_tokens,
                sectionKey: 'generators',
                onTap: () => context.go('/home-writer/generators'),
              ),
              _buildTreeSection(
                title: 'TRASH',
                icon: Icons.delete,
                sectionKey: 'trash',
                children: [
                  _buildTreeItem(
                    title: 'Old Drafts',
                    level: 1,
                    onTap: () => widget.onItemSelected('old_drafts'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTreeSection({
    required String title,
    required IconData icon,
    required String sectionKey,
    List<Widget>? children,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          dense: true,
          leading: Icon(icon, size: 18, color: Colors.grey[400]),
          title: Text(
            title,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: Icon(
            _expandedItems[sectionKey]!
                ? Icons.arrow_drop_down
                : Icons.arrow_right,
            color: Colors.grey[400],
          ),
          onTap: onTap,

          /*setState(() {
              _expandedItems[sectionKey] = !_expandedItems[sectionKey]!;
            });*/
        ),
        if (_expandedItems[sectionKey]!) ...?children,
      ],
    );
  }

  Widget _buildTreeItem({
    required String title,
    required int level,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: 16.0 + (level * 16.0)),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[400],
            fontSize: 13,
          ),
        ),
        selected: isSelected,
        selectedTileColor: Colors.grey[800],
        onTap: onTap,
      ),
    );
  }
}
