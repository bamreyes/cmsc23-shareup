import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:project/core/constants/colors.dart';
import 'package:project/core/models/post_model.dart';
import 'package:project/core/services/cloudinary_service.dart';
import 'package:project/core/widgets/headers/app_header.dart';
import 'package:project/core/widgets/buttons/primary_button.dart';
import 'package:project/core/widgets/inputs/app_text_field.dart';
import 'package:project/features/exchanges/providers/exchange_provider.dart';
import 'package:project/features/profile/providers/profile_provider.dart';

const List<String> _kDietaryTags = [
  'Vegan',
  'Halal',
  'Gluten-Free',
  'Canned',
  'Raw Ingredients',
  'Sugar-Free',
  'Others',
];

class AddItem extends StatefulWidget {
  const AddItem({super.key});

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _cloudinaryService = CloudinaryService();
  final _imagePicker = ImagePicker();

  File? _imageFile;
  List<String> _selectedTags = [];
  DateTime _expirationDate = DateTime.now().add(const Duration(days: 7));
  double? _latitude;
  double? _longitude;
  String? _locationName;

  bool _isSubmitting = false;
  bool _isLocating = false;
  String? _imageError;
  String? _nameError;
  String? _descriptionError;
  String? _tagsError;
  String? _locationError;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); 
    final picked = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
        _imageError = null;
      });
    }
  }

  void _showImageSourceSheet() {
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
                onTap: () => _pickImage(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from Gallery'),
                onTap: () => _pickImage(ImageSource.gallery),
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
      _locationError = null;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        setState(() {
          _locationError = 'Location permission denied.';
          _isLocating = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String name = 'Unknown Location';
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [
          p.street,
          p.subLocality,
          p.locality,
          p.administrativeArea,
        ].where((s) => s != null && s.isNotEmpty).toList();
        name = parts.take(3).join(', ');
      }

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationName = name;
        _locationController.text = name;
        _locationError = null;
        _isLocating = false;
      });
    } catch (e) {
      setState(() {
        _locationError = 'Failed to get location. Try again.';
        _isLocating = false;
      });
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
    bool valid = true;
    setState(() {
      _imageError = _imageFile == null ? 'Please add a photo of the item.' : null;
      _nameError = _nameController.text.trim().isEmpty ? 'Item name is required.' : null;
      _descriptionError = _descriptionController.text.trim().isEmpty
          ? 'Description is required.'
          : null;
      _tagsError = _selectedTags.isEmpty ? 'Select at least one dietary tag.' : null;
      _locationError = (_latitude == null || _longitude == null)
          ? 'Location is required. Use "Detect Location".'
          : null;
    });

    if (_imageError != null ||
        _nameError != null ||
        _descriptionError != null ||
        _tagsError != null ||
        _locationError != null) {
      valid = false;
    }
    return valid;
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
      appBar: AppHeader.back(
        title: 'Add Item',
        onBack: () => context.pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel(theme, 'Item Photo', required: true),
            const SizedBox(height: 8),
            _buildImagePicker(theme, colorScheme, borderColor),
            if (_imageError != null) _buildError(theme, _imageError!),
            const SizedBox(height: 20),

            _buildLabel(theme, 'Item Name', required: true),
            const SizedBox(height: 8),
            AppTextField(
              controller: _nameController,
              hintText: 'Enter name',
              onChanged: (_) => setState(() => _nameError = null),
            ),
            if (_nameError != null) _buildError(theme, _nameError!),
            const SizedBox(height: 20),

            _buildLabel(theme, 'Item Description', required: true),
            const SizedBox(height: 8),
            AppTextField(
              controller: _descriptionController,
              hintText: 'Enter description',
              maxLines: 3,
              keyboardType: TextInputType.multiline,
              onChanged: (_) => setState(() => _descriptionError = null),
            ),
            if (_descriptionError != null)
              _buildError(theme, _descriptionError!),
            const SizedBox(height: 20),

            _buildDietaryTagsRow(theme, colorScheme),
            if (_tagsError != null) _buildError(theme, _tagsError!),
            const SizedBox(height: 20),

            _buildLabel(theme, 'Expiration Date', required: true),
            const SizedBox(height: 8),
            AppTextField(
              hintText: _formatDate(_expirationDate),
              readOnly: true,
              onTap: _pickExpirationDate,
              suffixIcon: Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),

            _buildLabel(theme, 'Pickup Location', required: true),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _locationController,
                    hintText: 'Add Location',
                    readOnly: true,
                    suffixIcon: Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _isLocating
                    ? const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        onPressed: _detectLocation,
                        icon: const Icon(Icons.my_location, size: 18),
                        label: const Text('Detect'),
                      ),
              ],
            ),
            if (_locationError != null) _buildError(theme, _locationError!),
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
    );
  }


  Widget _buildLabel(ThemeData theme, String label,
      {bool required = false}) {
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
              color: AppColors.danger,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _buildError(ThemeData theme, String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Text(
        message,
        style: theme.textTheme.bodySmall?.copyWith(color: AppColors.danger),
      ),
    );
  }

  Widget _buildImagePicker(
    ThemeData theme,
    ColorScheme colorScheme,
    Color borderColor,
  ) {
    return GestureDetector(
      onTap: _showImageSourceSheet,
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(
            color: _imageError != null ? AppColors.danger : borderColor,
            style: _imageFile == null ? BorderStyle.solid : BorderStyle.solid,
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
                      onTap: () => setState(() => _imageFile = null),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 18),
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

  Widget _buildDietaryTagsRow(ThemeData theme, ColorScheme colorScheme) {
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
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (selected) {
                    _selectedTags.remove(tag);
                  } else {
                    _selectedTags.add(tag);
                  }
                  _tagsError = null;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color:
                      selected ? AppColors.primary500 : colorScheme.surface,
                  border: Border.all(
                    color: selected
                        ? AppColors.primary500
                        : AppColors.neutral300,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tag,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: selected ? Colors.white : colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}