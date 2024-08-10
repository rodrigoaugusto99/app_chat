import 'package:app_chat/ui/utils/helpers.dart';
import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? imageNetwork;
  final String title;
  final Function()? onTap;
  const HomeAppBar({
    super.key,
    required this.imageNetwork,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          children: [
            if (imageNetwork != '')
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.network(imageNetwork!),
              ),
            widthSeparator(24),
            styledText(
              color: Colors.white,
              text: title,
              fontWeight: FontWeight.bold,
              fontSize: 26,
            ),
            const Spacer(),
            GestureDetector(
              onTap: onTap,
              child: const Icon(
                Icons.logout,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(86);
}
