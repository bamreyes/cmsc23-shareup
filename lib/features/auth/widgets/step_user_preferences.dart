import 'package:flutter/material.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import 'package:project/core/widgets/buttons/toggle_button.dart';
import 'package:project/features/auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class UserPreferences extends StatefulWidget {
  const UserPreferences({super.key});

  @override
  State<UserPreferences> createState() => _UserPreferencesState();
}

class _UserPreferencesState extends State<UserPreferences> {
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

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    _firstNameController.text = authProvider.firstName ?? "";
    _lastNameController.text = authProvider.lastName ?? "";
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void handleOnSave(String? value) {
    final authProvider = context.read<AuthProvider>();
    authProvider.updateUserPreferences(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
    );
  }

  Widget buildTags(AuthProvider authProvider) {
    final myTags = authProvider.dietaryTags;
    return FormField(
      validator: (_) => myTags.isEmpty ? 'Selection required' : null,
      autovalidateMode: AutovalidateMode.onUserInteractionIfError,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8.0,
              runSpacing: 16.0,
              children: List.generate(dietaryTags.length, (index) {
                final tag = dietaryTags[index];
                final isSelected = myTags.contains(tag);
                return ToggleButton(
                  text: tag,
                  isSelected: isSelected,
                  onPressed: () {
                    authProvider.toggleDietaryTag(tag);
                    if (state.hasError) {
                      Future.microtask(() => state.validate());
                    }
                  },
                );
              }),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                child: Text(
                  state.errorText!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppTextField(
            controller: _firstNameController,
            labelText: "First Name",
            hintText: "Enter First Name",
            keyboardType: TextInputType.name,
            autovalidateMode: AutovalidateMode.onUserInteractionIfError,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'First Name is required';
              }
              return null;
            },
            onSaved: (value) => handleOnSave(value),
          ),
          SizedBox(height: 16),
          AppTextField(
            controller: _lastNameController,
            labelText: "Last Name",
            hintText: "Enter Last name",
            keyboardType: TextInputType.name,
            autovalidateMode: AutovalidateMode.onUserInteractionIfError,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Last Name is required';
              }
              return null;
            },
            onSaved: (value) => handleOnSave(value),
          ),
          SizedBox(height: 16),
          Text("What is your dietary preference?"),
          buildTags(authProvider),
        ],
      ),
    );
  }
}
