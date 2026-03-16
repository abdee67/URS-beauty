import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urs_beauty/features/beauty_services/domain/usecases/get_service_categories.dart';
import 'package:urs_beauty/features/deals/domain/usescases/get_deals.dart';
import 'package:urs_beauty/features/professionals/domain/usecases/get_professionals.dart';
import 'package:urs_beauty/features/home/presentation/bloc/home_bloc.dart';
import 'package:urs_beauty/features/home/presentation/widgets/service_carousel.dart';
import 'package:urs_beauty/features/home/presentation/widgets/greeting_header.dart';
import 'package:urs_beauty/features/professionals/presentation/widgets/professionals_widget.dart';
import 'package:urs_beauty/features/deals/presentation/widgets/delas_banner.dart';
import 'package:urs_beauty/features/home/presentation/widgets/search_bar.dart';
import 'package:urs_beauty/injection_container.dart';

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
        getProfessionals: getit<GetProfessionals>(),
        getServices: getit<GetServiceCategory>(),
        getDeals: getit<GetDeals>(),
      )..add(LoadHomeData());
      _isInitialized = true;
    }
  }

  bool _isInitialized = false;

@override
void initState(){
   context.read<HomeBloc>().add(LoadHomeData());
   super.initState();

}
 
  @override
  void dispose() {
    _homeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     //context.read<HomeBloc>().add(LoadHomeData());
    return  Scaffold(
        backgroundColor: Colors.grey,
        body: SafeArea(
               //bottom: false, // Allow content to flow behind the bottom nav bar  
               top:false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
                 //padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100), 
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
      );
  }
}
