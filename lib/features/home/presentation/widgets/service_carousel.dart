import 'package:flutter/material.dart';
import 'package:urs_beauty/features/beauty_services/domain/entities/service_category_entity.dart';

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
    return _SectionShell(
      title: 'Featured services',
      subtitle: 'Pick a category and we will match you with available pros.',
      trailing: services.isEmpty ? null : '${services.length} categories',
      onViewAll: services.isEmpty ? null : onViewAll,
      child: services.isEmpty
          ? const _EmptyServicesCard()
          : SizedBox(
              height: 230,
              child: ListView.separated(
                clipBehavior: Clip.none,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: services.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final service = services[index];
                  return SizedBox(
                    width: MediaQuery.sizeOf(context).width * 0.72,
                    child: _ServiceCard(
                      service: service,
                      index: index,
                      onTap: onServiceTap == null
                          ? null
                          : () => onServiceTap!(service),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _SectionShell extends StatelessWidget {
  const _SectionShell({
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
    this.onViewAll,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final String? trailing;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF2E2420),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF78665F),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (onViewAll != null) ...[
              const SizedBox(width: 12),
              TextButton(
                onPressed: onViewAll,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF9F624F),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                child: const Text(
                  'View all',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ] else if (trailing != null) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF0E5),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  trailing!,
                  style: const TextStyle(
                    color: Color(0xFF52664F),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 14),
        child,
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service, required this.index, this.onTap});

  final ServiceCategories service;
  final int index;
  final VoidCallback? onTap;

  static const _palette = [
    Color(0xFF9F624F),
    Color(0xFF70866D),
    Color(0xFFC28A5E),
    Color(0xFF8C6F9E),
  ];

  @override
  Widget build(BuildContext context) {
    final accent = _palette[index % _palette.length];

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _NetworkImageFill(
                  imageUrl: service.iconUrl,
                  fallbackColor: accent,
                  icon: Icons.spa_rounded,
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.02),
                        Colors.black.withValues(alpha: 0.12),
                        Colors.black.withValues(alpha: 0.72),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  right: 18,
                  bottom: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.22),
                          ),
                        ),
                        child: const Text(
                          'Explore services',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        service.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (service.description.trim().isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(
                          service.description.trim(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.86),
                                height: 1.25,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NetworkImageFill extends StatelessWidget {
  const _NetworkImageFill({
    required this.imageUrl,
    required this.fallbackColor,
    required this.icon,
  });

  final String imageUrl;
  final Color fallbackColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.trim().isEmpty) {
      return _ImageFallback(color: fallbackColor, icon: icon);
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }
        return _ImageFallback(color: fallbackColor, icon: icon);
      },
      errorBuilder: (_, __, ___) {
        return _ImageFallback(color: fallbackColor, icon: icon);
      },
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({required this.color, required this.icon});

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.82), const Color(0xFF2E2420)],
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.78),
          size: 52,
        ),
      ),
    );
  }
}

class _EmptyServicesCard extends StatelessWidget {
  const _EmptyServicesCard();

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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1EA),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.spa_outlined, color: Color(0xFF9F624F)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Services will appear here as soon as they are available.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF78665F),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
