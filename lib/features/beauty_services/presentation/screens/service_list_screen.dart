import 'package:dartz/dartz.dart' show Either;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/core/widgets/header.dart';
import 'package:urs_beauty/core/widgets/retry_button.dart';
import 'package:urs_beauty/features/beauty_services/domain/entities/service_entity.dart';
import 'package:urs_beauty/features/beauty_services/domain/usecases/get_services.dart';
import 'package:urs_beauty/features/beauty_services/presentation/widgets/service_tile.dart';
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
      body: FutureBuilder<Either<Failures, List<ServiceEntity>>>(
        future: _servicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return RetryButton(
              message: snapshot.error.toString(),
              onRetry: () => setState(_loadServices),
            );
          }

          final result = snapshot.data;
          if (result == null) {
            return RetryButton(
              message: 'Unable to load services right now.',
              onRetry: () => setState(_loadServices),
            );
          }

          return result.fold(
            (failure) => RetryButton(
              message: failure.message,
              onRetry: () => setState(_loadServices),
            ),
            (services) {
              if (services.isEmpty) {
                return RetryButton(
                  message: 'No services are available yet.',
                  onRetry: () => setState(_loadServices),
                );
              }

              return SafeArea(
                child: RefreshIndicator(
                  onRefresh: _refreshServices,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: services.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Header(
                          theme: theme,
                          title: 'Start your booking',
                          description:
                              'Pick a service first, then we will show the stylists who can take it.',
                        );
                      }

                      final service = services[index - 1];
                      return ServiceTile(
                        service: service,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => BlocProvider(
                                create: (_) {
                                  final bloc = getit<StylistsBloc>();
                                  bloc.add(
                                    GetStylistsByServiceEvent(service.id),
                                  );
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}



