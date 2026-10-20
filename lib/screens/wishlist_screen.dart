import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../data.dart';
import '../state/store.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'product_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Store>(
      builder: (context, store, _) {
        final wishlisted = store.wishlist
            .map((id) => kProducts.firstWhere((p) => p.id == id))
            .toList();

        return CupertinoPageScaffold(
          navigationBar: const CupertinoNavigationBar(
            middle: Text('Wishlist'),
          ),
          child: SafeArea(
            child: wishlisted.isEmpty
                ? EmptyState(
                    icon: CupertinoIcons.heart,
                    title: 'Your wishlist is empty',
                    message:
                        'Tap the heart on any product to save it here.',
                    action: CupertinoButton(
                      color: AppColors.accent,
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Browse products',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Expanded(
                        child: GridView(
                          padding: const EdgeInsets.all(kPagePadding),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.72,
                          ),
                          children: [
                            for (final product in wishlisted)
                              _WishlistCard(
                                product: product,
                                onTap: () => Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (_) =>
                                        ProductScreen(productId: product.id),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _WishlistCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const _WishlistCard({
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductImage(
            imageAsset: product.imageAsset,
            height: 150,
            width: double.infinity,
            radius: kRadiusImageTile,
          ),
          const SizedBox(height: 10),
          Text(
            product.brand,
            style: AppText.caption12.copyWith(
              color: AppColors.accent,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            product.name,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            formatPrice(product.price),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              fontFeatures: [
                FontFeature.tabularFigures(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
