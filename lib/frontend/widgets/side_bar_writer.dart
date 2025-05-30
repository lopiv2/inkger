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
        myBooks = tree; // Actualiza la estructura de datos
      });
    } catch (e) {
      print('Error al cargar la estructura de libros: $e');
      // Opcional: Mostrar un mensaje de error al usuario
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
            decoration: const InputDecoration(
              hintText: 'Nombre del libro/carpeta',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (controller.text.trim().isNotEmpty) {
                  final generatedId =
                      'book_${DateTime.now().millisecondsSinceEpoch}'; // Generar ID único
                  final newNode = {
                    'key': generatedId, // Usar el ID generado
                    'name': controller.text.trim(),
                    'children': <Map<String, dynamic>>[],
                    'icon': 'book',
                  };

                  // Añadir el nuevo nodo al árbol en memoria
                  setState(() {
                    (parent ?? myBooks).add(newNode);
                  });

                  // Guardar la estructura completa del árbol
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
                          icon: Icon(
                            Icons.create_new_folder,
                            color: Colors.grey[400],
                            size: 18,
                          ),
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
                      height:
                          300, // O usa Expanded si quieres que ocupe todo el espacio disponible
                      child: _buildBooksTreeView(myBooks),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Divisor
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
      root.add(_mapToTreeNode(book)); // Convierte cada elemento en un nodo
    }
    return TreeView.simple(
      tree: root,
      showRootNode: false,
      expansionIndicatorBuilder: (context, node) => ChevronIndicator.rightDown(
        tree: node,
        color: Colors.blue[700],
        padding: const EdgeInsets.all(8),
      ),
      indentation: const Indentation(style: IndentStyle.roundJoint, width: 8),
      onItemTap: (item) {
        //Si es un documento
        if (item.data['key'].contains("doc")) {
          context.push("/home-writer/document-editor/${item.data['key']}");
        }
      },
      builder: (context, node) => FolderTreeNode(
        node: node,
        root: root,
        onNodeChanged: () async {
          setState(() {
            myBooks = _treeNodeToList(root); // Reconstruir la estructura
          });
          await BookFoldersService.saveBooksTreeStructure(myBooks);
        },
        onNodeDeleted: () async {
          final nodeToDelete = node;
          setState(() {
            root.remove(nodeToDelete); // Eliminar el nodo del árbol
            myBooks = _treeNodeToList(root); // Reconstruir la estructura
          });
          await BookFoldersService.saveBooksTreeStructure(myBooks);
        },
      ),
    );
  }

  TreeNode _mapToTreeNode(Map<String, dynamic> book) {
    // Verifica que el nodo tenga las claves necesarias
    if (!book.containsKey('key') || !book.containsKey('name')) {
      throw Exception('Faltan claves necesarias en el nodo: $book');
    }

    final node = TreeNode(
      key: UniqueKey().toString(),
      data: {
        'key': book['key'], // Asegurarse de incluir el ID
        'name': book['name'],
        'icon': book['icon'] ?? 'folder',
      },
    );

    // Procesa los hijos recursivamente si existen
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
        'key': treeNode.data['key'], // Asegurarse de incluir el ID
        'name': treeNode.data['name'],
        'icon': treeNode.data['icon'] ?? 'folder',
        'children': _treeNodeToList(treeNode),
      };
    }).toList();
  }
}
