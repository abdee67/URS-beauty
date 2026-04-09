import 'package:flutter/material.dart';
import 'package:urs_beauty/features/bookings/presentation/screens/my_booking.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  @override
  Widget build(BuildContext context) {
    return const MyBookingScreen();
  }
}
