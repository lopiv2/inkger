import 'package:flutter/material.dart';
import 'package:inkger/frontend/models/feed.dart';
import 'package:inkger/frontend/utils/feeds_provider.dart';
import 'package:inkger/frontend/services/feeds_service.dart';
import 'package:inkger/frontend/widgets/custom_snackbar.dart';
import 'package:inkger/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditFeedsScreen extends StatefulWidget {
  @override
  State<EditFeedsScreen> createState() => _EditFeedsScreenState();
}

class _EditFeedsScreenState extends State<EditFeedsScreen> {
  void _showAddFeedDialog() async {
    final nameController = TextEditingController();
    final logoController = TextEditingController();
    final urlController = TextEditingController();
    final categoryController = TextEditingController();
    bool active = true;
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id');

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Agregar nuevo feed'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Nombre'),
                    ),
                    TextField(
                      controller: logoController,
                      decoration: InputDecoration(labelText: 'Logo (URL)'),
                    ),
                    TextField(
                      controller: urlController,
                      decoration: InputDecoration(labelText: 'Dirección (URL)'),
                    ),
                    TextField(
                      controller: categoryController,
                      decoration: InputDecoration(labelText: 'Categoría'),
                    ),
                    Row(
                      children: [
                        const Text('Activo'),
                        Switch(
                          value: active,
                          onChanged: (v) => setState(() => active = v),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'name': nameController.text.trim(),
                      'logo': logoController.text.trim(),
                      'url': urlController.text.trim(),
                      'category': categoryController.text.trim(),
                      'active': active,
                      'userId': userId,
                    });
                  },
                  child: Text('Agregar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null &&
        result['name'].isNotEmpty &&
        result['url'].isNotEmpty) {
      final feedsProvider = Provider.of<FeedsProvider>(context, listen: false);
      feedsProvider.addFeed(Feed.fromMap(result));
      await FeedsService.addFeed(result);
      CustomSnackBar.show(
        context,
        AppLocalizations.of(context)!.feedAdded,
        Colors.green,
        duration: Duration(seconds: 4),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedsProvider = Provider.of<FeedsProvider>(context);
    final feeds = feedsProvider.feeds;

    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Feeds'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Agregar feed',
            onPressed: _showAddFeedDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Nombre')),
            DataColumn(label: Text('Logo')),
            DataColumn(label: Text('Dirección')),
            DataColumn(label: Text('Categoría')),
            DataColumn(label: Text('Activo')),
            DataColumn(label: Text('Acciones')),
          ],
          rows: List.generate(feeds.length, (i) {
            final feed = feeds[i];
            return DataRow(
              cells: [
                DataCell(Text(feed.name)),
                DataCell(
                  Row(
                    children: [
                      if (feed.logo.isNotEmpty)
                        Image.network(
                          feed.logo,
                          width: 32,
                          height: 32,
                          errorBuilder: (_, __, ___) =>
                              Icon(Icons.broken_image),
                        ),
                    ],
                  ),
                ),
                DataCell(Text(feed.url)),
                DataCell(Text(feed.category)),
                DataCell(
                  Switch(
                    value: feed.active,
                    onChanged: (v) async {
                      final updatedFeed = {
                        'name': feed.name,
                        'logo': feed.logo,
                        'url': feed.url,
                        'category': feed.category,
                        'active': v,
                        'userId': feed.userId,
                      };
                      feedsProvider.updateFeed(i, Feed.fromMap(updatedFeed));
                      if (feed.id != null) {
                        await FeedsService.updateFeed(feed.id!, updatedFeed);
                      }
                      await feedsProvider.loadAllFeedsFromSources();
                    },
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        tooltip: 'Editar',
                        onPressed: () async {
                          final nameController = TextEditingController(
                            text: feed.name,
                          );
                          final logoController = TextEditingController(
                            text: feed.logo,
                          );
                          final urlController = TextEditingController(
                            text: feed.url,
                          );
                          final categoryController = TextEditingController(
                            text: feed.category,
                          );
                          bool active = feed.active;

                          final result = await showDialog<Map<String, dynamic>>(
                            context: context,
                            builder: (context) {
                              return StatefulBuilder(
                                builder: (context, setState) {
                                  return AlertDialog(
                                    title: Text('Editar feed'),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextField(
                                            controller: nameController,
                                            decoration: InputDecoration(
                                              labelText: 'Nombre',
                                            ),
                                          ),
                                          TextField(
                                            controller: logoController,
                                            decoration: InputDecoration(
                                              labelText: 'Logo (URL)',
                                            ),
                                          ),
                                          TextField(
                                            controller: urlController,
                                            decoration: InputDecoration(
                                              labelText: 'Dirección (URL)',
                                            ),
                                          ),
                                          TextField(
                                            controller: categoryController,
                                            decoration: InputDecoration(
                                              labelText: 'Categoría',
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              const Text('Activo'),
                                              Switch(
                                                value: active,
                                                onChanged: (v) =>
                                                    setState(() => active = v),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context, {
                                            'name': nameController.text.trim(),
                                            'logo': logoController.text.trim(),
                                            'url': urlController.text.trim(),
                                            'category': categoryController.text
                                                .trim(),
                                            'active': active,
                                          });
                                        },
                                        child: Text('Guardar'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );

                          if (result != null &&
                              result['name'].isNotEmpty &&
                              result['url'].isNotEmpty) {
                            final prefs = await SharedPreferences.getInstance();
                            final userId = prefs.getInt('id');
                            result['userId'] = userId;
                            feedsProvider.updateFeed(i, Feed.fromMap(result));
                            if (feed.id != null)
                              await FeedsService.updateFeed(feed.id!, result);
                          }
                          CustomSnackBar.show(
                            context,
                            AppLocalizations.of(context)!.feedUpdated,
                            Colors.green,
                            duration: Duration(seconds: 4),
                          );
                          await feedsProvider.loadAllFeedsFromSources();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Eliminar feed',
                        onPressed: () async {
                          feedsProvider.deleteFeed(i);
                          if (feed.id != null)
                            await FeedsService.deleteFeed(feed.id!);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
