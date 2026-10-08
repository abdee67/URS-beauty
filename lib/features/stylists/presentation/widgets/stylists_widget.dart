import 'package:flutter/material.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylist_entity.dart';
import 'package:urs_beauty/features/stylists/presentation/widgets/section_header.dart';

class StylistsWidget extends StatelessWidget {
  const StylistsWidget({super.key, required this.stylists, this.onStylistTap});

  final List<Stylist> stylists;
  final ValueChanged<Stylist>? onStylistTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Top Stylists',
          subtitle: 'Highly rated professionals near you',
          badge: stylists.isNotEmpty ? '${stylists.length} pros' : null,
        ),
        const SizedBox(height: 16),
        if (stylists.isEmpty)
          const _EmptyState()
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 620;
              final crossAxisCount = isWide ? 3 : 2;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: stylists.length,
                itemBuilder: (context, index) {
                  final stylist = stylists[index];
                  return _StylistCard(
                    stylist: stylist,
                    onTap: onStylistTap == null
                        ? null
                        : () => onStylistTap!(stylist),
                  );
                },
              );
            },
          ),
      ],
    );
  }
}

class _StylistCard extends StatelessWidget {
  const _StylistCard({required this.stylist, this.onTap});

  final Stylist stylist;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: const Color(0xFF6C5CE7).withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF0F0F0)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _StylistAvatar(imageUrl: stylist.imageUrl),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.4),
                            ],
                          ),
                        ),
                      ),
                      if (stylist.isVerified)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00B894),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00B894).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.verified_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: _RatingBadge(
                          rating: stylist.averageRating,
                          reviews: stylist.totalReview,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stylist.businessName.isNotEmpty
                              ? stylist.businessName
                              : 'Beauty Professional',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: const Color(0xFF2D3436),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Text(
                            stylist.description.isNotEmpty
                                ? stylist.description
                                : 'Professional beauty services at your doorstep',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF636E72),
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _InfoChip(
                              icon: Icons.location_on_rounded,
                              label:
                                  '${stylist.serviceRadiusKm.toStringAsFixed(0)} km',
                            ),
                            const SizedBox(width: 6),
                            _InfoChip(
                              icon: Icons.home_rounded,
                              label: 'Mobile',
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
}

class _StylistAvatar extends StatelessWidget {
  final String? imageUrl;

  const _StylistAvatar({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => const _StylistPlaceholder(),
      );
    }
    return const _StylistPlaceholder();
  }
}

class _StylistPlaceholder extends StatelessWidget {
  const _StylistPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF6C5CE7).withValues(alpha: 0.1),
      child: Center(
        child: CircleAvatar(
          radius: 30,
          backgroundColor: const Color(0xFF6C5CE7).withValues(alpha: 0.2),
          child: const Icon(
            Icons.person_rounded,
            color: Color(0xFF6C5CE7),
            size: 30,
          ),
        ),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double rating;
  final int reviews;

  const _RatingBadge({required this.rating, required this.reviews});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFFDCB6E), size: 14),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: Color(0xFF2D3436),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (reviews > 0) ...[
            const SizedBox(width: 2),
            Text(
              '($reviews)',
              style: TextStyle(
                color: const Color(0xFF636E72).withValues(alpha: 0.7),
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF6C5CE7).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF6C5CE7), size: 12),
            const SizedBox(width: 2),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF6C5CE7),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
              Icons.people_outline_rounded,
              color: Color(0xFF6C5CE7),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No stylists available',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFF2D3436),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Professional stylists will appear here once they join.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF636E72),
            ),
          ),
        ],
      ),
    );
  }
}