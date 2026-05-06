import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/notifications.dart';
import 'core/theme.dart';
import 'providers/system_provider.dart';
import 'screens/main_scaffold.dart';
import 'widgets/boot_screen.dart';

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
      // AppRoot è il vero entry point: gestisce il boot fuori da MaterialApp
      // in modo che il Navigator non sia ancora attivo durante loadData().
      home: const AppRoot(),
    );
  }
}

/// Separa il ciclo di vita del boot da quello dello scaffold.
///
/// Il crash '_dependents.isEmpty is not true' accade perché `notifyListeners()`
/// viene chiamato da `loadData()` mentre il widget tree di MaterialApp sta
/// ancora costruendo il primo frame. Mettendo il Selector qui, il rebuild
/// avviene su un nodo dell'albero già stabile, senza toccare il Navigator
/// o il context di MainScaffold.
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    // Selector invece di Consumer: si ricostruisce SOLO quando isLoading cambia,
    // non a ogni notifyListeners() del provider.
    return Selector<SystemProvider, bool>(
      selector: (_, prov) => prov.isLoading,
      builder: (_, isLoading, __) {
        if (isLoading) return const BootScreen();
        return const MainScaffold();
      },
    );
  }
}
