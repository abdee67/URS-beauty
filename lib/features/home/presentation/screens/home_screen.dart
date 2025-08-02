import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urs_beauty/features/home/presentation/bloc/home_bloc.dart';
import 'package:urs_beauty/features/home/presentation/widgets/featured_pros.dart';
import 'package:urs_beauty/features/home/presentation/widgets/greeting_header.dart';
import 'package:urs_beauty/features/home/presentation/widgets/professionals_widget.dart';
import 'package:urs_beauty/features/home/presentation/widgets/special_offers.dart';
import 'package:urs_beauty/features/home/presentation/widgets/search_bar.dart';
// Removed import for professionals_widget.dart as the file does not exist.

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(
        getProfessionals: context.read(),
        getServices: context.read(),
        getDeals: context.read(),
      )..add(LoadHomeData()),
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

                // The following widgets depend on state and should not be const or used here.
                // They are handled below in the BlocBuilder.
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