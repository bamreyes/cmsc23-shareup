import 'package:flutter/material.dart';
import 'package:project/core/models/post_model.dart';

class ItemDetails extends StatefulWidget {
  final PostModel post;

  const ItemDetails({super.key, required this.post});

  @override
  State<ItemDetails> createState() => _ItemDetailsState();
}

class _ItemDetailsState extends State<ItemDetails> {
  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}
