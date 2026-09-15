import 'package:flutter/material.dart';

import '../core/theme/app_tokens.dart';

/// Network image for event banners / project covers, with a brand-gradient
/// placeholder when there is no image or it fails to load.
///
/// Most uploads are portrait event posters, not landscape banners — [fit]
/// defaults to [BoxFit.cover] for list thumbnails (a small, consistent crop
/// is fine there), but full-screen hero usage should pass
/// [BoxFit.contain] so the whole poster stays visible; the gradient
/// placeholder shows through as letterboxing in that case.
class BannerImage extends StatelessWidget {
  final String? url;
  final IconData icon;
  final BoxFit fit;

  const BannerImage({super.key, this.url, this.icon = Icons.event_rounded, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    final imageUrl = url;
    return Stack(
      fit: StackFit.expand,
      children: [
        _placeholder(),
        if (imageUrl != null && imageUrl.startsWith('http'))
          Image.network(
            imageUrl,
            fit: fit,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
      ],
    );
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
