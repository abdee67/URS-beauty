import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> services = [];
  bool isLoading = true;

  Future<void> fetchServices() async {
    try {
      final response = await Supabase.instance.client
          .from('services')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        services = response;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching services: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('URS Services'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    leading: CachedNetworkImage(
                      imageUrl: service['image_url'] ?? '',
                      placeholder: (_, __) => CircularProgressIndicator(),
                      errorWidget: (_, __, ___) => Icon(Icons.image),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                    title: Text(service['title'] ?? 'No title'),
                    subtitle: Text('${service['price']} ETB - ${service['duration_minutes']} mins'),
                    onTap: () {
                      // TODO: Navigate to Service Detail page
                    },
                  ),
                );
              },
            ),
    );
  }
}
