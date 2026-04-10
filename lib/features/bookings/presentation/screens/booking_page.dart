import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urs_beauty/features/bookings/presentation/screens/my_booking.dart';
import 'package:urs_beauty/features/reviews/presentation/bloc/review_bloc.dart';
import 'package:urs_beauty/injection_container.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getit<ReviewBloc>(),
      child: const MyBookingScreen(),
    );
  }
}
