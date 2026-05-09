import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project/core/models/post_model.dart';
import 'package:project/core/models/user_model.dart';
import 'package:project/core/widgets/headers/app_header.dart';

class ItemScreen extends StatefulWidget {
  final PostModel post;
  final UserModel user;

  const ItemScreen({super.key, required this.post, required this.user});

  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Placeholder(),
      appBar: AppHeader.back(
        title: 'Item Details',
        onBack: () => context.pop(),
      ),
    );
  }
}
