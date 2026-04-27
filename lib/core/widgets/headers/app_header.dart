import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;

  const AppHeader({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.elevation = 0,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      leading: leading,
      actions: actions,
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: backgroundColor,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4);

  factory AppHeader.greeting({
    String? avatarUrl,
    required String name,
    VoidCallback? onNotificationPressed,
    VoidCallback? onAvatarPressed,
  }) {
    return AppHeader(
      centerTitle: false,
      leading: _Avatar(url: avatarUrl, onPressed: onAvatarPressed),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Hello,',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.neutral500,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.neutral900,
            ),
          ),
        ],
      ),
      actions: [
        _CircleIconButton(
          icon: Icons.notifications_none_outlined,
          onPressed: onNotificationPressed,
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  factory AppHeader.title({
    required String title,
    VoidCallback? onNotificationPressed,
    VoidCallback? onAvatarPressed,
  }) {
    return AppHeader(
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.neutral900,
        ),
      ),
      actions: [
        _CircleIconButton(
          icon: Icons.notifications_none_outlined,
          onPressed: onNotificationPressed,
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  factory AppHeader.back({required String title, VoidCallback? onBack}) {
    return AppHeader(
      centerTitle: true,
      leading: _CircleIconButton(icon: Icons.arrow_back, onPressed: onBack),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.neutral900,
        ),
      ),
    );
  }

  factory AppHeader.close({required String title, VoidCallback? onClose}) {
    return AppHeader(
      centerTitle: true,
      leading: _CircleIconButton(icon: Icons.close, onPressed: onClose),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.neutral900,
        ),
      ),
    );
  }

  factory AppHeader.backWithAction({
    required String title,
    required String actionLabel,
    VoidCallback? onBack,
    VoidCallback? onAction,
  }) {
    return AppHeader(
      centerTitle: true,
      leading: _CircleIconButton(icon: Icons.arrow_back, onPressed: onBack),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.neutral900,
        ),
      ),
      actions: [
        TextButton(
          onPressed: onAction,
          child: Text(
            actionLabel,
            style: const TextStyle(
              color: AppColors.primary600,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? url;
  final VoidCallback? onPressed;

  const _Avatar({this.url, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: GestureDetector(
        onTap: onPressed,
        child: CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.primary500,
          backgroundImage: url != null ? NetworkImage(url!) : null,
          child: url == null
              ? const Icon(Icons.person, color: Colors.white, size: 24)
              : null,
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _CircleIconButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(icon, color: AppColors.neutral900, size: 24),
          onPressed: onPressed ?? () => Navigator.maybePop(context),
        ),
      ),
    );
  }
}
