import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:urs_beauty/core/constants/app_colors.dart';
import 'package:urs_beauty/core/constants/app_routes.dart';
import 'package:urs_beauty/features/beauty_services/domain/entities/service_category_entity.dart';
import 'package:urs_beauty/features/beauty_services/presentation/screens/service_list_screen.dart';
import 'package:urs_beauty/features/deals/presentation/widgets/delas_banner.dart';
import 'package:urs_beauty/features/home/presentation/bloc/home_bloc.dart';
import 'package:urs_beauty/features/home/presentation/widgets/service_carousel.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylist_entity.dart';
import 'package:urs_beauty/features/stylists/presentation/pages/stylist_profile_screen.dart';
import 'package:urs_beauty/features/stylists/presentation/widgets/stylists_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    Future.microtask(_refreshHomeData);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refreshHomeData() async {
    if (!mounted) return;
    context.read<HomeBloc>().add(LoadHomeData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Scrollable Content
            BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                return RefreshIndicator(
                  color: AppColors.clay,
                  backgroundColor: Colors.white,
                  onRefresh: _refreshHomeData,
                  child: AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          slivers: [
                            // Add padding for the sticky header
                            const SliverPadding(
                              padding: EdgeInsets.only(top: 80),
                              sliver: SliverToBoxAdapter(),
                            ),
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildListDelegate([
                                  const SizedBox(height: 16),
                                  _SearchBar(
                                    onTap: () =>
                                        context.push(AppRoutes.searchScreen),
                                  ),
                                  const SizedBox(height: 24),
                                  if (state is HomeLoading) ...[
                                    const _ModernLoadingSection(),
                                  ] else if (state is HomeLoadFailure) ...[
                                    _ErrorSection(
                                      message: state.message,
                                      onRetry: _refreshHomeData,
                                    ),
                                  ] else if (state is HomeLoadSuccess) ...[
                                    PromotionsBanner(deals: state.deals),
                                    if (state.deals.isNotEmpty)
                                      const SizedBox(height: 28),
                                    ServicesCarousel(
                                      services: state.services,
                                      onServiceTap: _openCategoryServices,
                                      onViewAll: _openAllServices,
                                    ),
                                    const SizedBox(height: 28),
                                    StylistsWidget(
                                      stylists: state.stylists,
                                      onStylistTap: _openStylistProfile,
                                    ),
                                    const SizedBox(height: 32),
                                  ] else ...[
                                    const _ModernLoadingSection(),
                                  ],
                                ]),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            // Sticky Header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.paper.withValues(alpha: 0.98),
                      AppColors.paper.withValues(alpha: 0.95),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.clay.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: _StickyHeader(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAllServices() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const ServiceListScreen()));
  }

  void _openCategoryServices(ServiceCategories category) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ServiceListScreen(
          categoryId: category.id,
          categoryName: category.name,
        ),
      ),
    );
  }

  void _openStylistProfile(Stylist stylist) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StylistProfileScreen(stylist: stylist),
      ),
    );
  }
}

class _StickyHeader extends StatefulWidget {
  const _StickyHeader();

  @override
  State<_StickyHeader> createState() => _StickyHeaderState();
}

class _StickyHeaderState extends State<_StickyHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'URS Beauty',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: -0.5,
                    ),
                  ),

                  Row(
                    children: [
                      // Notifications
                      Stack(
                        children: [
                          IconButton(
                            onPressed: () {
                              // Navigate to notifications
                            },
                            icon: const Icon(
                              Icons.notifications_outlined,
                              color: AppColors.clay,
                              size: 22,
                            ),
                            splashRadius: 20,
                          ),
                          Positioned(
                            top: 8,
                            right: 4,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.sage,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 4),
                      // Settings
                      IconButton(
                        onPressed: () {
                          context.read<HomeBloc>().add(LoadHomeData());
                        },
                        icon: const Icon(
                          Icons.settings_outlined,
                          color: AppColors.clay,
                        ),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                ],
              ),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getTimeIcon(), color: AppColors.sage, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Good ${_getTimeGreeting()}',
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

  IconData _getTimeIcon() {
    final hour = DateTime.now().hour;
    if (hour < 12) return Icons.wb_sunny_rounded;
    if (hour < 17) return Icons.wb_sunny_outlined;
    return Icons.nights_stay_rounded;
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: AppColors.clay.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF0D8CA)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.clay.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: AppColors.clay,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Search services or stylists...',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.sage.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.sage.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.tune_rounded, color: AppColors.sage, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Filters',
                      style: TextStyle(
                        color: AppColors.sage,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModernLoadingSection extends StatelessWidget {
  const _ModernLoadingSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Center(
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.clay.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.clay),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading amazing services...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        const _LoadingSkeleton(height: 180),
        const SizedBox(height: 16),
        const _LoadingSkeleton(height: 240),
        const SizedBox(height: 16),
        const _LoadingSkeleton(height: 280),
      ],
    );
  }
}

class _LoadingSkeleton extends StatefulWidget {
  final double height;
  const _LoadingSkeleton({required this.height});

  @override
  State<_LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<_LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey.shade200,
                Colors.grey.shade100,
                Colors.grey.shade200,
              ],
              stops: [
                _animation.value - 0.2,
                _animation.value,
                _animation.value + 0.2,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
        );
      },
    );
  }
}

class _ErrorSection extends StatelessWidget {
  const _ErrorSection({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0D8CA)),
        boxShadow: [
          BoxShadow(
            color: AppColors.clay.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.clay.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              color: AppColors.clay,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Connection Error',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.muted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text(
                'Try Again',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.clay,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
