import 'package:flutter/material.dart';
import 'package:urs_beauty/features/service-listing/domain/models/service_model.dart';
import 'package:urs_beauty/features/service-listing/presentation/widgets/service_card.dart';

class ServiceGridView extends StatelessWidget {
  final List<ServiceModel> services;

  const ServiceGridView({
    super.key,
    required this.services,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return ServiceCard(service: service, isGridView: true);
      },
    );
  }
}