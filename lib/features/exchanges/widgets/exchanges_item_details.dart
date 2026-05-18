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
import 'package:project/core/services/database_service.dart';
import 'package:project/core/widgets/buttons/primary_button.dart';
import 'package:project/core/widgets/inputs/app_text_field.dart';
import 'package:project/features/exchanges/providers/exchange_provider.dart';

const List<String> _kDietaryTags = [
  'Vegan',
  'Halal',
  'Gluten-Free',
  'Canned',
  'Raw Ingredients',
  'Sugar-Free',
  'Others',
];

class ItemDetails extends StatefulWidget {
  final PostModel post;

  const ItemDetails({super.key, required this.post});

  @override
  State<ItemDetails> createState() => _ItemDetailsState();
}

class _ItemDetailsState extends State<ItemDetails> {
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

  bool _isEditing = false;
  bool _isSaving = false;
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
      widget.post.status == PostStatus.completed;

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
                  'Change Photo',
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

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    final picked = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      setState(() => _newImageFile = File(picked.path));
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
            const SnackBar(content: Text('Location permission denied.')),
          );
        }
        setState(() => _isLocating = false);
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
          const SnackBar(content: Text('Failed to get location. Try again.')),
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
    if (picked != null) setState(() => _expirationDate = picked);
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        _selectedTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    String imageUrl = widget.post.image;

    // upload new image if user changed it
    if (_newImageFile != null) {
      final uploadResult = await _cloudinaryService.uploadFile(_newImageFile!);
      if (!uploadResult.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image upload failed: ${uploadResult.error}'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
        setState(() => _isSaving = false);
        return;
      }
      imageUrl = uploadResult.data!;
    }

    final updates = {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'image': imageUrl,
      'dietaryTags': _selectedTags,
      'expirationDate': _expirationDate.toIso8601String(),
      'latitude': _latitude,
      'longitude': _longitude,
      'locationName': _locationName,
    };

    final db = DatabaseService();
    final result = await db.updatePost(widget.post.id!, updates);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result.isSuccess) {
      // refresh the posts list in the provider
      context.read<ExchangeProvider>().fetchMyPosts(widget.post.userId);

      setState(() {
        _isEditing = false;
        _newImageFile = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item updated successfully!'),
          backgroundColor: AppColors.primary500,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Failed to update item.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _cancelEdit() {
    setState(() {
      // reset all fields back to the original post data
      _nameController.text = widget.post.name;
      _descriptionController.text = widget.post.description;
      _locationController.text = widget.post.locationName;
      _selectedTags = List<String>.from(widget.post.dietaryTags);
      _expirationDate = widget.post.expirationDate;
      _latitude = widget.post.latitude;
      _longitude = widget.post.longitude;
      _locationName = widget.post.locationName;
      _newImageFile = null;
      _isEditing = false;
    });
  }

  // Delete
  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Item?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
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

    final db = DatabaseService();
    final result = await db.updatePost(widget.post.id!, {
      'status': PostStatus.deleted.name,
    });

    if (!mounted) return;
    setState(() => _isDeleting = false);

    if (result.isSuccess) {
      // refresh provider then go back
      context.read<ExchangeProvider>().fetchMyPosts(widget.post.userId);
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(theme, 'Item Photo', required: true),
          const SizedBox(height: 8),
          _buildImageSection(theme, borderColor),
          const SizedBox(height: 20),

          _buildLabel(theme, 'Item Name', required: true),
          const SizedBox(height: 8),
          AppTextField(
            controller: _nameController,
            hintText: 'Enter name',
            readOnly: !_isEditing,
          ),
          const SizedBox(height: 20),

          _buildLabel(theme, 'Item Description', required: true),
          const SizedBox(height: 8),
          AppTextField(
            controller: _descriptionController,
            hintText: 'Enter description',
            maxLines: 3,
            keyboardType: TextInputType.multiline,
            readOnly: !_isEditing,
          ),
          const SizedBox(height: 20),

          _buildDietaryTagsSection(theme, colorScheme),
          const SizedBox(height: 20),

          _buildLabel(theme, 'Expiration Date', required: true),
          const SizedBox(height: 8),
          AppTextField(
            hintText: _formatDate(_expirationDate),
            readOnly: true,
            onTap: _isEditing ? _pickExpirationDate : null,
            suffixIcon: Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          _buildLabel(theme, 'Location', required: true),
          const SizedBox(height: 8),
          Row(
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
              if (_isEditing) ...[
                const SizedBox(width: 10),
                _isLocating
                    ? const Padding(
                        padding: EdgeInsets.only(top: 4),
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
            ],
          ),
          const SizedBox(height: 32),

          _buildActionButtons(theme),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLabel(ThemeData theme, String label, {bool required = false}) {
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

  Widget _buildImageSection(ThemeData theme, Color borderColor) {
    final hasNewImage = _newImageFile != null;
    final existingUrl = widget.post.image;

    return GestureDetector(
      onTap: _isEditing ? _showImageSourceSheet : null,
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: hasNewImage
                  ? Image.file(_newImageFile!, fit: BoxFit.cover)
                  : (existingUrl.isNotEmpty
                        ? Image.network(
                            existingUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 48,
                                color: AppColors.neutral400,
                              ),
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 48,
                              color: AppColors.neutral400,
                            ),
                          )),
            ),
            // Edit overlay hint
            if (_isEditing)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Change Photo',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDietaryTagsSection(ThemeData theme, ColorScheme colorScheme) {
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
              onTap: _isEditing
                  ? () {
                      setState(() {
                        if (selected) {
                          _selectedTags.remove(tag);
                        } else {
                          _selectedTags.add(tag);
                        }
                      });
                    }
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary500 : colorScheme.surface,
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

  Widget _buildActionButtons(ThemeData theme) {
    // Reserved/completed posts can only be deleted, not edited
    if (_isReservedOrDone) {
      return _buildDeleteButton();
    }

    if (_isEditing) {
      return Column(
        children: [
          PrimaryButton(
            text: 'Save Changes',
            isLoading: _isSaving,
            onPressed: _isSaving ? null : _save,
          ),
          const SizedBox(height: 12),
          _buildDeleteButton(),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _cancelEdit,
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.neutral500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // View mode
    return Column(
      children: [
        PrimaryButton(
          text: 'Edit Item',
          onPressed: () => setState(() => _isEditing = true),
        ),
        const SizedBox(height: 12),
        _buildDeleteButton(),
      ],
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.danger),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          foregroundColor: AppColors.danger,
        ),
        onPressed: _isDeleting ? null : _confirmDelete,
        child: _isDeleting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: AppColors.danger,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
      ),
    );
  }
}
