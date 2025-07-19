import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'URS BEAUTY',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
 final _supabase = Supabase.instance.client;
  int _currentIndex = 0;
  final _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final user = _supabase.auth.currentUser;
    final userId = user?.id ?? '';
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, ${user?.email?.split('@').first ?? 'Guest'}👋',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
             const SizedBox(height: 4),
            FutureBuilder(
              future: _getDefaultAddress(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Loading address...');
                }
                return Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Delivering to: ${snapshot.data ?? 'Select location'} 📍',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            _buildSearchBar(),
            const SizedBox(height: 20),
            
            // Deals Carousel
            _buildDealsCarousel(),
            const SizedBox(height: 24),
            
            // Categories
            _buildCategoriesSection(),
            const SizedBox(height: 24),
            
            // Featured Professionals
            _buildFeaturedProfessionals(),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildSearchBar() {
    return SearchBar(
      hintText: 'Search for services...',

      leading: const Icon(Icons.search),
      elevation: WidgetStateProperty.all(0),
      onTap: () {
        // Navigate to search screen
        Navigator.pushNamed(context, '/search');
      },
      onChanged: (String value) {
        // Handle search input
        print('Search input: $value');
      },
      backgroundColor: WidgetStateProperty.all(Colors.grey[100]),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
    );
    
  }
  

  Widget _buildDealsCarousel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Deals You\'ll Love',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'See all →',
              style: TextStyle(
                color: Colors.pink,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: FutureBuilder(
            future: _getPromotions(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final deals = snapshot.data ?? [];
          return ListView.builder(
            scrollDirection: Axis.horizontal,
             padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: deals.length,
            itemBuilder: (context, index) {
              final deal = deals[index];
              return Container(
                width: 280,
                margin: EdgeInsets.only(right: index == deals.length - 1 ? 0 : 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(deal['image_url']),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deal['title'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            deal['price'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            deal['originalPrice'],
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => _navigateToService(deal['service_Id']),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.pink,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Book Now'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
            },
        ),
      ),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Service categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'See all →',
              style: TextStyle(
                color: Colors.pink,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
           child: FutureBuilder(
            future: _getCategories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final categories = snapshot.data ?? [];
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return GestureDetector(
              onTap: () => _navigateToCategory(category['id']),
                child: Container(
                  width: 80,
                  margin: EdgeInsets.only(right: index == categories.length - 1 ? 0 : 12),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                              color: _getCategoryColor(index).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getCategoryIcon(index),
                              size: 28,
                              color: _getCategoryColor(index),
                            ),
                          ),
                      const SizedBox(height: 8),
                      Text(
                        category['name'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedProfessionals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Featured Professionals',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'See all →',
              style: TextStyle(
                color: Colors.pink,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
         FutureBuilder(
          future: _getFeaturedProfessionals(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final professionals = snapshot.data ?? [];
       return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: professionals.length,
          itemBuilder: (context, index) {
            final professional = professionals[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: professional['avatar_url'] ?? '',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                       placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                          professional['business_name'] ?? 'Professional',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 16, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                (professional['avg_rating'] ?? 0.0).toStringAsFixed(1),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            professional['description'] ?? 'No description available',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                professional['service_radius'] ?? '',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                          'From ${professional['min_price'] ?? 0} ETB',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FilledButton(
                       onPressed: () => _bookProfessional(professional['id']),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(80, 36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Book'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
          },
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) {
        if (index == 3) { // Chat index
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chat feature coming soon!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        setState(() => _currentIndex = index);
        _pageController.jumpToPage(index);
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.location_on_outlined),
          selectedIcon: Icon(Icons.location_on),
          label: 'Services',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_today_outlined),
          selectedIcon: Icon(Icons.calendar_today),
          label: 'Bookings',
        ),
        NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline),
          selectedIcon: Icon(Icons.chat_bubble),
          
          label: 'Chat',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Account',
        ),
      ],
    );
  }
 // Helper methods
  Color _getCategoryColor(int index) {
    final colors = [
      Colors.pink,
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.orange,
    ];
    return colors[index % colors.length];
  }

  IconData _getCategoryIcon(int index) {
    final icons = [
      Iconsax.brush,
      Iconsax.scissor,
      Iconsax.finger_cricle,
      Iconsax.health,
      Icons.spa,
    ];
    return icons[index % icons.length];
  }

  // Supabase queries
  Future<List<Map<String, dynamic>>> _getPromotions() async {
    final response = await _supabase
        .from('promotions')
        .select('*')
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .limit(3);
    return response;
  }

  Future<List<Map<String, dynamic>>> _getCategories() async {
    final response = await _supabase
        .from('service_categories')
        .select('*')
        .eq('is_active', true)
        .order('sort_order');
    return response;
  }

  Future<List<Map<String, dynamic>>> _getFeaturedProfessionals() async {
    final response = await _supabase
        .from('service_providers')
        .select('''
          id,
          business_name,
          avg_rating,
          service_radius_km,
          avatar_url,
          provider_services!inner(min_price: price)
        ''')
        .eq('is_verified', true)
        .order('avg_rating', ascending: false)
        .limit(5);
    return response;
  }

  Future<String?> _getDefaultAddress(String userId) async {
    final response = await _supabase
        .from('customer_addresses')
        .select('address_line1, city')
        .eq('user_id', userId)
        .eq('is_default', true)
        .maybeSingle();
    return response != null ? '${response['address_line1']}, ${response['city']}' : null;
  }

  // Navigation methods
  void _navigateToService(String serviceId) {
    // Implement navigation to service details
  }

  void _navigateToCategory(String categoryId) {
    // Implement navigation to category details
  }

  void _bookProfessional(String professionalId) {
    // Implement booking flow
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}