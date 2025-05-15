import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inkger/frontend/services/book_folders_service.dart';

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

  List<Map<String, dynamic>> myBooks = [];

  void _addBookFolder(String name, [List<Map<String, dynamic>>? children]) {
    setState(() {
      myBooks.add({
        'name': name,
        'children': children ?? [],
      });
    });
  }

  void _showAddBookDialog({List<Map<String, dynamic>>? parent}) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Crear nuevo libro/carpeta'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Nombre del libro/carpeta'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    (parent ?? myBooks).add({
                      'name': controller.text.trim(),
                      'children': <Map<String, dynamic>>[],
                    });
                  });
                  await BookFoldersService.saveBooksTreeStructure(myBooks);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );
  }

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
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.create_new_folder, color: Colors.grey[400], size: 18),
                          tooltip: 'Añadir libro/carpeta',
                          onPressed: () => _showAddBookDialog(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'MY BOOKS',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // TreeView de libros/carpeta
                  Padding(
                    padding: const EdgeInsets.only(left: 32, top: 4, right: 8),
                    child: _buildBooksTreeView(myBooks),
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

  Widget _buildBooksTreeView(List<Map<String, dynamic>> books) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: books.map((book) {
        final children = book['children'] as List<Map<String, dynamic>>;
        final hasChildren = children.isNotEmpty;
        // Usar un ValueNotifier para el estado expandido
        final expandedNotifier = ValueNotifier<bool>(book['expanded'] ?? false);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            hasChildren
                ? ValueListenableBuilder<bool>(
                    valueListenable: expandedNotifier,
                    builder: (context, expanded, _) {
                      return IconButton(
                        icon: Icon(
                          expanded ? Icons.remove : Icons.add,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                        tooltip: expanded ? 'Colapsar' : 'Expandir',
                        onPressed: () {
                          expandedNotifier.value = !expanded;
                          book['expanded'] = expandedNotifier.value;
                        },
                      );
                    },
                  )
                : SizedBox(width: 40),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            book['name'],
                            style: TextStyle(color: Colors.grey[300], fontSize: 13),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.create_new_folder, size: 16, color: Colors.grey[400]),
                          tooltip: 'Añadir subcarpeta',
                          onPressed: () => _showAddBookDialog(parent: children),
                        ),
                      ],
                    ),
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: expandedNotifier,
                    builder: (context, expanded, _) {
                      if (expanded && hasChildren) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 4), // Reducido aún más
                          child: _buildBooksTreeView(children),
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
