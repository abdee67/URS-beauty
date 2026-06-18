import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urs_beauty/features/beauty_services/domain/entities/service_entity.dart';
import 'package:urs_beauty/features/stylists/presentation/bloc/bloc/stylists_bloc.dart';
import 'package:urs_beauty/features/stylists/presentation/pages/stylist_detail_screen.dart';
import 'package:urs_beauty/features/stylists/presentation/widgets/service_date_time_picker.dart';
import 'package:urs_beauty/injection_container.dart';

class ServiceDetailScreen extends StatelessWidget {
  const ServiceDetailScreen({super.key, required this.service});

  final ServiceEntity service;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final price = _formatPrice(service.minPrice, service.basePrice);
    final duration = _formatDuration(service.durationMinutes);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF6),
      appBar: AppBar(
        title: const Text('Service details'),
        backgroundColor: const Color(0xFFFFFBF6),
        foregroundColor: const Color(0xFF2E2420),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF5ED), Color(0xFFFFFBF6)],
          ),
        ),
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
            physics: const BouncingScrollPhysics(),
            children: [
              _HeroCard(service: service),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.payments_rounded,
                      label: 'Price',
                      value: price,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.schedule_rounded,
                      label: 'Duration',
                      value: duration,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _DetailSection(
                title: 'About this service',
                body: service.description.trim().isEmpty
                    ? 'A professional beauty service delivered by verified stylists near you.'
                    : service.description.trim(),
              ),
              const SizedBox(height: 14),
              _DetailSection(
                title: 'What happens next',
                body:
                    'Choose an available stylist, pick a schedule, and confirm your booking. Payment is requested after the service is completed.',
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openStylists(context),
                  icon: const Icon(Icons.groups_2_rounded),
                  label: const Text('Choose a stylist'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9F624F),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openStylists(BuildContext context) async {
    final requestedDateTime = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFFFBF6),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) => const ServiceDateTimePicker(),
    );

    if (requestedDateTime == null || !context.mounted) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => getit<StylistsBloc>()),
          ],
          child: StylistDetailScreen(
            serviceId: service.id,
            serviceName: service.name,
            requestedDateTime: requestedDateTime,
          ),
        ),
      ),
    );
  }

  String _formatPrice(double minPrice, double basePrice) {
    final price = minPrice > 0 ? minPrice : basePrice;
    if (price <= 0) {
      return 'On request';
    }
    if (minPrice > 0 && basePrice > minPrice) {
      return 'From ${price.toStringAsFixed(0)} ETB';
    }
    return '${price.toStringAsFixed(0)} ETB';
  }

  String _formatDuration(int? durationMinutes) {
    if (durationMinutes == null || durationMinutes <= 0) {
      return 'Flexible';
    }
    return '$durationMinutes min';
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.service});

  final ServiceEntity service;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _ServiceImage(imageUrl: service.iconUrl),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.02),
                    Colors.black.withValues(alpha: 0.14),
                    Colors.black.withValues(alpha: 0.72),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22),
                      ),
                    ),
                    child: const Text(
                      'Exact service',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    service.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceImage extends StatelessWidget {
  const _ServiceImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.trim().isEmpty) {
      return const _ServiceFallback();
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const _ServiceFallback(),
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }
        return const _ServiceFallback();
      },
    );
  }
}

class _ServiceFallback extends StatelessWidget {
  const _ServiceFallback();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE9B7A6), Color(0xFF9F624F), Color(0xFF2E2420)],
        ),
      ),
      child: Center(
        child: Icon(Icons.spa_rounded, color: Colors.white, size: 64),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF0D8CA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF9F624F)),
          const SizedBox(height: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF78665F),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFF2E2420),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0D8CA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFF2E2420),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF78665F),
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
