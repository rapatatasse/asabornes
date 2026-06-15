import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/borne_provider.dart';
import 'screens/map_screen.dart';

void main() {
  runApp(const AsaBornesApp());
}

class AsaBornesApp extends StatelessWidget {
  const AsaBornesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BorneProvider(),
      child: MaterialApp(
        title: 'ASA Bornes',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.blue,
          useMaterial3: true,
        ),
        home: const MapScreen(),
      ),
    );
  }
}
