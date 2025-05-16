import 'package:flutter/material.dart';
import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:inkger/frontend/services/book_folders_service.dart';

class FolderTreeNode extends StatelessWidget {
  final TreeNode node;
  final TreeNode root;
  final Future<void> Function() onNodeChanged;

  const FolderTreeNode({
    Key? key,
    required this.node,
    required this.root,
    required this.onNodeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: (details) async {
        final selected = await showMenu<String>(
          context: context,
          position: RelativeRect.fromLTRB(
            details.globalPosition.dx,
            details.globalPosition.dy,
            details.globalPosition.dx,
            details.globalPosition.dy,
          ),
          items: [
            PopupMenuItem<String>(
              value: 'add_folder',
              child: Text('Añadir subcarpeta'),
            ),
            PopupMenuItem<String>(
              value: 'add_doc',
              child: Text('Añadir documento'),
            ),
            PopupMenuItem<String>(
              value: 'rename',
              child: Text('Renombrar'),
            ),
            PopupMenuItem<String>(
              value: 'delete',
              child: Text('Eliminar'),
            ),
            PopupMenuItem<String>(
              value: 'icon',
              child: Text('Cambiar icono'),
            ),
          ],
        );
        if (selected == 'add_folder') {
          final TextEditingController controller = TextEditingController();
          final result = await showDialog<String>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Nombre de la nueva carpeta'),
                content: TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'Nombre de la carpeta'),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (controller.text.trim().isNotEmpty) {
                        Navigator.of(context).pop(controller.text.trim());
                      }
                    },
                    child: const Text('Crear'),
                  ),
                ],
              );
            },
          );
          if (result != null && result.isNotEmpty) {
            // Guardar el nodo en la base de datos y obtener el id real
            final saved = await BookFoldersService.saveBooksFolderNode({
              'name': result,
              'icon': 'folder',
              'children': [],
            }, parentId: node.data['id']);
            final newNodeId = saved?['data']?['id'];
            // Añadir el nuevo nodo al árbol en memoria con el id real
            final newNode = TreeNode(key: UniqueKey().toString(), data: {
              'id': newNodeId,
              'name': result,
              'icon': 'folder',
              'children': []
            });
            node.add(newNode);
            await onNodeChanged();
            await BookFoldersService.saveBooksTreeStructure(
              root.children.values.map((child) {
                final treeNode = child as TreeNode;
                return {
                  'name': treeNode.data['name'],
                  'icon': treeNode.data['icon'] ?? 'folder',
                  'children': _treeNodeToList(treeNode),
                };
              }).toList(),
            );
          }
        } else if (selected == 'add_doc') {
          final TextEditingController controller = TextEditingController();
          final result = await showDialog<String>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Nombre del nuevo documento'),
                content: TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'Nombre del documento'),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (controller.text.trim().isNotEmpty) {
                        Navigator.of(context).pop(controller.text.trim());
                      }
                    },
                    child: const Text('Crear'),
                  ),
                ],
              );
            },
          );
          if (result != null && result.isNotEmpty) {
            // Guardar el nodo en la base de datos y obtener el id real
            final saved = await BookFoldersService.saveBooksFolderNode({
              'name': result,
              'icon': 'doc',
              'children': [],
            }, parentId: node.data['id']);
            final newNodeId = saved?['data']?['id'];
            // Añadir el nuevo nodo al árbol en memoria con el id real
            final newNode = TreeNode(key: UniqueKey().toString(), data: {
              'id': newNodeId,
              'name': result,
              'icon': 'doc',
              'children': []
            });
            node.add(newNode);
            await onNodeChanged();
            await BookFoldersService.saveBooksTreeStructure(
              root.children.values.map((child) {
                final treeNode = child as TreeNode;
                return {
                  'name': treeNode.data['name'],
                  'icon': treeNode.data['icon'] ?? 'folder',
                  'children': _treeNodeToList(treeNode),
                };
              }).toList(),
            );
          }
        } else if (selected == 'rename') {
          final TextEditingController controller = TextEditingController(text: node.data['name'] ?? '');
          final result = await showDialog<String>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Renombrar elemento'),
                content: TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'Nuevo nombre'),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (controller.text.trim().isNotEmpty) {
                        Navigator.of(context).pop(controller.text.trim());
                      }
                    },
                    child: const Text('Renombrar'),
                  ),
                ],
              );
            },
          );
          if (result != null && result.isNotEmpty) {
            node.data['name'] = result;
            await onNodeChanged();
          }
        } else if (selected == 'delete') {
          if (node.parent != null) {
            // Eliminar en la base de datos antes de quitar del árbol
            if (node.data['id'] == null) {
              // Buscar el id real tras guardar el árbol (si no está en memoria)
              await BookFoldersService.saveBooksTreeStructure(
                root.children.values.map((child) {
                  final treeNode = child as TreeNode;
                  return {
                    'name': treeNode.data['name'],
                    'icon': treeNode.data['icon'] ?? 'folder',
                    'children': _treeNodeToList(treeNode),
                  };
                }).toList(),
              );
              // Aquí podrías recargar el árbol y buscar el nodo por nombre/icono para obtener el id real
              // Pero lo ideal es que el id se asigne al crear el nodo
            }
            if (node.data['id'] != null) {
              await BookFoldersService.deleteBooksFolderNode(node.data['id']);
            }
            node.parent!.remove(node);
            await onNodeChanged();
            await BookFoldersService.saveBooksTreeStructure(
              root.children.values.map((child) {
                final treeNode = child as TreeNode;
                return {
                  'name': treeNode.data['name'],
                  'icon': treeNode.data['icon'] ?? 'folder',
                  'children': _treeNodeToList(treeNode),
                };
              }).toList(),
            );
          }
        } else if (selected == 'icon') {
          final icons = [
            {'icon': Icons.folder, 'label': 'Carpeta', 'value': 'folder'},
            {'icon': Icons.description, 'label': 'Documento', 'value': 'doc'},
            {'icon': Icons.star, 'label': 'Favorito', 'value': 'star'},
            {'icon': Icons.book, 'label': 'Libro', 'value': 'book'},
            {'icon': Icons.lightbulb, 'label': 'Idea', 'value': 'lightbulb'},
          ];
          final result = await showDialog<String>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Selecciona un icono'),
                content: SizedBox(
                  width: 300,
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: icons.map((iconData) {
                      return GestureDetector(
                        onTap: () => Navigator.of(context).pop(iconData['value'] as String),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(iconData['icon'] as IconData, size: 32, color: Colors.blueGrey),
                            const SizedBox(height: 4),
                            Text(iconData['label'] as String, style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                ],
              );
            },
          );
          if (result != null && result.isNotEmpty) {
            node.data['icon'] = result;
            await onNodeChanged();
          }
        }
      },
      child: Card(
        color: Colors.grey[900],
        child: ListTile(
          dense: true,
          leading: Icon(
            _iconFromString(node.data['icon'] ?? 'folder'),
            size: 16,
            color: Colors.amber[700],
          ),
          title: Text(
            node.data['name'] ?? '',
            style: TextStyle(color: Colors.grey[300], fontSize: 13),
          ),
        ),
      ),
    );
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

  IconData _iconFromString(String icon) {
    switch (icon) {
      case 'folder':
        return Icons.folder;
      case 'book':
        return Icons.import_contacts;
      case 'doc':
        return Icons.description;
      case 'star':
        return Icons.star;
      case 'lightbulb':
        return Icons.lightbulb;
      default:
        return Icons.folder;
    }
  }
}
