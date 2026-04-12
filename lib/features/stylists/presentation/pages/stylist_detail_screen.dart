import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urs_beauty/core/widgets/empty_state.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylist_entity.dart';
import 'package:urs_beauty/features/stylists/presentation/bloc/bloc/stylists_bloc.dart';
import 'package:urs_beauty/features/stylists/presentation/pages/stylist_profile_screen.dart';
import 'package:urs_beauty/features/stylists/presentation/widgets/stylist_card.dart';

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

  //load all stylists
  void _loadAllStylists() {
    final bloc = context.read<StylistsBloc>();
    bloc.add(const GetStylistsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final serviceTitle = _serviceTitle;
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTitle(context, serviceTitle),
                const SizedBox(height: 16),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      _loadAllStylists();
                    },
                    child: BlocBuilder<StylistsBloc, StylistsState>(
                      builder: (context, state) {
                        if (_isLoading(state.status)) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
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
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final stylist = stylists[index];
                            return StylistCard(
                              stylist: stylist,
                              onTap: () =>
                                  _openStylistProfile(context, stylist),
                            );
                          },
                        );
                      },
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
}
