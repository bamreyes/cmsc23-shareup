import 'package:flutter/material.dart';
import 'package:project/core/widgets/headers/app_header.dart';

class AddItem extends StatefulWidget {
  const AddItem({super.key});

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader.back(title: 'Add New Item'),
      body: Placeholder(),
    );
  }
}
