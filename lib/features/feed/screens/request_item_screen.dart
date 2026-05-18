import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:project/core/constants/colors.dart';
import 'package:project/core/widgets/common/loading_screen.dart';
import 'package:project/core/models/post_model.dart';
import 'package:project/core/models/request_model.dart';
import 'package:project/core/widgets/headers/app_header.dart';
import 'package:project/core/services/location_service.dart';
import 'package:project/core/widgets/inputs/app_text_field.dart';
import 'package:project/features/profile/providers/profile_provider.dart';
import 'package:project/features/feed/providers/feed_provider.dart';
import 'package:project/core/widgets/buttons/primary_button.dart';
import 'package:project/core/models/user_model.dart';
import 'package:project/features/exchanges/providers/exchange_provider.dart';
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
  String? _timeError;
  final TextEditingController _messageController = TextEditingController();
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
    final feedProvider = context.read<FeedProvider>();
    final profileProvider = context.read<ProfileProvider>();

    // Only fetch if data is missing
    if (_uploader == null) {
      await feedProvider.fetchUser(widget.post.userId);
      final user = feedProvider.getUser(widget.post.userId);

      if (user != null && mounted) {
        setState(() {
          _uploader = user;
          _uploaderName = "${user.firstName} ${user.lastName}".trim();
          if (_uploaderName.isEmpty) _uploaderName = user.username;
        });
      }
    }

    if (_distanceLabel.isEmpty) {
      final currentUser = profileProvider.currentUser;
      String distanceText = "Location unavailable";

      if (currentUser != null) {
        final dCalc = _locationService.getDistance(
          startLatitude: currentUser.latitude,
          startLongitude: currentUser.longitude,
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

  String? _getValidationError() {
    if (selectedDate == null || selectedTime == null) return null;
    final now = DateTime.now();
    final pickup = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );
    final oneHourFromNow = now.add(const Duration(hours: 1));

    if (pickup.isBefore(now)) {
      return "Selected time has already passed.";
    } else if (pickup.isBefore(oneHourFromNow)) {
      return "Selected time must at least an hour from now.";
    }
    return null;
  }

  void _validatePickupTime() {
    setState(() {
      _timeError = _getValidationError();
    });
  }

  void _handleSubmit() async {
    final freshError = _getValidationError();
    if (freshError != null) {
      setState(() => _timeError = freshError);
      return;
    }

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
    final result = await context.read<ExchangeProvider>().createRequest(
      request,
    );

    if (result.isSuccess) {
      if (mounted) {
        context.pop();
      }
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        if (result.error == "Item already reserved!") {
          setState(() => _isReserved = true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? "Failed to request item"),
              backgroundColor: AppColors.error500,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingScreen(
        title: 'Submitting request',
        subtitle: 'Sending your request to the sharer. Please wait...',
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final exchangeProvider = context.watch<ExchangeProvider>();

    final isAlreadyRequested = exchangeProvider.requests.any(
      (r) =>
          r.postId == widget.post.id &&
          (r.status == RequestStatus.pending ||
              r.status == RequestStatus.accepted),
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppHeader.back(title: 'Request', onBack: () => context.pop()),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ItemHeader(
              post: widget.post,
              user: _uploader,
              uploaderName: _uploaderName,
              distance: _distanceLabel,
            ),
            SizedBox(height: 12),
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
          child: _buildRequestButton(isAlreadyRequested),
        ),
      ),
    );
  }

  Widget _buildScheduleCard(ThemeData theme, ColorScheme colorScheme) {
    final isDark = theme.brightness == Brightness.dark;
    final cardBgColor = isDark ? AppColors.neutral900 : colorScheme.surface;
    final borderColor = isDark ? AppColors.neutral800 : AppColors.grey200;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
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
          if (_timeError != null) ...[
            SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                _timeError!,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.error,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageCard(ThemeData theme, ColorScheme colorScheme) {
    final isDark = theme.brightness == Brightness.dark;
    final cardBgColor = isDark ? AppColors.neutral900 : colorScheme.surface;
    final borderColor = isDark ? AppColors.neutral800 : AppColors.grey200;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
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

  Widget _buildRequestButton(bool isAlreadyRequested) {
    if (_isReserved) {
      return PrimaryButton(text: 'Item Already Reserved', onPressed: null);
    }
    if (isAlreadyRequested) {
      return PrimaryButton(text: 'Item Already Requested', onPressed: null);
    }
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
      setState(() {
        selectedDate = picked;
        _validatePickupTime();
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
        _validatePickupTime();
      });
    }
  }
}
