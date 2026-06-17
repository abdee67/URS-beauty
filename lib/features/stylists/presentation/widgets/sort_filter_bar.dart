import 'package:flutter/material.dart';
import 'package:urs_beauty/features/stylists/presentation/bloc/bloc/stylists_bloc.dart';

class SortFilterBar extends StatelessWidget {
  const SortFilterBar({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
  });

  final SortBy currentSort;
  final ValueChanged<SortBy> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
      child: Row(
        children: SortBy.values.map((sort) {
          final selected = currentSort == sort;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_label(sort)),
              selected: selected,
              onSelected: (_) => onSortChanged(sort),
              showCheckmark: false,
              selectedColor: const Color(0xFF6B3F32),
              labelStyle: TextStyle(
                color: selected ? Colors.white : const Color(0xFF6B3F32),
                fontWeight: FontWeight.w800,
              ),
              side: const BorderSide(color: Color(0xFFD9B7A9)),
              backgroundColor: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }

  String _label(SortBy sort) {
    switch (sort) {
      case SortBy.distance:
        return 'Distance';
      case SortBy.rating:
        return 'Rating';
      case SortBy.price:
        return 'Price';
    }
  }
}
