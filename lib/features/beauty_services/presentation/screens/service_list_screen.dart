import 'package:dartz/dartz.dart' show Either;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/beauty_services/domain/entities/service_entity.dart';
import 'package:urs_beauty/features/beauty_services/domain/usecases/get_services.dart';
import 'package:urs_beauty/features/stylists/presentation/bloc/bloc/stylists_bloc.dart';
import 'package:urs_beauty/features/stylists/presentation/pages/stylist_detail_screen.dart';
import 'package:urs_beauty/injection_container.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  late Future<Either<Failures, List<ServiceEntity>>> _servicesFuture;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  void _loadServices() {
    _servicesFuture = getit<GetServices>()();
  }

  Future<void> _refreshServices() async {
    setState(_loadServices);
    await _servicesFuture;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Choose a service',
          style: TextStyle(color: Color(0xFF5C2E1F)),
        ),
      ),
      body: FutureBuilder<Either<Failures, List<ServiceEntity>>>(
        future: _servicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorView(
              message: snapshot.error.toString(),
              onRetry: () => setState(_loadServices),
            );
          }

          final result = snapshot.data;
          if (result == null) {
            return _ErrorView(
              message: 'Unable to load services right now.',
              onRetry: () => setState(_loadServices),
            );
          }

          return result.fold(
            (failure) => _ErrorView(
              message: failure.message,
              onRetry: () => setState(_loadServices),
            ),
            (services) {
              if (services.isEmpty) {
                return _EmptyView(
                  message: 'No services are available yet.',
                  onRetry: () => setState(_loadServices),
                );
              }

              return RefreshIndicator(
                onRefresh: _refreshServices,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: services.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _Header(theme: theme);
                    }

                    final service = services[index - 1];
                    return _ServiceTile(
                      service: service,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => BlocProvider(
                              create: (_) {
                                final bloc = getit<StylistsBloc>();
                                bloc.add(GetStylistsByServiceEvent(service.id));
                                return bloc;
                              },
                              child: StylistDetailScreen(
                                serviceId: service.id,
                                serviceName: service.name,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE8D8), Color(0xFFFFD3B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Start your booking',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF5C2E1F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pick a service first, then we will show the stylists who can take it.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF744534),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.service, required this.onTap});

  final ServiceEntity service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0E4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.spa_rounded, color: Color(0xFFC96A3D)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      service.description.isEmpty
                          ? 'Professional service available for booking.'
                          : service.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoChip(
                          label: _formatPrice(
                            service.minPrice,
                            service.basePrice,
                          ),
                        ),
                        _InfoChip(
                          label: _formatDuration(service.durationMinutes),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(double minPrice, double basePrice) {
    final price = minPrice > 0 ? minPrice : basePrice;
    if (price <= 0) {
      return 'Price on request';
    }
    if (minPrice > 0 && basePrice > minPrice) {
      return 'From ${price.toStringAsFixed(0)}';
    }
    return price.toStringAsFixed(0);
  }

  String _formatDuration(int? durationMinutes) {
    if (durationMinutes == null || durationMinutes <= 0) {
      return 'Flexible time';
    }
    return '$durationMinutes min';
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F1EA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 44),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 44),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Refresh')),
          ],
        ),
      ),
    );
  }
}
