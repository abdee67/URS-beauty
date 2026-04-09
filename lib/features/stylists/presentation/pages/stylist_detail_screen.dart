import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:urs_beauty/core/constants/app_routes.dart';
import 'package:urs_beauty/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:urs_beauty/features/bookings/presentation/screens/booking_schedule_screen.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylist_entity.dart';
import 'package:urs_beauty/features/stylists/presentation/bloc/bloc/stylists_bloc.dart';
import 'package:urs_beauty/injection_container.dart';

class StylistDetailScreen extends StatefulWidget {
  const StylistDetailScreen({super.key, this.serviceId, this.serviceName});

  final String? serviceId;
  final String? serviceName;

  @override
  State<StylistDetailScreen> createState() => _StylistDetailScreenState();
}

class _StylistDetailScreenState extends State<StylistDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadStylistsForSelection();
  }

  @override
  void didUpdateWidget(covariant StylistDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.serviceId != widget.serviceId) {
      _loadStylistsForSelection();
    }
  }

  bool get _hasSelectedService => widget.serviceId?.trim().isNotEmpty == true;

  String get _serviceTitle {
    if (widget.serviceName?.trim().isNotEmpty == true) {
      return widget.serviceName!.trim();
    }
    if (_hasSelectedService) {
      return 'Selected service';
    }
    return 'Available stylists';
  }

  bool _isLoading(StylistsStatus status) {
    if (_hasSelectedService) {
      return status == StylistsStatus.stylistsByServiceLoading;
    }
    return status == StylistsStatus.stylistsLoading;
  }

  List<Stylist> _stylistsFromState(StylistsState state) {
    if (_hasSelectedService) {
      return state.stylistsByService;
    }
    return state.stylists;
  }

  void _loadStylistsForSelection() {
    final bloc = context.read<StylistsBloc>();
    final serviceId = widget.serviceId?.trim();

    if (serviceId != null && serviceId.isNotEmpty) {
      bloc.add(GetStylistsByServiceEvent(serviceId));
      return;
    }

    bloc.add(const GetStylistsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final serviceTitle = _serviceTitle;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Choose a stylist',
          style: TextStyle(color: Color(0xFF5C2E1F)),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF3E6), Color(0xFFFFDFC6)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTitle(context, serviceTitle),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<StylistsBloc, StylistsState>(
                    builder: (context, state) {
                      if (_isLoading(state.status)) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state.errorMessage.isNotEmpty) {
                        return _EmptyState(message: state.errorMessage);
                      }

                      final stylists = _stylistsFromState(state);
                      if (stylists.isEmpty) {
                        return _EmptyState(
                          message: _hasSelectedService
                              ? 'No stylists found for this service.'
                              : 'No stylists are available right now.',
                        );
                      }

                      return ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: stylists.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final stylist = stylists[index];
                          return _StylistCard(
                            stylist: stylist,
                            onTap: () => _openBookingFlow(context, stylist),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                        return;
                      }
                      context.go(AppRoutes.serviceScreen);
                    },
                    child: const Text('Back to services'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, String serviceTitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          serviceTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF5C2E1F),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'We curated stylists who can deliver this service.',
          style: TextStyle(color: Color(0xFF744534), height: 1.4),
        ),
      ],
    );
  }

  void _openBookingFlow(BuildContext context, Stylist stylist) {
    final serviceId = widget.serviceId?.trim();
    if (serviceId == null || serviceId.isEmpty) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => getit<BookingBloc>(),
          child: BookingScheduleScreen(
            serviceId: serviceId,
            serviceName: _serviceTitle,
            stylist: stylist,
          ),
        ),
      ),
    );
  }
}

class _StylistCard extends StatelessWidget {
  const _StylistCard({required this.stylist, required this.onTap});

  final Stylist stylist;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withAlpha(230),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _StylistAvatar(imageUrl: stylist.imageUrl),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stylist.businessName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2F1C18),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stylist.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          stylist.averageRating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${stylist.totalReview} reviews',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StylistAvatar extends StatelessWidget {
  const _StylistAvatar({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl.trim().isNotEmpty;
    return CircleAvatar(
      radius: 28,
      backgroundColor: const Color(0xFFF8F1EA),
      backgroundImage: hasImage ? NetworkImage(imageUrl) : null,
      child: hasImage
          ? null
          : const Icon(Icons.face_rounded, color: Color(0xFFC96A3D)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_search_rounded,
              size: 48,
              color: Color(0xFFAA7355),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
