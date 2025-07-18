import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';
import 'package:urs_beauty/screens/category_detail.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beauty App',
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
  final String username = "Sarah";
  final String deliveryAddress = "Bole, Addis Ababa";
  int _currentIndex = 0;

  final List<Map<String, dynamic>> deals = [
    {
      'title': 'Eid Offer: Hair+Makeup',
      'price': '1,299 ETB',
      'originalPrice': '1,899 ETB',
      'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRKPRlsy29SgD4B_dSkZ_iuS5Qi78a4LF-yKg&s',
    },
    {
      'title': 'Summer Glow Package',
      'price': '999 ETB',
      'originalPrice': '1,499 ETB',
      'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT28mrLSWwlRcDBl2Zxdvqg61VtDoYi_anrgA&s',
    },
    {
      'title': 'Bridal Package',
      'price': '3,999 ETB',
      'originalPrice': '5,999 ETB',
      'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT2oVm0GeQ7YwpaQ2qV-NwFc1SxMNB6d0GLKA&s',
    },
  ];

  final List<Map<String, dynamic>> categories = [
    {'name': 'Makeup', 'icon': Iconsax.brush, 'color': Colors.pink},
    {'name': 'Hair', 'icon': Iconsax.scissor, 'color': Colors.blue},
    {'name': 'Nails', 'icon': Iconsax.finger_cricle, 'color': Colors.purple},
    {'name': 'Spa', 'icon': Iconsax.health, 'color': Colors.green},
    {'name': 'Massage', 'icon': Icons.spa,'color': Colors.orange},
  ];

  final List<Map<String, dynamic>> professionals = [
    {
      'name': 'Aisha',
      'rating': 4.9,
      'services': 'Makeup Artist',
      'location': 'Bole',
      'price': 'From 299 ETB',
      'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS3O97cxUhO2MZ5MrmEFxwvc_3ux2GA2oCXyQ&s',
    },
    {
      'name': 'Marta',
      'rating': 4.7,
      'services': 'Hair Stylist',
      'location': 'Kazanches',
      'price': 'From 399 ETB',
      'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRkDTRFdtelcDdZL-L3C2oANDInCo-UV_tQRQ&s',
    },
    {
      'name': 'Selam',
      'rating': 4.8,
      'services': 'Nail Technician',
      'location': 'Megenagna',
      'price': 'From 199 ETB',
      'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT8_57blfO6i2xgwPsWPKR-oNzLfHXhZ01thA&s',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, $username👋',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Delivering to: $deliveryAddress 📍',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
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
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: deals.length,
            itemBuilder: (context, index) {
              final deal = deals[index];
              return Container(
                width: 280,
                margin: EdgeInsets.only(right: index == deals.length - 1 ? 0 : 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(deal['image']),
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
                          onPressed: () {},
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
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return GestureDetector(
                onTap: () {
                  // Navigate to category details
                      Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryDetailsScreen(
                      categoryName: category['name'],
                      categoryColor: category['color'],
                      categoryIcon: category['icon'],
                    ),
                  ),
                );
              
                },
                child: Container(
                  width: 80,
                  margin: EdgeInsets.only(right: index == categories.length - 1 ? 0 : 12),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: category['color'].withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          category['icon'],
                          size: 28,
                          color: category['color'],
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
        ListView.builder(
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
                      imageUrl: professional['image'],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
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
                            professional['name'],
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
                                professional['rating'].toString(),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            professional['services'],
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                professional['location'],
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            professional['price'],
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
                      onPressed: () {},
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
          label: 'Location',
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
}