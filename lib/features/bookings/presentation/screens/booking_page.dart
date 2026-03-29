import 'package:flutter/material.dart';
import 'package:urs_beauty/features/beauty_services/presentation/screens/service_list_screen.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  @override
  Widget build(BuildContext context) {
    return const ServiceListScreen();
  }
}
