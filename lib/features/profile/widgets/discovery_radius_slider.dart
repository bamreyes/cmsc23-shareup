import 'package:flutter/material.dart';
import 'package:project/core/constants/colors.dart';
import 'package:project/features/profile/providers/profile_provider.dart';
import 'package:provider/provider.dart';

class DiscoveryRadiusSlider extends StatefulWidget {
  final double? initialRadius;
  final Function(double)? onChanged;
  final Function(double)? onChangeEnd;

  const DiscoveryRadiusSlider({
    super.key,
    this.initialRadius,
    this.onChanged,
    this.onChangeEnd,
  });

  @override
  State<DiscoveryRadiusSlider> createState() => _DiscoveryRadiusSliderState();
}

class _DiscoveryRadiusSliderState extends State<DiscoveryRadiusSlider> {
  double? _dragValue;
  late double _currentRadius;

  @override
  void initState() {
    super.initState();
    _currentRadius =
        widget.initialRadius ??
        context.read<ProfileProvider>().currentUser?.discoveryRadius ??
        20.0;
  }

  @override
  Widget build(BuildContext context) {
    final displayValue = _dragValue ?? _currentRadius;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    final cardBgColor = isDark ? AppColors.neutral900 : colorScheme.surface;
    final borderColor = isDark ? AppColors.neutral800 : AppColors.grey200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Discovery Radius',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: cardBgColor,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    displayValue.round().toString(),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary500,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'km',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.brightness == Brightness.dark
                          ? AppColors.neutral400
                          : AppColors.neutral500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),

              Slider(
                value: displayValue,
                max: 50,
                min: 0,
                divisions: 50,
                onChanged: (double value) {
                  setState(() {
                    _dragValue = value;
                  });
                  widget.onChanged?.call(value);
                },
                onChangeEnd: (double value) {
                  setState(() {
                    _currentRadius = value;
                    _dragValue = null;
                  });
                  widget.onChangeEnd?.call(value);
                },
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '0 km',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.brightness == Brightness.dark
                            ? AppColors.neutral500
                            : AppColors.neutral400,
                      ),
                    ),
                    Text(
                      '50 km',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.brightness == Brightness.dark
                            ? AppColors.neutral500
                            : AppColors.neutral400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
