import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urs_beauty/features/service-listing/presentation/cubit/service_list_cubit.dart';
import 'package:urs_beauty/features/service-listing/presentation/widgets/filter_bottom_sheet.dart';

class SearchFilterBar extends StatelessWidget {
  const SearchFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ServiceListCubit>();
    final state = context.watch<ServiceListCubit>().state;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: SearchBar(
              hintText: 'Search services...',
              onChanged: (query) => cubit.filterServices(searchQuery: query),
              leading: const Icon(Icons.search),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (_) => const FilterBottomSheet(),
            ),
          ),
        ],
      ),
    );
  }
}