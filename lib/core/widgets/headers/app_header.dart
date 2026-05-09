import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottom;

  const AppHeader({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.elevation = 0,
    this.backgroundColor,
    this.bottom,
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
      bottom: bottom,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

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
          Builder(
            builder: (context) => Text(
              'Hello,',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.neutral400
                    : AppColors.neutral500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            name,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        _CircleIconButton(
          icon: Icons.notifications_none_outlined,
          onPressed: onNotificationPressed,
        ),
        SizedBox(width: 16),
      ],
    );
  }

  factory AppHeader.title({
    required String title,
    String? avatarUrl,
    VoidCallback? onNotificationPressed,
    VoidCallback? onAvatarPressed,
    PreferredSizeWidget? bottom,
  }) {
    return AppHeader(
      centerTitle: true,
      leading: _Avatar(url: avatarUrl, onPressed: onAvatarPressed),
      title: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      actions: [
        _CircleIconButton(
          icon: Icons.notifications_none_outlined,
          onPressed: onNotificationPressed,
        ),
        SizedBox(width: 16),
      ],
      bottom: bottom,
    );
  }

  factory AppHeader.back({required String title, VoidCallback? onBack}) {
    return AppHeader(
      centerTitle: true,
      leading: _CircleIconButton(icon: Icons.arrow_back, onPressed: onBack),
      title: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  factory AppHeader.close({required String title, VoidCallback? onClose}) {
    return AppHeader(
      centerTitle: true,
      leading: _CircleIconButton(icon: Icons.close, onPressed: onClose),
      title: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  factory AppHeader.backWithAction({
    required String title,
    required String actionLabel,
    VoidCallback? onBack,
    VoidCallback? onAction,
    PreferredSizeWidget? bottom,
  }) {
    return AppHeader(
      centerTitle: true,
      leading: _CircleIconButton(icon: Icons.arrow_back, onPressed: onBack),
      title: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      actions: [
        TextButton(
          onPressed: onAction,
          child: Text(
            actionLabel,
            style: TextStyle(
              color: AppColors.primary600,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(width: 8),
      ],
      bottom: bottom,
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
      padding: EdgeInsets.only(left: 16.0),
      child: GestureDetector(
        onTap: onPressed,
        child: CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.primary500,
          backgroundImage: url != null ? NetworkImage(url!) : null,
          child: url == null
              ? Icon(Icons.person, color: Colors.white, size: 24)
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.neutral900 : AppColors.neutral100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(
            icon,
            color: Theme.of(context).colorScheme.onSurface,
            size: 24,
          ),
          onPressed: onPressed ?? () => Navigator.maybePop(context),
        ),
      ),
    );
  }
}
