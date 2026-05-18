import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:project/core/constants/colors.dart';
import 'package:project/core/models/post_model.dart';
import 'package:project/core/services/cloudinary_service.dart';
import 'package:project/core/services/database_service.dart';
import 'package:project/core/widgets/inputs/app_text_field.dart';
import 'package:project/core/widgets/buttons/toggle_button.dart';
import 'package:project/core/constants/dietary_tag_colors.dart';
import 'package:project/features/exchanges/providers/exchange_provider.dart';

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

class ItemDetails extends StatefulWidget {
  final PostModel post;

  const ItemDetails({super.key, required this.post});

  @override
  State<ItemDetails> createState() => ItemDetailsState();
}

class ItemDetailsState extends State<ItemDetails> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;

  final _cloudinaryService = CloudinaryService();
  final _imagePicker = ImagePicker();

  File? _newImageFile; // non-null only if user picked a new image
  late List<String> _selectedTags;
  late DateTime _expirationDate;
  late double _latitude;
  late double _longitude;
  late String _locationName;

  bool _isDeleting = false;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _initFromPost(widget.post);
  }

  void _initFromPost(PostModel post) {
    _nameController = TextEditingController(text: post.name);
    _descriptionController = TextEditingController(text: post.description);
    _locationController = TextEditingController(text: post.locationName);
    _selectedTags = List<String>.from(post.dietaryTags);
    _expirationDate = post.expirationDate;
    _latitude = post.latitude;
    _longitude = post.longitude;
    _locationName = post.locationName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // Helpers
  bool get _isReservedOrDone =>
      widget.post.status == PostStatus.reserved ||
      widget.post.status == PostStatus.completed ||
      widget.post.status == PostStatus.deleted;

  String _formatDate(DateTime date) {
    const months = [
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
                  'Change Photo',
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

  Future<void> _pickImage(
    ImageSource source,
    FormFieldState<File?> state,
  ) async {
    Navigator.pop(context);
    final picked = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      setState(() => _newImageFile = File(picked.path));
      state.didChange(_newImageFile);
    }
  }

  Future<void> _detectLocation() async {
    setState(() => _isLocating = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location permission denied.')),
          );
        }
        setState(() => _isLocating = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
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

      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _locationName = name;
          _locationController.text = name;
          _isLocating = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLocating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get location. Try again.')),
        );
      }
    }
  }

  Future<void> _pickExpirationDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expirationDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) setState(() => _expirationDate = picked);
  }

  Future<void> save() async {
    if (_isReservedOrDone) {
      context.pop();
      return;
    }

    if (_formKey.currentState?.validate() != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    String imageUrl = widget.post.image;

    // upload new image if user changed it
    if (_newImageFile != null) {
      final uploadResult = await _cloudinaryService.uploadFile(_newImageFile!);
      if (!uploadResult.isSuccess) {
        if (mounted) {
          Navigator.pop(context); // Pop loading indicator
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image upload failed: ${uploadResult.error}'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
        return;
      }
      imageUrl = uploadResult.data!;
    }

    final updates = {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'image': imageUrl,
      'dietaryTags': _selectedTags,
      'expirationDate': Timestamp.fromDate(_expirationDate),
      'latitude': _latitude,
      'longitude': _longitude,
      'locationName': _locationName,
    };

    final db = DatabaseService();
    final result = await db.updatePost(widget.post.id!, updates);

    if (!mounted) return;
    Navigator.pop(context);

    if (result.isSuccess) {
      // refresh the posts list in the provider
      context.read<ExchangeProvider>().fetchMyPosts(widget.post.userId);

      setState(() {
        _newImageFile = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item updated successfully!'),
          backgroundColor: AppColors.primary500,
        ),
      );

      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Failed to update item.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  // Delete
  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Item?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This will permanently remove the item. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.neutral500),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete',
              style: TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    _deletePost();
  }

  Future<void> _deletePost() async {
    setState(() => _isDeleting = true);

    final provider = context.read<ExchangeProvider>();
    final result = await provider.deletePost(widget.post.id!);

    if (!mounted) return;
    setState(() => _isDeleting = false);

    if (result.isSuccess) {
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Failed to delete item.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  //Build
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderColor = theme.brightness == Brightness.light
        ? AppColors.grey200
        : AppColors.neutral800;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel(theme, 'Item Photo', required: true),
            SizedBox(height: 8),
            FormField<File>(
              validator: (_) =>
                  (_newImageFile == null && widget.post.image.isEmpty)
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
                        padding: EdgeInsets.only(top: 6, left: 4),
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
              controller: _nameController,
              labelText: 'Item Name',
              hasAsterisk: true,
              hintText: 'Enter name',
              readOnly: _isReservedOrDone,
              autovalidateMode: AutovalidateMode.onUserInteractionIfError,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Item name is required.';
                }
                return null;
              },
            ),
            SizedBox(height: 20),

            AppTextField(
              controller: _descriptionController,
              labelText: 'Item Description',
              hasAsterisk: true,
              hintText: 'Enter description',
              maxLines: 3,
              keyboardType: TextInputType.multiline,
              readOnly: _isReservedOrDone,
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
                        padding: EdgeInsets.only(top: 6, left: 4),
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
              labelText: 'Expiration Date',
              hasAsterisk: true,
              hintText: _formatDate(_expirationDate),
              readOnly: true,
              onTap: _isReservedOrDone ? null : _pickExpirationDate,
              suffixIcon: Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 20),

            AppTextField(
              controller: _locationController,
              labelText: 'Pickup Location',
              hasAsterisk: true,
              hintText: 'Add Location',
              readOnly: true,
              autovalidateMode: AutovalidateMode.onUserInteractionIfError,
              validator: (value) {
                if (_latitude == 0.0 ||
                    _longitude == 0.0 ||
                    value == null ||
                    value.trim().isEmpty) {
                  return 'Location is required. Use "Detect".';
                }
                return null;
              },
              suffixIcon: _isReservedOrDone
                  ? null
                  : (_isLocating
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          )
                        : TextButton.icon(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.only(right: 12),
                            ),
                            onPressed: _detectLocation,
                            icon: Icon(Icons.my_location, size: 16),
                            label: Text(
                              'Detect',
                              style: TextStyle(fontSize: 13),
                            ),
                          )),
            ),
            SizedBox(height: 40),

            if (widget.post.status != PostStatus.deleted) ...[
              _buildDeleteButton(),
              SizedBox(height: 24),
            ],
          ],
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
    final hasNewImage = _newImageFile != null;
    final existingUrl = widget.post.image;

    return GestureDetector(
      onTap: _isReservedOrDone ? null : () => _showImageSourceSheet(state),
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
        child: (hasNewImage || existingUrl.isNotEmpty)
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: hasNewImage
                        ? Image.file(_newImageFile!, fit: BoxFit.cover)
                        : Image.network(
                            existingUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 48,
                                color: AppColors.neutral400,
                              ),
                            ),
                          ),
                  ),
                  if (!_isReservedOrDone)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _newImageFile = null;
                          });
                          state.didChange(null);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(4),
                          child: Icon(
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
                  SizedBox(height: 8),
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
            SizedBox(width: 8),
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
        SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _kDietaryTags.map((tag) {
            final selected = _selectedTags.contains(tag);
            return ToggleButton(
              text: tag,
              isSelected: selected,
              activeColor: DietaryTagColors.colorFor(tag),
              onPressed: _isReservedOrDone
                  ? () {}
                  : () {
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

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.danger),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(vertical: 14),
          foregroundColor: AppColors.danger,
        ),
        onPressed: _isDeleting ? null : _confirmDelete,
        child: _isDeleting
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: AppColors.danger,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
      ),
    );
  }
}
