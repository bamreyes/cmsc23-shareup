import 'package:flutter/material.dart';
import 'package:project/core/models/post_model.dart';

class ItemRequest extends StatefulWidget {
  final PostModel post;

  const ItemRequest({super.key, required this.post});

  @override
  State<ItemRequest> createState() => _ItemRequestState();
}

class _ItemRequestState extends State<ItemRequest> {
  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}
