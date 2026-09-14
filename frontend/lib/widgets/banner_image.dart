import 'package:flutter/material.dart';

import '../core/theme/app_tokens.dart';

/// Network image for event banners / project covers, with a brand-gradient
/// placeholder when there is no image or it fails to load.
class BannerImage extends StatelessWidget {
  final String? url;
  final IconData icon;

  const BannerImage({super.key, this.url, this.icon = Icons.event_rounded});

  @override
  Widget build(BuildContext context) {
    final imageUrl = url;
    if (imageUrl != null && imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.brandGradient),
      child: Center(
        child: Icon(icon, size: 40, color: Colors.white.withValues(alpha: 0.35)),
      ),
    );
  }
}
