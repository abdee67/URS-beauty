import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urs_beauty/features/home/presentation/bloc/home_bloc.dart';
import 'package:urs_beauty/features/home/presentation/widgets/greeting_header.dart';
import 'package:urs_beauty/features/home/presentation/widgets/search_bar.dart';
import 'package:urs_beauty/features/home/presentation/widgets/category_grid.dart';
import 'package:urs_beauty/features/home/presentation/widgets/featured_pros.dart';
import 'package:urs_beauty/features/home/presentation/widgets/special_offers.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(
        getFeaturedPros: context.read(),
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
                const CustomSearchBar(),
                const SizedBox(height: 20),
                const CategoryGrid(),
                const SizedBox(height: 20),
                BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    if (state is HomeLoadSuccess) {
                      return Column(
                        children: [
                          FeaturedProsList(featuredPros: state.featuredPros),
                          const SizedBox(height: 20),
                          SpecialOffers(deals: state.deals),
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