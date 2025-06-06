import 'package:flutter/material.dart';
import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter_iconpicker/Models/IconPack.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart'
    as FlutterIconPicker;
import 'package:go_router/go_router.dart';
import 'package:inkger/frontend/services/book_folders_service.dart';
import 'package:inkger/frontend/services/writer_services.dart';

class FolderTreeNode extends StatelessWidget {
  final TreeNode node;
  final TreeNode root;
  final Future<void> Function() onNodeChanged;
  final Future<void> Function() onNodeDeleted;

  const FolderTreeNode({
    Key? key,
    required this.node,
    required this.root,
    required this.onNodeChanged,
    required this.onNodeDeleted,
  }) : super(key: key);

  Future<void> _addNode({
    required BuildContext context,
    required String title,
    required String idPrefix,
    required String icon,
  }) async {
    final TextEditingController controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Nombre de $title'.toLowerCase(),
            ),
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
      final generatedId =
          '${idPrefix}_${DateTime.now().millisecondsSinceEpoch}'; // Generar ID único
      final newNode = TreeNode(
        key: generatedId,
        data: {
          'key': generatedId,
          'name': result,
          'icon': icon,
          'parentId': node.data['key'], // Usar el key del nodo padre
          'children': [],
        },
      );
      node.add(newNode);
      await onNodeChanged();
      await BookFoldersService.saveBooksTreeStructure(
        root.children.values.map((child) {
          final treeNode = child as TreeNode;
          return {
            'key': treeNode.data['key'],
            'name': treeNode.data['name'],
            'icon': treeNode.data['icon'] ?? 'folder',
            'children': _treeNodeToList(treeNode),
          };
        }).toList(),
      );
      // Use the newly created node for document creation
      await WriterServices.createDocument(
        newNode.data?['key'] ?? '',
        result,
        '[{"insert":"\\n"}]', // Delta vacío válido para Quill
      );
    }
  }

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
            PopupMenuItem<String>(value: 'rename', child: Text('Renombrar')),
            PopupMenuItem<String>(value: 'delete', child: Text('Eliminar')),
            PopupMenuItem<String>(value: 'icon', child: Text('Cambiar icono')),
          ],
        );
        if (selected == 'add_folder') {
          await _addNode(
            context: context,
            title: 'Nueva Carpeta',
            idPrefix: 'item',
            icon: 'folder',
          );
        } else if (selected == 'add_doc') {
          await _addNode(
            context: context,
            title: 'Nuevo Documento',
            idPrefix: 'doc',
            icon: 'doc',
          );
        } else if (selected == 'rename') {
          final TextEditingController controller = TextEditingController(
            text: node.data['name'] ?? '',
          );
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
            if (node.data['key'] != null) {
              await BookFoldersService.deleteBooksFolderNode(node.data['key']);
            }
            node.parent!.remove(node);
            await onNodeDeleted();
            context.go('/home-writer');
          }
        } else if (selected == 'icon') {
          final IconData? icon = await FlutterIconPicker.showIconPicker(
            context,
            iconPackModes: [IconPack.material],
            showSearchBar: true,
            title: const Text('Selecciona un icono'),
          );
          if (icon != null) {
            node.data['icon'] = icon.codePoint
                .toString(); // Guardamos el código del ícono
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
        'key': treeNode.data['key'], // Asegúrate de incluir el key aquí
        'name': treeNode.data['name'],
        'icon': treeNode.data['icon'] ?? 'folder',
        'children': _treeNodeToList(
          treeNode,
        ), // Recursivamente incluir los hijos
      };
    }).toList();
  }

  IconData _iconFromString(String icon) {
    final int? codePoint = int.tryParse(icon);
    if (codePoint != null) {
      return IconData(codePoint, fontFamily: 'MaterialIcons');
    }

    // Fallback por si el ícono es un nombre (casos anteriores)
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
      case 'groups':
        return Icons.group;
      case 'place':
        return Icons.place;
      case 'event':
        return Icons.event;
      case 'inventory':
        return Icons.inventory;
      case 'description':
        return Icons.description;
      case 'histoy_edu':
        return Icons.history_edu;
      case 'science':
        return Icons.science;
      default:
        return Icons.folder;
    }
  }
}
