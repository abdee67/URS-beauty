import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../cubit/service_list_cubit.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late double _currentMinRating;
  late double _currentMaxPrice;

  @override
  void initState() {
    super.initState();
    final state = context.read<ServiceListCubit>().state;
    _currentMinRating = state.minRating ?? 0;
    _currentMaxPrice = state.maxPrice ?? 5000;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text('Minimum Rating'),
          Slider(
            value: _currentMinRating,
            min: 0,
            max: 5,
            divisions: 5,
            label: _currentMinRating.toStringAsFixed(1),
            onChanged: (value) => setState(() => _currentMinRating = value),
          ),
          const SizedBox(height: 16),
          const Text('Maximum Price (ETB)'),
          Slider(
            value: _currentMaxPrice,
            min: 100,
            max: 5000,
            divisions: 49,
            label: _currentMaxPrice.toStringAsFixed(0),
            onChanged: (value) => setState(() => _currentMaxPrice = value),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<ServiceListCubit>().filterServices(
                      minRating: null,
                      maxPrice: null,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    context.read<ServiceListCubit>().filterServices(
                      minRating: _currentMinRating,
                      maxPrice: _currentMaxPrice,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}