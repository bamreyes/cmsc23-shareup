import 'package:flutter/material.dart';
import 'package:project/core/widgets/headers/app_header.dart';

class ExchangesScreen extends StatelessWidget {
  const ExchangesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader.title(title: 'Exchanges'),
      body: Center(
        child: Text(
          'Exchanges',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
