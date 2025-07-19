import 'package:flutter/material.dart';
import 'package:urs_beauty/features/service-listing/domain/models/service_model.dart';
import 'package:urs_beauty/features/service-listing/presentation/widgets/service_card.dart';

class ServiceListView extends StatelessWidget {
  final List<ServiceModel> services;
  final ScrollController? controller;

  const ServiceListView({
    super.key,
    required this.services,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.all(16),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ServiceCard(service: service),
        );
      },
    );
  }
}