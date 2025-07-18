import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/models/service.dart';
import 'package:urs_beauty/screens/service_card_screen.dart';

class CategoryDetailsScreen extends StatefulWidget {
  
  final String categoryName;
  final Color categoryColor;
  final IconData categoryIcon;

  const CategoryDetailsScreen({
    super.key,
    required this.categoryName,
    required this.categoryColor,
    required this.categoryIcon,
  });
  @override
  State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  late Future<List<Service>> _servicesFuture;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _servicesFuture = fetchServicesByCategory(widget.categoryName);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels == 
        _scrollController.position.maxScrollExtent) {
      _loadMoreServices();
    }
  }

  Future<void> _loadMoreServices() async {
    // Implement pagination if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.categoryColor.withOpacity(0.05),
      appBar: AppBar(
        title: Text(widget.categoryName,
        style: TextStyle(color: widget.categoryColor,
        fontWeight: FontWeight.bold,
        ),),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color:widget.categoryColor),
        elevation: 0,
      ),
          body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _servicesFuture = fetchServicesByCategory(widget.categoryName);
          });
        },
 child: CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.categoryColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.categoryIcon,
                    size: 32,
                    color: widget.categoryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.categoryName} Services',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Book top-rated ${widget.categoryName.toLowerCase()} professionals',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return FutureBuilder<List<Service>>(
                future: _servicesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    log('Error fetching services: ${snapshot.error}');
                    return Center(child: Text('Error loading services'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No services found'));
                  }

                  final service = snapshot.data![index];
                  return ServiceCard(service: service);
                },
              );
            },
            childCount: 10, // Adjust based on your data
          ),
        ),
      ],
    ),
        ),
      );
  }


Future<List<Service>> fetchServicesByCategory(String categoryId) async {
  final response = await Supabase.instance.client
      .from('services')
      .select('''
        *, 
        service_categories!inner(*),
        provider_services!inner(price, is_available)
      ''')
      .eq('service_categories.id', categoryId)
      .eq('is_active', true)
      .eq('provider_services.is_available', true)
      .order('popularity_score', ascending: false);
  
  return response.map((json) => Service.fromJson(json)).toList();
}
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}