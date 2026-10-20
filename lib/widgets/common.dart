import 'package:flutter/cupertino.dart';

import '../theme.dart';

class ProductImage extends StatelessWidget {
  final String imageAsset;
  final double height;
  final double width;
  final BoxFit fit;
  final double radius;

  const ProductImage({
    super.key,
    required this.imageAsset,
    this.height = 200,
    this.width = double.infinity,
    this.fit = BoxFit.cover,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        imageAsset,
        height: height,
        width: width,
        fit: fit,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) => Container(
          height: height,
          width: width,
          color: AppColors.softGreenTint,
          child: const Center(
            child: Icon(CupertinoIcons.photo, size: 48, color: AppColors.secondaryText),
          ),
        ),
      ),
    );
  }
}

class LabelChips extends StatelessWidget {
  final List<String> labels;

  const LabelChips({super.key, required this.labels});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: labels
          .map(
            (l) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.softGreenTint,
                borderRadius: BorderRadius.circular(kRadiusPill),
              ),
              child: Text(
                l,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(kPagePadding, 16, kPagePadding, 8),
      child: Text(
        title,
        style: AppText.headline17,
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.softGreenTint,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: AppColors.accent),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppText.headline17,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppText.body15.copyWith(
                color: AppColors.secondaryText,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

OverlayEntry? _toastEntry;

void _dismissToast() {
  _toastEntry?.remove();
  _toastEntry = null;
}

void showAppToast(BuildContext context, String message) {
  _dismissToast();
  final entry = OverlayEntry(
    builder: (_) => Positioned(
      bottom: 24 + MediaQuery.of(context).padding.bottom,
      left: 16,
      right: 16,
      child: _Toast(message: message),
    ),
  );
  _toastEntry = entry;
  Overlay.of(context).insert(entry);
  Future.delayed(const Duration(seconds: 2), () {
    if (_toastEntry == entry) _dismissToast();
  });
}

class _Toast extends StatelessWidget {
  final String message;
  const _Toast({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.text,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
