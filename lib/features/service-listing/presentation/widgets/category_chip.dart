import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urs_beauty/features/service-listing/presentation/cubit/service_list_cubit.dart';

class CategoryFilterChips extends StatelessWidget {
  const CategoryFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ServiceListCubit>();
    final state = context.watch<ServiceListCubit>().state;

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.categories.length,
        itemBuilder: (context, index) {
          final category = state.categories[index];
          final isSelected = state.selectedCategoryId == category.id;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category.name),
              selected: isSelected,
              onSelected: (selected) {
                cubit.filterServices(
                  categoryId: selected ? category.id : null,
                );
              },
            ),
          );
        },
      ),
    );
  }
}