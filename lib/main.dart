import 'package:flutter/material.dart';
import 'config/supabase_config.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.init();
  runApp(const URSBEAUTY());
}

class URSBEAUTY extends StatelessWidget {
  const URSBEAUTY({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'URS BEAUTY',
      theme: ThemeData.light(),
      routerConfig: AppRouter.router,
    );
  }
}
