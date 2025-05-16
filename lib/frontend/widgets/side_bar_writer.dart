import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inkger/frontend/services/book_folders_service.dart';
import 'package:animated_tree_view/animated_tree_view.dart';
import 'dart:html' as html;
import 'package:inkger/frontend/widgets/folder_tree_node.dart';

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

  @override
  void initState() {
    super.initState();
    _loadBooksTree();
    // Prevenir el menú contextual nativo en web solo si estamos en web
    // ignore: undefined_prefixed_name
    if (identical(0, 0.0)) {
      // Solo se ejecuta en web
      html.document.onContextMenu.listen((event) => event.preventDefault());
    }
  }

  Future<void> _loadBooksTree() async {
    try {
      final tree = await BookFoldersService.fetchBooksTreeStructure();
      setState(() {
        myBooks = tree;
      });
    } catch (e) {
      // Puedes mostrar un error si lo deseas
    }
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
                  final newNode = {
                    'name': controller.text.trim(),
                    'children': <Map<String, dynamic>>[],
                    'icon': 'book',
                  };
                  setState(() {
                    (parent ?? myBooks).add(newNode);
                  });
                  await BookFoldersService.saveBooksFolderNode(newNode);
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
                    child: SizedBox(
                      height: 300, // O usa Expanded si quieres que ocupe todo el espacio disponible
                      child: _buildBooksTreeView(myBooks),
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

  Widget _buildBooksTreeView(List<Map<String, dynamic>> books) {
    final root = TreeNode.root();
    for (final book in books) {
      root.add(_mapToTreeNode(book));
    }
    return TreeView.simple(
      tree: root,
      showRootNode: false,
      expansionIndicatorBuilder: (context, node) =>
          ChevronIndicator.rightDown(
            tree: node,
            color: Colors.blue[700],
            padding: const EdgeInsets.all(8),
          ),
      indentation: const Indentation(style: IndentStyle.roundJoint, width: 8),
      onItemTap: (item) {
        // Aquí puedes manejar la selección del nodo si lo deseas
      },
      builder: (context, node) => FolderTreeNode(
        node: node,
        root: root,
        onNodeChanged: () async {
          setState(() {
            myBooks = _treeNodeToList(root);
          });
          // Guardar solo el nodo recién creado si es nuevo
          if (node.data['isNew'] == true) {
            await BookFoldersService.saveBooksFolderNode({
              'name': node.data['name'],
              'icon': node.data['icon'] ?? 'folder',
              'children': [],
            }, parentId: (node.parent is TreeNode) ? (node.parent as TreeNode).data['id'] : null);
            node.data.remove('isNew'); // Elimina la marca de nuevo
          }
          // Si quieres guardar el árbol completo, descomenta la siguiente línea:
          // await BookFoldersService.saveBooksTreeStructure(myBooks);
        },
      ),
    );
  }

  TreeNode _mapToTreeNode(Map<String, dynamic> book) {
    final node = TreeNode(
      key: UniqueKey().toString(),
      data: {'name': book['name'], 'icon': book['icon'] ?? 'folder'},
    );
    if (book['children'] != null && book['children'] is List) {
      for (final child in book['children']) {
        node.add(_mapToTreeNode(child));
      }
    }
    return node;
  }

  List<Map<String, dynamic>> _treeNodeToList(TreeNode node) {
    return node.children.values.map<Map<String, dynamic>>((child) {
      final treeNode = child as TreeNode;
      return {
        'name': treeNode.data['name'],
        'icon': treeNode.data['icon'] ?? 'folder',
        'children': _treeNodeToList(treeNode),
      };
    }).toList();
  }
}
