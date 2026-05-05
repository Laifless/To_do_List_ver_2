import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/notifications.dart';
import 'core/theme.dart';
import 'providers/system_provider.dart';
import 'screens/main_scaffold.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  await NotificationService.instance.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => SystemProvider()..loadData(),
      child: const HunterApp(),
    ),
  );
}

class HunterApp extends StatelessWidget {
  const HunterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hunter System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: const MainScaffold(),
    );
  }
}   