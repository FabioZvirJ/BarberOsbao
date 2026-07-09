import 'package:flutter/material.dart';
import 'package:barber_osbao/packages/design_system/organisms/app_header.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_container.dart';

class AppPage extends StatelessWidget {
  final String title;
  final Widget child;
  final String userName;
  final String userAvatarUrl;
  final String barberName;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onProfileTap;
  final bool scrollable;
  final double maxWidth;

  const AppPage({
    super.key,
    required this.title,
    required this.child,
    required this.userName,
    required this.userAvatarUrl,
    this.barberName = 'Gerência Osbao',
    this.onSearch,
    this.onProfileTap,
    this.scrollable = true,
    this.maxWidth = 1200.0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppHeader(
            userName: userName,
            userAvatarUrl: userAvatarUrl,
            barberName: barberName,
            onSearch: onSearch,
            onProfileTap: onProfileTap,
          ),
          Expanded(
            child: AppContainer(
              scrollable: scrollable,
              maxWidth: maxWidth,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
