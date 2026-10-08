import 'package:flutter/material.dart';
import 'package:urs_beauty/features/beauty_services/domain/entities/service_category_entity.dart';
import 'package:urs_beauty/features/stylists/presentation/widgets/section_header.dart';

class ServicesCarousel extends StatelessWidget {
  const ServicesCarousel({
    super.key,
    required this.services,
    this.onServiceTap,
    this.onViewAll,
  });

  final List<ServiceCategories> services;
  final ValueChanged<ServiceCategories>? onServiceTap;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Featured Services',
          subtitle: 'Choose from our curated collection',
          actionLabel: services.isNotEmpty ? 'View All' : null,
          onAction: onViewAll,
          badge: services.isNotEmpty ? '${services.length}+' : null,
        ),
        const SizedBox(height: 16),
        if (services.isEmpty)
          const _EmptyState()
        else
          SizedBox(
            height: 260,
            child: ListView.builder(
              clipBehavior: Clip.none,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: services.length,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemBuilder: (context, index) {
                final service = services[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 280,
                    child: _ServiceCard(
                      service: service,
                      index: index,
                      onTap: onServiceTap == null
                          ? null
                          : () => onServiceTap!(service),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}


class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service, required this.index, this.onTap});

  final ServiceCategories service;
  final int index;
  final VoidCallback? onTap;

  static const _gradients = [
    [Color(0xFF6C5CE7), Color(0xFFA855F7)],
    [Color(0xFF00B894), Color(0xFF55EFC4)],
    [Color(0xFFE17055), Color(0xFFFDCB6E)],
    [Color(0xFF0984E3), Color(0xFF74B9FF)],
    [Color(0xFF6C5CE7), Color(0xFFA8E6CF)],
  ];

  @override
  Widget build(BuildContext context) {
    final gradient = _gradients[index % _gradients.length];

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      elevation: 4,
      shadowColor: gradient[0].withValues(alpha: 0.3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF0F0F0)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradient,
                      ),
                    ),
                    child: Stack(
                      children: [
                        if (service.iconUrl.isNotEmpty)
                          Positioned.fill(
                            child: Opacity(
                              opacity: 0.1,
                              child: Image.network(
                                service.iconUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const SizedBox(),
                              ),
                            ),
                          ),
                        Center(
                          child: Icon(
                            _getServiceIcon(service.name),
                            color: Colors.white.withValues(alpha: 0.9),
                            size: 64,
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.favorite_border_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: const Color(0xFF2D3436),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Text(
                            service.description.isNotEmpty
                                ? service.description
                                : 'Professional beauty services at your doorstep',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: const Color(0xFF636E72),
                                  height: 1.3,
                                ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: gradient[0].withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Popular',
                                style: TextStyle(
                                  color: gradient[0],
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: gradient[0],
                              size: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getServiceIcon(String serviceName) {
    final name = serviceName.toLowerCase();
    if (name.contains('hair')) return Icons.face_retouching_natural_rounded;
    if (name.contains('nail')) return Icons.auto_awesome_rounded;
    if (name.contains('makeup') || name.contains('make-up')) {
      return Icons.brush_rounded;
    }
    if (name.contains('spa')) return Icons.spa_rounded;
    if (name.contains('massage')) return Icons.air_rounded;
    return Icons.auto_awesome_mosaic_rounded;
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C5CE7).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF6C5CE7).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.spa_outlined,
              color: Color(0xFF6C5CE7),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No services available yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFF2D3436),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Services will appear here as soon as they are available.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF636E72)),
          ),
        ],
      ),
    );
  }
}
