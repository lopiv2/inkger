import 'package:flutter/material.dart';
import 'package:inkger/frontend/utils/book_filter_provider.dart';
import 'package:provider/provider.dart';

class BookFiltersLayout extends StatelessWidget {
  const BookFiltersLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filters = Provider.of<BookFilterProvider>(context);
    final hasActiveFilters =
        filters.selectedAuthors.isNotEmpty ||
        filters.selectedPublishers.isNotEmpty ||
        filters.selectedTags.isNotEmpty;

    return Visibility(
      visible: filters.isFilterMenuVisible,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasActiveFilters) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'Filtros activos:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  ...filters.selectedAuthors.map((author) {
                    return Chip(
                      label: Text('Autor: $author'),
                      onDeleted: () {
                        filters.removeAuthor(author);
                      },
                    );
                  }),
                  ...filters.selectedPublishers.map((publisher) {
                    return Chip(
                      label: Text('Editorial: $publisher'),
                      onDeleted: () {
                        filters.removePublisher(publisher);
                      },
                    );
                  }),
                  ...filters.selectedTags.map((tag) {
                    return Chip(
                      label: Text('Etiqueta: $tag'),
                      onDeleted: () {
                        filters.removeTag(tag);
                      },
                    );
                  }),
                ],
              ),
              const SizedBox(height: 20),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Autor',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        hint: const Text('Selecciona autores'),
                        items: filters.availableAuthors.map((author) {
                          return DropdownMenuItem<String>(
                            value: author,
                            child: Text(author),
                          );
                        }).toList(),
                        onChanged: (selectedAuthor) {
                          if (selectedAuthor != null) {
                            filters.toggleAuthor(selectedAuthor);
                          }
                        },
                        value: null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Editorial',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        hint: const Text('Selecciona editoriales'),
                        items: filters.availablePublishers.map((publisher) {
                          return DropdownMenuItem<String>(
                            value: publisher,
                            child: Text(publisher),
                          );
                        }).toList(),
                        onChanged: (selectedPublisher) {
                          if (selectedPublisher != null) {
                            filters.togglePublisher(selectedPublisher);
                          }
                        },
                        value: null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Etiqueta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        hint: const Text('Selecciona etiquetas'),
                        items: filters.availableTags.map((tag) {
                          return DropdownMenuItem<String>(
                            value: tag,
                            child: Text(tag),
                          );
                        }).toList(),
                        onChanged: (selectedTag) {
                          if (selectedTag != null) {
                            filters.toggleTag(selectedTag);
                          }
                        },
                        value: null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}