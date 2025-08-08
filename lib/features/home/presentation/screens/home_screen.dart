import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urs_beauty/features/home/presentation/bloc/home_bloc.dart';
import 'package:urs_beauty/features/home/presentation/widgets/service_carousel.dart';
import 'package:urs_beauty/features/home/presentation/widgets/greeting_header.dart';
import 'package:urs_beauty/features/home/presentation/widgets/professionals_widget.dart';
import 'package:urs_beauty/features/home/presentation/widgets/delas_banner.dart';
import 'package:urs_beauty/features/home/presentation/widgets/search_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeBloc _homeBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _homeBloc = HomeBloc(
        getProfessionals: context.read(),
        getServices: context.read(),
        getDeals: context.read(),
      )..add(LoadHomeData());
      _isInitialized = true;
    }
  }

  bool _isInitialized = false;

  @override
  void dispose() {
    _homeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _homeBloc,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GreetingHeader(),
                const SizedBox(height: 20),
                const SearchBarWidget(),
                const SizedBox(height: 20),
                BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    if (state is HomeLoadSuccess) {
                      return Column(
                        children: [
                          PromotionsBanner(deals: state.deals),
                          const SizedBox(height: 20),
                          ServicesCarousel(services: state.services),
                          const SizedBox(height: 20),
                          ProfessionalsWidget(
                            professionals: state.professionals,
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    } else if (state is HomeLoadFailure) {
                      return Center(child: Text(state.message));
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
