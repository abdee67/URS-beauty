import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  static const _clay = Color(0xFF9F624F);
  static const _paper = Color(0xFFFFF8F2);

  @override
  void initState() {
    super.initState();
    Future.microtask(_refreshHomeData);
  }

  Future<void> _refreshHomeData() async {
    if (!mounted) {
      return;
    }
    context.read<HomeBloc>().add(LoadHomeData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _paper,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFEFE6), Color(0xFFFFF9F4), Color(0xFFF7EFE6)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              return RefreshIndicator(
                color: _clay,
                backgroundColor: Colors.white,
                onRefresh: _refreshHomeData,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const _HomeHero(),
                          const SizedBox(height: 16),
                          _SearchPill(
                            onTap: () => context.push(AppRoutes.searchScreen),
                          ),
                          const SizedBox(height: 22),
                          if (state is HomeLoading) ...[
                            const _LoadingSection(),
                          ] else if (state is HomeLoadFailure) ...[
                            _HomeErrorState(
                              message: state.message,
                              onRetry: _refreshHomeData,
                            ),
                          ] else if (state is HomeLoadSuccess) ...[
                            PromotionsBanner(deals: state.deals),
                            if (state.deals.isNotEmpty)
                              const SizedBox(height: 22),
                            ServicesCarousel(
                              services: state.services,
                              onServiceTap: _openCategoryServices,
                              onViewAll: _openAllServices,
                            ),
                            const SizedBox(height: 24),
                            StylistsWidget(
                              stylists: state.stylists,
                              onStylistTap: _openStylistProfile,
                            ),
                            const SizedBox(height: 36),
                          ] else ...[
                            const _LoadingSection(),
                          ],
                        ]),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
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

class _HomeHero extends StatelessWidget {
  const _HomeHero();

  static const _ink = Color(0xFF2E2420);
  static const _muted = Color(0xFF78665F);
  static const _clay = Color(0xFF9F624F);
  static const _rose = Color(0xFFE9B7A6);
  static const _sage = Color(0xFF70866D);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.84)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _sage.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: _sage.withValues(alpha: 0.16)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_timeIcon(), color: _sage, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Good ${_timeGreeting()}',
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_rose, _clay]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.spa_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Find beauty care that comes to you',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: _ink,
              fontWeight: FontWeight.w900,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Book trusted stylists, compare services, and pay after the appointment is complete.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _muted,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: const [
              _TrustChip(icon: Icons.verified_rounded, label: 'Verified pros'),
              SizedBox(width: 8),
              _TrustChip(icon: Icons.payments_rounded, label: 'Pay after'),
            ],
          ),
        ],
      ),
    );
  }

  static String _timeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

  static IconData _timeIcon() {
    final hour = DateTime.now().hour;
    if (hour < 12) return Icons.wb_sunny_rounded;
    if (hour < 17) return Icons.light_mode_rounded;
    return Icons.nights_stay_rounded;
  }
}

class _TrustChip extends StatelessWidget {
  const _TrustChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3EC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF3D7CA)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF9F624F)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF4B332C),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchPill extends StatelessWidget {
  const _SearchPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFF0D6C9)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: Color(0xFF9F624F)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Search services or stylists',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF7A6258),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.tune_rounded,
                color: Color(0xFF70866D),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingSection extends StatelessWidget {
  const _LoadingSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _SkeletonBox(height: 150),
        SizedBox(height: 18),
        _SkeletonBox(height: 220),
        SizedBox(height: 18),
        _SkeletonBox(height: 260),
      ],
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.84)),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: Color(0xFF9F624F),
        ),
      ),
    );
  }
}

class _HomeErrorState extends StatelessWidget {
  const _HomeErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0D6C9)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: Color(0xFF9F624F),
            size: 42,
          ),
          const SizedBox(height: 12),
          Text(
            'Could not load home',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Color(0xFF2E2420),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF78665F)),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9F624F),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
