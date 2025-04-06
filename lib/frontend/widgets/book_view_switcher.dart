import 'package:flutter/material.dart';
import 'package:inkger/frontend/utils/book_filter_provider.dart';
import 'package:provider/provider.dart';

class BookViewSwitcher extends StatelessWidget {

  const BookViewSwitcher({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filters = Provider.of<BookFilterProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: () => filters.setGridView(true),
          icon: Icon(Icons.grid_view),
        ),
        SizedBox(width: 2),
        IconButton(
          onPressed: () => filters.setGridView(false),
          icon: Icon(Icons.list),
        ),
      ],
    );
  }
}
