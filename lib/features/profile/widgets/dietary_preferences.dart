import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/features/profile/providers/profile_provider.dart';
import 'package:project/core/widgets/buttons/toggle_button.dart';

class DietaryPreferences extends StatefulWidget {
  final List<String>? initialTags;
  final Function(List<String>)? onChanged;

  const DietaryPreferences({super.key, this.initialTags, this.onChanged});

  @override
  State<DietaryPreferences> createState() => _DietaryPreferencesState();
}

class _DietaryPreferencesState extends State<DietaryPreferences> {
  List<String> _currentTags = [];

  static const List<String> dietaryTags = [
    'Vegan',
    'Vegetarian',
    'Halal',
    'Pescatarian',
    'Gluten-Free',
    'Dairy-Free',
    'Keto-Friendly',
    'Raw Ingredients',
    'Home-Cooked',
    'Baked Goods',
    'Packaged',
    'Fresh Produced',
    'Nut-Free',
    'Egg-Free',
    'Shellfish-Free',
  ];

  @override
  void initState() {
    super.initState();
    _initializeTags();
  }

  @override
  void didUpdateWidget(covariant DietaryPreferences oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTags != oldWidget.initialTags) {
      _initializeTags();
    }
  }

  void _initializeTags() {
    _currentTags = widget.initialTags != null
        ? List.from(widget.initialTags!)
        : List.from(
            context.read<ProfileProvider>().currentUser?.dietaryTags ?? [],
          );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dietary Preferences',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 8.0,
          runSpacing: 16.0,
          children: List.generate(dietaryTags.length, (index) {
            final tag = dietaryTags[index];
            final isSelected = _currentTags.contains(tag);

            return ToggleButton(
              text: tag,
              isSelected: isSelected,
              onPressed: () {
                setState(() {
                  if (isSelected && _currentTags.length > 1) {
                    _currentTags.remove(tag);
                  } else if (!isSelected) {
                    _currentTags.add(tag);
                  }
                });
                widget.onChanged?.call(_currentTags);
              },
            );
          }),
        ),
      ],
    );
  }
}
