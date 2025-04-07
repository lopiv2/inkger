import 'package:flutter/material.dart';

class FilterFields extends StatelessWidget {
  const FilterFields({
    super.key,
    required this.title,
    required this.hint,
    required this.availableFilters,
    required this.toggle,
  });

  final List<String> availableFilters;
  final void Function(String) toggle;
  final String title;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            isExpanded: true,
            hint: Text(hint),
            items:
                availableFilters.map((filter) {
                  return DropdownMenuItem<String>(
                    value: filter,
                    child: Text(filter),
                  );
                }).toList(),
            onChanged: (selected) {
              if (selected != null) {
                toggle(selected);
              }
            },
            value: null,
          ),
        ],
      ),
    );
  }
}