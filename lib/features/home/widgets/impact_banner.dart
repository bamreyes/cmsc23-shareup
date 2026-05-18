import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:project/core/constants/colors.dart';

class ImpactBanner extends StatelessWidget {
  final int postCount;
  final int requestCount;

  const ImpactBanner({
    super.key,
    required this.postCount,
    required this.requestCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary500, Color.fromARGB(255, 0, 190, 187)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary500.withValues(alpha: 0.20),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -30,
                      child: CircleAvatar(
                        radius: 75,
                        backgroundColor: Colors.amberAccent.withValues(
                          alpha: 0.12,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 20,
                      bottom: -50,
                      child: CircleAvatar(
                        radius: 65,
                        backgroundColor: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    Positioned(
                      left: -10,
                      bottom: -60,
                      child: CircleAvatar(
                        radius: 85,
                        backgroundColor: Colors.cyanAccent.withValues(
                          alpha: 0.10,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 80,
                      top: -20,
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Active on ShareUP',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Share more, waste less. Track your active listings and requests here.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.90),
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 14),

                        Row(
                          children: [
                            _buildBannerStatBadge(
                              label: 'Posts',
                              value: postCount,
                            ),
                            SizedBox(width: 10),
                            _buildBannerStatBadge(
                              label: 'Requests',
                              value: requestCount,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerStatBadge({required String label, required int value}) {
    final displayLabel = value == 1
        ? (label.endsWith('s') ? label.substring(0, label.length - 1) : label)
        : label;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Text(
        '$value $displayLabel',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
