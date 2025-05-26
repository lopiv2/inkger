import 'package:flutter/material.dart';
import 'package:inkger/l10n/app_localizations.dart';

enum SortCriteria { creationDate, publicationDate, author, title }

class BooksSortSelector extends StatelessWidget {
  final SortCriteria selectedCriteria;
  final bool ascending;
  final void Function(SortCriteria) onCriteriaChanged;
  final VoidCallback onToggleDirection;

  const BooksSortSelector({
    Key? key,
    required this.selectedCriteria,
    required this.ascending,
    required this.onCriteriaChanged,
    required this.onToggleDirection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DropdownButton<SortCriteria>(
          value: selectedCriteria,
          items: [
            DropdownMenuItem(
              value: SortCriteria.creationDate,
              child: Text(AppLocalizations.of(context)!.creationDate),
            ),
            DropdownMenuItem(
              value: SortCriteria.publicationDate,
              child: Text(AppLocalizations.of(context)!.publishingDate),
            ),
            DropdownMenuItem(
              value: SortCriteria.author,
              child: Text(AppLocalizations.of(context)!.author),
            ),
            DropdownMenuItem(
              value: SortCriteria.title,
              child: Text(AppLocalizations.of(context)!.title),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              onCriteriaChanged(value);
            }
          },
        ),
        IconButton(
          icon: Icon(ascending ? Icons.arrow_upward : Icons.arrow_downward),
          tooltip: ascending
              ? AppLocalizations.of(context)!.ascendingOrder
              : AppLocalizations.of(context)!.descendingOrder,
          onPressed: onToggleDirection,
        ),
      ],
    );
  }
}
