import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/models/user_model.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel? user;

  const ProfileHeader({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 8),

          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary500, width: 2.5),
                ),
                child: CircleAvatar(
                  radius: 64,
                  backgroundColor: AppColors.neutral700,
                  backgroundImage:
                      (user?.profileImage != null &&
                          user!.profileImage.isNotEmpty)
                      ? NetworkImage(user!.profileImage)
                      : null,
                  child:
                      (user?.profileImage == null || user!.profileImage.isEmpty)
                      ? Icon(
                          Icons.person,
                          size: 64,
                          color: AppColors.neutral400,
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: -6,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary500,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '@${user?.username ?? 'username'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Full name
          Text(
            '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim(),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 2),
          // Email
          Text(
            user?.email ?? '',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.neutral400
                  : AppColors.neutral500,
            ),
          ),
        ],
      ),
    );
  }
}
