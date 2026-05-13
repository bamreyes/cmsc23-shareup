import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project/core/constants/colors.dart';
import 'package:project/core/models/post_model.dart';
import 'package:project/core/models/user_model.dart';
import 'package:project/core/widgets/headers/app_header.dart';
import 'package:project/features/exchanges/widgets/exchanges_item_details.dart';
import 'package:project/features/exchanges/widgets/exchanges_item_request.dart';

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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppHeader.backWithAction(
          title: 'Item Details',
          onBack: () => context.pop(),
          bottom: TabBar(
            indicatorColor: AppColors.primary500,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 3,
            labelColor: AppColors.primary500,
            unselectedLabelColor: AppColors.neutral500,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
            tabs: [
              Tab(text: "Details"),
              Tab(text: "Requests"),
            ],
          ),
          actionLabel: 'Done',
        ),
        body: TabBarView(
          children: [
            ItemDetails(post: widget.post),
            ItemRequest(post: widget.post),
          ],
        ),
      ),
    );
  }
}
