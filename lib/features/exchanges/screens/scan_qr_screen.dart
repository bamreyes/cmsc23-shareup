import 'package:flutter/material.dart';
import 'package:project/core/widgets/headers/app_header.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader.back(title: 'Scan QR Code'),
      body: Placeholder(),
    );
  }
}
