import 'package:flutter/material.dart';
import 'package:project/core/widgets/headers/app_header.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader.back(title: 'Notifications'),
      body: Placeholder(),
    );
  }
}
