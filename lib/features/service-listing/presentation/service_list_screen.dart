import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urs_beauty/features/service-listing/presentation/cubit/service_list_cubit.dart';
import 'package:urs_beauty/features/service-listing/presentation/cubit/service_list_state.dart';
import 'package:urs_beauty/features/service-listing/presentation/widgets/category_chip.dart';
import 'package:urs_beauty/features/service-listing/presentation/widgets/search_filter_bar.dart';
import 'package:urs_beauty/features/service-listing/presentation/widgets/service_grid_view.dart';
import 'package:urs_beauty/features/service-listing/presentation/widgets/service_list_view.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  final _scrollController = ScrollController();
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    context.read<ServiceListCubit>().loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels == 
        _scrollController.position.maxScrollExtent) {
      // Implement pagination if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
        ],
      ),
      body: Column(
        children: [
          const SearchFilterBar(),
          const CategoryFilterChips(),
          Expanded(
            child: BlocBuilder<ServiceListCubit, ServiceListState>(
              builder: (context, state) {
                if (state.status == ServiceListStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (state.status == ServiceListStatus.error) {
                  return Center(child: Text(state.errorMessage ?? 'Error loading services'));
                }
                
                if (state.filteredServices.isEmpty) {
                  return const Center(child: Text('No services found'));
                }
                
                return RefreshIndicator(
                  onRefresh: () async => context.read<ServiceListCubit>().loadInitialData(),
                  child: _isGridView
                      ? ServiceGridView(services: state.filteredServices)
                      : ServiceListView(
                          services: state.filteredServices,
                          controller: _scrollController,
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}