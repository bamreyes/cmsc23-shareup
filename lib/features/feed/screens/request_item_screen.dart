import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:project/core/utils/time_ago.dart';
import '../../../core/constants/colors.dart';
import '../../../core/models/post_model.dart';
import '../../../core/models/request_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/database_service.dart';
import '../../../core/widgets/headers/app_header.dart';
import '../../../core/services/location_service.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../profile/providers/profile_provider.dart';

class RequestItemScreen extends StatefulWidget {
  final PostModel post;

  const RequestItemScreen({super.key, required this.post});

  @override
  State<RequestItemScreen> createState() => _RequestItemScreenState();
}

class _RequestItemScreenState extends State<RequestItemScreen> {
  String _uploaderName = "";
  String _distanceLabel = "";
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
    _initializeData();
  }

  Future<void> _initializeData() async {
    final userResult = await _databaseService.getUserById(widget.post.userId);
    String fullName = "Unknown User";

    if (userResult != null && userResult.isSuccess && userResult.data != null) {
      final user = userResult.data!;
      fullName = "${user.firstName} ${user.lastName}".trim();
      if (fullName.isEmpty) fullName = user.username;
    }

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
        _uploaderName = fullName;
        _distanceLabel = distanceText;
      });
    }
  }

  void _handleSubmit() async {
    if (selectedDate == null || selectedTime == null) {
      return;
    }

    setState(() => _isLoading = true);
    final profile = context.read<ProfileProvider>();

    final pickup = DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day, selectedTime!.hour, selectedTime!.minute);
    final request = RequestModel(
      postId: widget.post.id!, 
      requesterId: profile.userId ?? "", 
      pickupDatetime: pickup,
      message: _messageController.text, 
      status: RequestStatus.pending, 
      createdAt: DateTime.now()
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
    return Scaffold(
      appBar: AppHeader.close(title: 'Request', onClose: () => context.pop()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // _buildUploaderHeader(theme),
            // const SizedBox(height: 20),
            // _buildImageSection(theme),
            // const SizedBox(height: 24),
            // _buildScheduleCard(theme),
            // const SizedBox(height: 20),
            // _buildMessageCard(theme),
          ],
        ),
      ),


}