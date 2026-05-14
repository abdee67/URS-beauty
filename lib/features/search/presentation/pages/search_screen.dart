import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urs_beauty/features/beauty_services/domain/entities/service_entity.dart';
import 'package:urs_beauty/features/beauty_services/presentation/bloc/service_bloc.dart';
import 'package:urs_beauty/features/beauty_services/presentation/bloc/service_event.dart';
import 'package:urs_beauty/features/beauty_services/presentation/bloc/service_state.dart';
import 'package:urs_beauty/features/beauty_services/presentation/screens/service_detail_screen.dart';
import 'package:urs_beauty/features/beauty_services/presentation/widgets/service_tile.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylist_entity.dart';
import 'package:urs_beauty/features/stylists/presentation/bloc/bloc/stylists_bloc.dart';
import 'package:urs_beauty/features/stylists/presentation/pages/stylist_profile_screen.dart';
import 'package:urs_beauty/features/stylists/presentation/widgets/stylist_card.dart';
import 'package:urs_beauty/injection_container.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getit<ServiceBloc>()),
        BlocProvider(create: (_) => getit<StylistsBloc>()),
      ],
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final _controller = TextEditingController();
  Timer? _debounce;
  bool _didLoadInitialData = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadInitialData) {
      return;
    }

    _didLoadInitialData = true;
    context.read<ServiceBloc>().add(FetchServices());
    context.read<StylistsBloc>().add(const GetStylistsEvent());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 320), () {
      if (!mounted) {
        return;
      }

      final query = value.trim();
      if (query.isEmpty) {
        context.read<ServiceBloc>().add(FetchServices());
        context.read<StylistsBloc>().add(const GetStylistsEvent());
        return;
      }

      context.read<ServiceBloc>().add(SearchServices(query));
      context.read<StylistsBloc>().add(SearchStylistsEvent(query));
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = _controller.text.trim();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF6),
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: const Color(0xFFFFFBF6),
        foregroundColor: const Color(0xFF2E2420),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF5ED), Color(0xFFFFFBF6)],
          ),
        ),
        child: BlocBuilder<ServiceBloc, ServiceState>(
          builder: (context, serviceState) {
            return BlocBuilder<StylistsBloc, StylistsState>(
              builder: (context, stylistState) {
                final services = query.isEmpty
                    ? serviceState.services
                    : serviceState.searchedServices;
                final stylists = query.isEmpty
                    ? stylistState.stylists
                    : stylistState.searchedStylists;
                final isLoading =
                    _isServiceLoading(serviceState.status) ||
                    _isStylistLoading(stylistState.status);

                return ListView(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _SearchField(
                      controller: _controller,
                      onChanged: _onQueryChanged,
                      onClear: () {
                        _controller.clear();
                        _onQueryChanged('');
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 18),
                    if (isLoading)
                      const _LoadingCard()
                    else if (services.isEmpty && stylists.isEmpty)
                      _EmptySearchState(query: query)
                    else ...[
                      if (services.isNotEmpty) ...[
                        _SectionHeader(
                          title: query.isEmpty
                              ? 'Popular services'
                              : 'Services',
                          count: services.length,
                        ),
                        const SizedBox(height: 12),
                        ...services.map(
                          (service) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ServiceTile(
                              service: service,
                              onTap: () => _openService(context, service),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (stylists.isNotEmpty) ...[
                        _SectionHeader(
                          title: query.isEmpty
                              ? 'Available stylists'
                              : 'Stylists',
                          count: stylists.length,
                        ),
                        const SizedBox(height: 12),
                        ...stylists.map(
                          (stylist) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: StylistCard(
                              stylist: stylist,
                              onTap: () => _openStylist(context, stylist),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  bool _isServiceLoading(ServiceStatus status) {
    return status == ServiceStatus.serviceLoading ||
        status == ServiceStatus.searchedServiceLoading;
  }

  bool _isStylistLoading(StylistsStatus status) {
    return status == StylistsStatus.stylistsLoading ||
        status == StylistsStatus.stylistSearching;
  }

  void _openService(BuildContext context, ServiceEntity service) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ServiceDetailScreen(service: service),
      ),
    );
  }

  void _openStylist(BuildContext context, Stylist stylist) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StylistProfileScreen(stylist: stylist),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF0D6C9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        autofocus: true,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search services or stylists',
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF9F624F),
          ),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFF2E2420),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0E8),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$count found',
            style: const TextStyle(
              color: Color(0xFF9F624F),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0D8CA)),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Color(0xFF9F624F)),
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final hasQuery = query.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFF0D8CA)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.manage_search_rounded,
            color: Color(0xFF9F624F),
            size: 44,
          ),
          const SizedBox(height: 12),
          Text(
            hasQuery ? 'No matches found' : 'Start searching',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFF2E2420),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hasQuery
                ? 'Try a different service name or stylist business name.'
                : 'Find exact services and trusted stylists in one place.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF78665F),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
