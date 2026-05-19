import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:project/features/notifications/providers/notification_provider.dart';

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
      shape: backgroundColor == Colors.transparent ? Border() : null,
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
      title: Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: Column(
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
    VoidCallback? onNotificationPressed,
    PreferredSizeWidget? bottom,
  }) {
    return AppHeader(
      centerTitle: true,
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

  factory AppHeader.titleOnly({required String title}) {
    return AppHeader(
      centerTitle: true,
      title: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  factory AppHeader.back({
    required String title,
    VoidCallback? onBack,
    List<Widget>? actions,
    PreferredSizeWidget? bottom,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return AppHeader(
      centerTitle: true,
      backgroundColor: backgroundColor,
      leading: _CircleIconButton(icon: Icons.arrow_back, onPressed: onBack),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      actions: actions,
      bottom: bottom,
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
    final uid = FirebaseAuth.instance.currentUser?.uid;

    Widget iconWidget = Icon(
      icon,
      color: Theme.of(context).colorScheme.onSurface,
      size: 24,
    );

    if (icon == Icons.notifications_none_outlined && uid != null) {
      iconWidget = StreamBuilder<int>(
        stream: context.read<NotificationProvider>().streamUnreadCount(uid),
        builder: (context, snapshot) {
          final count = snapshot.data ?? 0;
          if (count == 0) {
            return Icon(
              icon,
              color: Theme.of(context).colorScheme.onSurface,
              size: 24,
            );
          }
          return Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.onSurface,
                size: 24,
              ),
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: AppColors.error500,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
                ),
              ),
            ],
          );
        },
      );
    }

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
          icon: iconWidget,
          onPressed:
              onPressed ??
              () {
                if (icon == Icons.notifications_none_outlined) {
                  context.push('/notifications');
                } else {
                  context.pop();
                }
              },
        ),
      ),
    );
  }
}
