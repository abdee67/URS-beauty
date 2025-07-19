import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:urs_beauty/features/service-listing/domain/models/service_model.dart';
import 'package:urs_beauty/features/service-listing/presentation/cubit/service_list_cubit.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final bool isGridView;

  const ServiceCard({
    super.key,
    required this.service,
    this.isGridView = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigate to service details
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with favorite button
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: service.imageUrl,
                      width: double.infinity,
                      height: isGridView ? 120 : 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(
                        service.isFavorite 
                            ? Icons.favorite 
                            : Icons.favorite_border,
                        color: service.isFavorite 
                            ? Colors.red 
                            : Colors.white,
                      ),
                      onPressed: () => context
                          .read<ServiceListCubit>()
                          .toggleFavorite(service.id),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                service.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(service.rating.toStringAsFixed(1)),
                  const SizedBox(width: 8),
                  Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 4),
                  Text('${service.durationMinutes} min'),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'ETB ${service.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (!isGridView) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      // Book service
                    },
                    child: const Text('Book Now'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}