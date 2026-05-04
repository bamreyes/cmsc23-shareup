import 'package:flutter/material.dart';
import 'package:project/features/profile/providers/profile_provider.dart';
import 'package:provider/provider.dart';

class DiscoveryRadiusSlider extends StatefulWidget {
  final double? initialRadius;
  final Function(double)? onChanged;

  const DiscoveryRadiusSlider({super.key, this.initialRadius, this.onChanged});

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

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Discovery Radius',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            Text(
              '${displayValue.toStringAsFixed(1)} km',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        Slider(
          value: displayValue,
          max: 50,
          min: 0,
          divisions: 50,
          label: '${displayValue.toStringAsFixed(1)} km',
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
            widget.onChanged?.call(value);
          },
        ),
      ],
    );
  }
}
