import 'package:flutter/material.dart';
import 'package:project/core/widgets/headers/app_header.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader.title(title: "Feed"),
      body: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text("Feed")],
          ),
        ),
      ),
    );
  }
}
