import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:urs_beauty/core/widgets/empty_state.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylist_entity.dart';
import 'package:urs_beauty/features/stylists/presentation/bloc/bloc/stylists_bloc.dart';
import 'package:urs_beauty/features/stylists/presentation/pages/stylist_profile_screen.dart';
import 'package:urs_beauty/features/stylists/presentation/widgets/service_date_time_picker.dart';
import 'package:urs_beauty/features/stylists/presentation/widgets/sort_filter_bar.dart';
import 'package:urs_beauty/features/stylists/presentation/widgets/stylist_card.dart';
import 'package:urs_beauty/features/stylists/presentation/widgets/stylist_map_view.dart';

class StylistDetailScreen extends StatefulWidget {
  const StylistDetailScreen({
    super.key,
    this.serviceId,
    this.serviceName,
    this.requestedDateTime,
  });

  final String? serviceId;
  final String? serviceName;
  final DateTime? requestedDateTime;

  @override
  State<StylistDetailScreen> createState() => _StylistDetailScreenState();
}

class _StylistDetailScreenState extends State<StylistDetailScreen> {
  DateTime? _requestedDateTime;

  @override
  void initState() {
    super.initState();
    _requestedDateTime = widget.requestedDateTime;
    _loadStylistsForSelection();
  }

  @override
  void didUpdateWidget(covariant StylistDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.serviceId != widget.serviceId ||
        oldWidget.requestedDateTime != widget.requestedDateTime) {
      _requestedDateTime = widget.requestedDateTime;
      _loadStylistsForSelection();
    }
  }

  bool get _hasSelectedService => widget.serviceId?.trim().isNotEmpty == true;

  bool get _usesRecommendations =>
      _hasSelectedService && _requestedDateTime != null;

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
    final serviceId = widget.serviceId?.trim();

    if (_usesRecommendations && serviceId != null) {
      context.read<StylistsBloc>().add(
        SearchStylistsForService(
          serviceId: serviceId,
          requestedDateTime: _requestedDateTime!,
        ),
      );
      return;
    }

    final bloc = context.read<StylistsBloc>();
    if (serviceId != null && serviceId.isNotEmpty) {
      bloc.add(GetStylistsByServiceEvent(serviceId));
      return;
    }

    bloc.add(const GetStylistsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF6),
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
            child: _usesRecommendations
                ? _buildRecommendationList(context)
                : _buildLegacyStylistList(context),
          ),
        ),
      ),
    );
  }

  Widget _buildLegacyStylistList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTitle(context, _serviceTitle),
        const SizedBox(height: 16),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              _loadStylistsForSelection();
            },
            child: BlocBuilder<StylistsBloc, StylistsState>(
              builder: (context, state) {
                if (_isLoading(state.status)) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.errorMessage.isNotEmpty) {
                  return EmptyState(
                    title: state.errorMessage,
                    subtitle: 'Please try again later.',
                  );
                }

                final stylists = _stylistsFromState(state);
                if (stylists.isEmpty) {
                  return EmptyState(
                    title: _hasSelectedService
                        ? 'No stylists found for this service.'
                        : 'No stylists are available right now.',
                    subtitle: 'Please try again later.',
                  );
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: stylists.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final stylist = stylists[index];
                    return StylistCard(
                      stylist: stylist,
                      onTap: () => _openStylistProfile(context, stylist),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationList(BuildContext context) {
    return BlocBuilder<StylistsBloc, StylistsState>(
      builder: (context, state) {
        final loaded = state.status == StylistsStatus.recomendedStylistsLoaded
            ? state
            : null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTitle(context, _serviceTitle, loadedState: loaded),
            const SizedBox(height: 16),
            Expanded(child: _buildRecommendationBody(context, state)),
          ],
        );
      },
    );
  }

  Widget _buildRecommendationBody(BuildContext context, StylistsState state) {
    if (state.status == StylistsStatus.recomendedStylistsLoading ||
        state.status == StylistsStatus.recomendedStylistsInitial) {
      return const _StylistListShimmer();
    }

    if (state.status == StylistsStatus.recomendedStylistsLoaded) {
      return _buildLoadedRecommendation(context, state);
    }

    if (state.status == StylistsStatus.recomendedStylistsEmpty) {
      return _buildEmptyRecommendation(context, state);
    }

    if (state.status == StylistsStatus.recomendedStylistsError) {
      return _buildRecommendationError(context, state);
    }

    return const SizedBox.shrink();
  }

  Widget _buildLoadedRecommendation(BuildContext context, StylistsState state) {
    if (state.isMapView) {
      return StylistMapView(
        stylists: state.sortedStylists,
        onStylistTap: (stylist) =>
            _openRecommendedStylistProfile(context, stylist),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SortFilterBar(
          currentSort: state.sortBy,
          onSortChanged: (sort) {
            context.read<StylistsBloc>().add(SortStylists(sort));
          },
        ),
        const SizedBox(height: 4),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 180) {
                context.read<StylistsBloc>().add(const LoadMoreStylists());
              }
              return false;
            },
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: state.sortedStylists.length + (state.hasMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index >= state.sortedStylists.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final stylist = state.sortedStylists[index];
                return StylistCard(
                  stylist: stylist,
                  distanceKm: stylist.distanceKm,
                  onTap: () => _openRecommendedStylistProfile(context, stylist),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyRecommendation(BuildContext context, StylistsState state) {
    return _ActionState(
      icon: Icons.event_busy_rounded,
      title:
          'No stylists available for this service in your area on ${_formatMediumDate(context, state.requestedDateTime ?? DateTime.now())}.',
      subtitle: 'Try another appointment time or choose a different service.',
      primaryLabel: 'Try a different date',
      onPrimary: () => _pickDifferentDate(context),
      secondaryLabel: 'Try a different service',
      onSecondary: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildRecommendationError(BuildContext context, StylistsState state) {
    return _ActionState(
      icon: state.isLocationError
          ? Icons.location_off_rounded
          : Icons.error_outline_rounded,
      title: state.isLocationError ? 'Location needed' : 'Could not load',
      subtitle: state.message ?? 'Failed to load stylists.',
      primaryLabel: state.isLocationError ? 'Open settings' : 'Try again',
      onPrimary: state.isLocationError
          ? Geolocator.openLocationSettings
          : _loadStylistsForSelection,
      secondaryLabel: state.isLocationError ? 'Try again' : null,
      onSecondary: state.isLocationError ? _loadStylistsForSelection : null,
    );
  }

  Future<void> _pickDifferentDate(BuildContext context) async {
    final selectedDateTime = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFFFBF6),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) => const ServiceDateTimePicker(),
    );

    if (selectedDateTime == null || !context.mounted) {
      return;
    }

    setState(() => _requestedDateTime = selectedDateTime);
    _loadStylistsForSelection();
  }

  Widget _buildTitle(
    BuildContext context,
    String serviceTitle, {
    StylistsState? loadedState,
  }) {
    final requestedDateTime = _requestedDateTime;
    final subtitle = requestedDateTime == null
        ? 'We curated stylists who can deliver this service.'
        : 'Available near you on ${_formatMediumDate(context, requestedDateTime)} at ${_formatTime(context, requestedDateTime)}.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                serviceTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5C2E1F),
                ),
              ),
            ),
            if (loadedState != null)
              IconButton(
                tooltip: loadedState.isMapView ? 'Show list' : 'Show map',
                onPressed: () {
                  context.read<StylistsBloc>().add(const ToggleMapView());
                },
                icon: Icon(
                  loadedState.isMapView
                      ? Icons.view_list_rounded
                      : Icons.map_rounded,
                  color: const Color(0xFF6B3F32),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF744534), height: 1.4),
        ),
      ],
    );
  }

  void _openStylistProfile(BuildContext context, Stylist stylist) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StylistProfileScreen(
          stylist: stylist,
          serviceId: widget.serviceId,
          serviceName: widget.serviceName,
        ),
      ),
    );
  }

  void _openRecommendedStylistProfile(BuildContext context, Stylist stylist) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StylistProfileScreen(
          stylist: stylist,
          serviceId: widget.serviceId,
          serviceName: widget.serviceName,
          requestedDateTime: _requestedDateTime,
          distanceKm: stylist.distanceKm,
        ),
      ),
    );
  }

  String _formatMediumDate(BuildContext context, DateTime dateTime) {
    return MaterialLocalizations.of(context).formatMediumDate(dateTime);
  }

  String _formatTime(BuildContext context, DateTime dateTime) {
    return MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(dateTime));
  }
}

class _ActionState extends StatelessWidget {
  const _ActionState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      children: [
        const SizedBox(height: 54),
        Center(
          child: Container(
            width: 78,
            height: 78,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF0E4),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF9F624F), size: 36),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFF43261D),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF744534),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: onPrimary,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6B3F32),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(primaryLabel),
        ),
        if (secondaryLabel != null && onSecondary != null) ...[
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: onSecondary,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6B3F32),
              side: const BorderSide(color: Color(0xFFD9B7A9)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(secondaryLabel!),
          ),
        ],
      ],
    );
  }
}

class _StylistListShimmer extends StatelessWidget {
  const _StylistListShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) {
        return Container(
          height: 136,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(20),
          ),
        );
      },
    );
  }
}
