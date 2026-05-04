import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:project/core/constants/colors.dart';
import 'package:project/core/models/post_model.dart';
import 'package:project/core/models/request_model.dart';
import 'package:project/core/services/database_service.dart';
import 'package:project/core/widgets/headers/app_header.dart';
import 'package:project/core/services/location_service.dart';
import 'package:project/core/widgets/inputs/app_text_field.dart';
import 'package:project/features/profile/providers/profile_provider.dart';
import 'package:project/core/widgets/buttons/primary_button.dart';
import 'package:project/core/models/user_model.dart';
import 'package:project/features/feed/widgets/item_header.dart';
import 'package:project/features/feed/widgets/item_image_section.dart';
import 'package:project/core/utils/date_formatter.dart';

class RequestItemScreen extends StatefulWidget {
  final PostModel post;
  final UserModel? initialUser;
  final String? initialDistance;

  const RequestItemScreen({
    super.key,
    required this.post,
    this.initialUser,
    this.initialDistance,
  });

  @override
  State<RequestItemScreen> createState() => _RequestItemScreenState();
}

class _RequestItemScreenState extends State<RequestItemScreen> {
  String _uploaderName = "";
  String _distanceLabel = "";
  UserModel? _uploader;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final TextEditingController _messageController = TextEditingController();
  final _databaseService = DatabaseService();
  final _locationService = LocationService();
  bool _isLoading = false;
  bool _isReserved = false;

  @override
  void initState() {
    super.initState();
    _isReserved = widget.post.status == PostStatus.reserved;

    // Set initial values if provided to make it load instantly
    if (widget.initialUser != null) {
      _uploader = widget.initialUser;
      _uploaderName = _uploader!.username;
      if (_uploaderName.isEmpty) _uploaderName = _uploader!.username;
    }
    if (widget.initialDistance != null) {
      _distanceLabel = widget.initialDistance!;
    }

    _initializeData();
  }

  Future<void> _initializeData() async {
    // Only fetch if data is missing
    if (_uploader == null) {
      final userResult = await _databaseService.getUserById(widget.post.userId);
      if (userResult.isSuccess && userResult.data != null) {
        final user = userResult.data!;
        if (mounted) {
          setState(() {
            _uploader = user;
            _uploaderName = "${user.firstName} ${user.lastName}".trim();
            if (_uploaderName.isEmpty) _uploaderName = user.username;
          });
        }
      }
    }

    if (_distanceLabel.isEmpty) {
      final locResult = await _locationService.getCurrentLocation();
      String distanceText = "Location unavailable";

      if (locResult.isSuccess && locResult.data != null) {
        final dCalc = _locationService.getDistance(
          startLatitude: locResult.data!.latitude,
          startLongitude: locResult.data!.longitude,
          endLatitude: widget.post.latitude,
          endLongitude: widget.post.longitude,
        );
        distanceText = "${dCalc.data?.toStringAsFixed(1) ?? "0.0"} km away";
      }

      if (mounted) {
        setState(() {
          _distanceLabel = distanceText;
        });
      }
    }
  }

  void _handleSubmit() async {
    if (selectedDate == null || selectedTime == null) {
      return;
    }

    setState(() => _isLoading = true);
    final profile = context.read<ProfileProvider>();

    final pickup = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );
    final request = RequestModel(
      postId: widget.post.id!,
      requesterId: profile.userId ?? "",
      pickupDatetime: pickup,
      message: _messageController.text,
      status: RequestStatus.pending,
      createdAt: DateTime.now(),
    );
    final result = await _databaseService.createRequest(request);

    if (result.isSuccess) {
      if (mounted) {
        context.pop();
      }
    } else {
      setState(() {
        _isLoading = false;
        if (result.error == "Item already reserved") {
          _isReserved = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppHeader.back(title: 'Request', onBack: () => context.pop()),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ItemHeader(
              post: widget.post,
              user: _uploader,
              uploaderName: _uploaderName,
              distance: _distanceLabel,
            ),
            SizedBox(height: 20),
            ItemImageSection(post: widget.post),
            SizedBox(height: 24),
            _buildScheduleCard(theme, colorScheme),
            SizedBox(height: 16),
            _buildMessageCard(theme, colorScheme),
            SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: _isReserved
              ? _buildReservedBanner(theme)
              : _buildRequestButton(),
        ),
      ),
    );
  }

  Widget _buildScheduleCard(ThemeData theme, ColorScheme colorScheme) {
    final borderColor = theme.brightness == Brightness.light
        ? AppColors.grey200
        : AppColors.neutral800;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Pickup Schedule",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.neutral400,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Date",
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 8),
                    AppTextField(
                      hintText: selectedDate == null
                          ? "Select Date"
                          : DateFormatter.formatDateShort(selectedDate!),
                      readOnly: true,
                      onTap: _selectDate,
                      suffixIcon: Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Time",
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 8),
                    AppTextField(
                      hintText: selectedTime == null
                          ? "Select Time"
                          : selectedTime!.format(context),
                      readOnly: true,
                      onTap: _selectTime,
                      suffixIcon: Icon(
                        Icons.access_time,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(ThemeData theme, ColorScheme colorScheme) {
    final borderColor = theme.brightness == Brightness.light
        ? AppColors.grey200
        : AppColors.neutral800;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Message ",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "(Optional) ",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.neutral400,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: 12),
          AppTextField(
            controller: _messageController,
            hintText: "Hello! I would like to request for this item because...",
            maxLines: 4,
            keyboardType: TextInputType.multiline,
          ),
        ],
      ),
    );
  }

  Widget _buildReservedBanner(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Item already reserved',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppColors.statusReserved,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRequestButton() {
    return PrimaryButton(
      text: 'Request Item',
      isLoading: _isLoading,
      onPressed: _handleSubmit,
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }
}
