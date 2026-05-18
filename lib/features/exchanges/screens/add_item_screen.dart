import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:project/core/constants/colors.dart';
import 'package:project/core/models/post_model.dart';
import 'package:project/core/services/cloudinary_service.dart';
import 'package:project/core/widgets/headers/app_header.dart';
import 'package:project/core/widgets/buttons/primary_button.dart';
import 'package:project/core/widgets/inputs/app_text_field.dart';
import 'package:project/core/widgets/buttons/toggle_button.dart';
import 'package:project/core/constants/dietary_tag_colors.dart';
import 'package:project/features/exchanges/providers/exchange_provider.dart';
import 'package:project/features/profile/providers/profile_provider.dart';

const List<String> _kDietaryTags = [
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

class AddItem extends StatefulWidget {
  const AddItem({super.key});

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _cloudinaryService = CloudinaryService();

  File? _imageFile;
  final List<String> _selectedTags = [];
  DateTime _expirationDate = DateTime.now().add(const Duration(days: 7));
  double? _latitude;
  double? _longitude;
  String? _locationName;

  bool _isSubmitting = false;
  bool _isLocating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(
    ImageSource source,
    FormFieldState<File?> state,
  ) async {
    Navigator.pop(context);
    final exchangeProvider = context.read<ExchangeProvider>();
    final result = await exchangeProvider.pickImage(source);
    if (result.isSuccess && result.data != null) {
      setState(() {
        _imageFile = result.data;
      });
      state.didChange(_imageFile);
    }
  }

  void _showImageSourceSheet(FormFieldState<File?> state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  'Add Photo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Take a Photo'),
                onTap: () => _pickImage(ImageSource.camera, state),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from Gallery'),
                onTap: () => _pickImage(ImageSource.gallery, state),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _detectLocation() async {
    setState(() {
      _isLocating = true;
    });

    final exchangeProvider = context.read<ExchangeProvider>();
    final result = await exchangeProvider.detectCurrentLocation();

    if (result.isSuccess && result.data != null) {
      final data = result.data!;
      setState(() {
        _latitude = data['latitude'] as double;
        _longitude = data['longitude'] as double;
        _locationName = data['address'] as String;
        _locationController.text = _locationName!;
        _isLocating = false;
      });
    } else {
      setState(() {
        _isLocating = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Failed to get location.'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _pickExpirationDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expirationDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _expirationDate = picked);
    }
  }

  bool _validate() {
    return _formKey.currentState?.validate() ?? false;
  }

  Future<void> _submit() async {
    if (!_validate()) return;

    setState(() => _isSubmitting = true);

    //Upload image to Cloudinary
    final uploadResult = await _cloudinaryService.uploadFile(_imageFile!);
    if (!uploadResult.isSuccess) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image upload failed: ${uploadResult.error}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
      return;
    }

    final imageUrl = uploadResult.data!;
    final userId = context.read<ProfileProvider>().userId ?? '';
    final now = DateTime.now();

    final post = PostModel(
      userId: userId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      image: imageUrl,
      expirationDate: _expirationDate,
      dietaryTags: _selectedTags,
      latitude: _latitude!,
      longitude: _longitude!,
      locationName: _locationName!,
      status: PostStatus.available,
      createdAt: now,
      updatedAt: now,
    );

    //Save to Firestore
    final result = await context.read<ExchangeProvider>().createPost(post);

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item posted successfully!'),
          backgroundColor: AppColors.primary500,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Failed to post item.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderColor = theme.brightness == Brightness.light
        ? AppColors.grey200
        : AppColors.neutral800;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppHeader.back(title: 'Add Item', onBack: () => context.pop()),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel(theme, 'Item Photo', required: true),
              const SizedBox(height: 8),
              FormField<File>(
                validator: (_) => _imageFile == null
                    ? 'Please add a photo of the item.'
                    : null,
                autovalidateMode: AutovalidateMode.onUserInteractionIfError,
                builder: (state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImagePicker(theme, colorScheme, borderColor, state),
                      if (state.hasError)
                        Padding(
                          padding: const EdgeInsets.only(top: 6, left: 4),
                          child: Text(
                            state.errorText!,
                            style: TextStyle(
                              color: theme.colorScheme.error,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              AppTextField(
                controller: _nameController,
                labelText: 'Item Name',
                hasAsterisk: true,
                hintText: 'Enter name',
                autovalidateMode: AutovalidateMode.onUserInteractionIfError,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Item name is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              AppTextField(
                controller: _descriptionController,
                labelText: 'Item Description',
                hasAsterisk: true,
                hintText: 'Enter description',
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                autovalidateMode: AutovalidateMode.onUserInteractionIfError,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              FormField<List<String>>(
                initialValue: _selectedTags,
                validator: (_) => _selectedTags.isEmpty
                    ? 'Select at least one dietary tag.'
                    : null,
                autovalidateMode: AutovalidateMode.onUserInteractionIfError,
                builder: (state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDietaryTagsRow(theme, colorScheme, state),
                      if (state.hasError)
                        Padding(
                          padding: const EdgeInsets.only(top: 6, left: 4),
                          child: Text(
                            state.errorText!,
                            style: TextStyle(
                              color: theme.colorScheme.error,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              SizedBox(height: 20),

              AppTextField(
                hintText: _formatDate(_expirationDate),
                labelText: 'Expiration Date',
                readOnly: true,
                onTap: _pickExpirationDate,
                suffixIcon: Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),

              AppTextField(
                controller: _locationController,
                labelText: 'Pickup Location',
                hasAsterisk: true,
                hintText: 'Add Location',
                readOnly: true,
                autovalidateMode: AutovalidateMode.onUserInteractionIfError,
                validator: (value) {
                  if (_latitude == null ||
                      _longitude == null ||
                      value == null ||
                      value.trim().isEmpty) {
                    return 'Location is required. Use "Detect".';
                  }
                  return null;
                },
                suffixIcon: _isLocating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    : TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.only(right: 12),
                        ),
                        onPressed: _detectLocation,
                        icon: const Icon(Icons.my_location, size: 16),
                        label: const Text(
                          'Detect',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
              ),
              const SizedBox(height: 40),

              PrimaryButton(
                text: 'Post Item',
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : _submit,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(ThemeData theme, String label, {bool required = false}) {
    final colorScheme = theme.colorScheme;
    return Row(
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (required)
          Text(
            ' *',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _buildImagePicker(
    ThemeData theme,
    ColorScheme colorScheme,
    Color borderColor,
    FormFieldState<File?> state,
  ) {
    return GestureDetector(
      onTap: () => _showImageSourceSheet(state),
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(
            color: state.hasError ? AppColors.danger : borderColor,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: _imageFile != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(_imageFile!, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _imageFile = null);
                        state.didChange(null);
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 32, color: AppColors.neutral400),
                  const SizedBox(height: 8),
                  Text(
                    'Add Image',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDietaryTagsRow(
    ThemeData theme,
    ColorScheme colorScheme,
    FormFieldState<List<String>> state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildLabel(theme, 'Dietary Tags', required: true),
            const SizedBox(width: 8),
            if (_selectedTags.isNotEmpty)
              Expanded(
                child: Text(
                  _selectedTags.join(', '),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.primary500,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _kDietaryTags.map((tag) {
            final selected = _selectedTags.contains(tag);
            return ToggleButton(
              text: tag,
              isSelected: selected,
              activeColor: DietaryTagColors.colorFor(tag),
              onPressed: () {
                setState(() {
                  if (selected) {
                    _selectedTags.remove(tag);
                  } else {
                    _selectedTags.add(tag);
                  }
                });
                state.didChange(_selectedTags);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
