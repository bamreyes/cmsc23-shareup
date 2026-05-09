import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project/core/models/post_model.dart';
import 'package:project/core/models/request_model.dart';
import 'package:project/core/models/user_model.dart';
import 'package:project/core/widgets/headers/app_header.dart';

class RequestDetailsScreen extends StatefulWidget {
  final RequestModel request;
  final PostModel post;
  final UserModel postOwner;

  const RequestDetailsScreen({
    super.key,
    required this.request,
    required this.post,
    required this.postOwner,
  });

  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Placeholder(),
      appBar: AppHeader.back(
        title: 'Request Details',
        onBack: () => context.pop(),
      ),
    );
  }
}
