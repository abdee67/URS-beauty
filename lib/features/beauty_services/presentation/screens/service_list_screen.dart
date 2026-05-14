import 'package:dartz/dartz.dart' show Either;
import 'package:flutter/material.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/core/widgets/header.dart';
import 'package:urs_beauty/core/widgets/retry_button.dart';
import 'package:urs_beauty/features/beauty_services/domain/entities/service_entity.dart';
import 'package:urs_beauty/features/beauty_services/domain/usecases/get_service_by_category.dart';
import 'package:urs_beauty/features/beauty_services/domain/usecases/get_services.dart';
import 'package:urs_beauty/features/beauty_services/presentation/screens/service_detail_screen.dart';
import 'package:urs_beauty/features/beauty_services/presentation/widgets/service_tile.dart';
import 'package:urs_beauty/injection_container.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key, this.categoryId, this.categoryName});

  final String? categoryId;
  final String? categoryName;

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  late Future<Either<Failures, List<ServiceEntity>>> _servicesFuture;

  bool get _isCategoryView => widget.categoryId?.trim().isNotEmpty == true;

  String get _title {
    if (_isCategoryView && widget.categoryName?.trim().isNotEmpty == true) {
      return widget.categoryName!.trim();
    }
    return 'All services';
  }

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  void _loadServices() {
    final categoryId = widget.categoryId?.trim();
    if (categoryId != null && categoryId.isNotEmpty) {
      _servicesFuture = getit<GetServiceByCategory>()(categoryId);
      return;
    }

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
        title: Text(_title),
        backgroundColor: const Color(0xFFFFFBF6),
        foregroundColor: const Color(0xFF2E2420),
        elevation: 0,
      ),
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
                          title: _isCategoryView
                              ? 'Services in $_title'
                              : 'Start your booking',
                          description: _isCategoryView
                              ? 'Choose the exact service you want, then review details before picking a stylist.'
                              : 'Browse every available service, review the details, then choose a stylist.',
                        );
                      }

                      final service = services[index - 1];
                      return ServiceTile(
                        service: service,
                        onTap: () => _openServiceDetail(context, service),
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

  void _openServiceDetail(BuildContext context, ServiceEntity service) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ServiceDetailScreen(service: service),
      ),
    );
  }
}
