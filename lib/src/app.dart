import 'package:flutter/material.dart';
import 'package:veto_ai/src/features/contract_guardian/presentation/contract_guardian_home_page.dart';

class ContractGuardianApp extends StatelessWidget {
  const ContractGuardianApp({super.key});

  @override
  Widget build(BuildContext context) {
    const parchment = Color(0xFFF4EFE6);
    const ink = Color(0xFF1C1917);
    const gold = Color(0xFFC0843D);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Contract Guardian',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: parchment,
        colorScheme: ColorScheme.fromSeed(
          seedColor: gold,
          brightness: Brightness.light,
          surface: Colors.white,
        ),
        textTheme: ThemeData.light().textTheme.apply(
              bodyColor: ink,
              displayColor: ink,
            ),
      ),
      home: const ContractGuardianHomePage(),
    );
  }
}
