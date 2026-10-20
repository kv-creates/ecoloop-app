import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data.dart';
import '../state/store.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ProductScreen extends StatefulWidget {
  final int productId;

  const ProductScreen({super.key, required this.productId});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  Product? _product;
  int _qty = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _product = kProducts.firstWhere(
      (p) => p.id == widget.productId,
      orElse: () => kProducts.first,
    );
    if (_product!.id != widget.productId) {
      _product = null;
    }
  }

  void _addToCart(BuildContext context) {
    if (_product == null) return;
    context.read<Store>().add(_product!.id, _qty);
    HapticFeedback.selectionClick();
    showAppToast(context, 'Added to cart');
  }

  @override
  Widget build(BuildContext context) {
    if (_product == null) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Product'),
        ),
        child: EmptyState(
          icon: CupertinoIcons.doc,
          title: 'Product not found',
          message: 'This product does not exist.',
        ),
      );
    }
    final product = _product!;
    final wishlisted = context.watch<Store>().isWishlisted(product.id);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            context.read<Store>().toggleWish(product.id);
            HapticFeedback.selectionClick();
          },
          child: Icon(
            wishlisted ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
            color: wishlisted ? AppColors.danger : null,
            size: 22,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            ProductImage(
              imageAsset: product.imageAsset,
              height: 260,
              width: double.infinity,
              radius: 0,
            ),
            Padding(
              padding: const EdgeInsets.all(kPagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.brand,
                              style: AppText.caption12.copyWith(
                                color: AppColors.accent,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.softGreenTint,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CupertinoIcons.share,
                          color: AppColors.secondaryText,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    formatPrice(product.price),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontFeatures: [
                        FontFeature.tabularFigures(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  LabelChips(labels: product.labels),
                  const SizedBox(height: 20),
                  Text(
                    'About this product',
                    style: AppText.headline17,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: AppText.body15,
                  ),
                  const SizedBox(height: 20),
                  _CollapsibleSection(
                    title: 'Features',
                    content:
                        'This product carries the following attributes: '
                        '${product.labels.join(', ')}. '
                        'Each feature is verified from the product page.',
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            _BottomBar(
              product: product,
              qty: _qty,
              onQtyChanged: (v) => setState(() => _qty = v),
              onAdd: () => _addToCart(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollapsibleSection extends StatelessWidget {
  final String title;
  final String content;

  const _CollapsibleSection({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(kRadiusCard),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(kPagePadding),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ),
                const Icon(
                  CupertinoIcons.chevron_down,
                  size: 18,
                  color: AppColors.secondaryText,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              kPagePadding, 0, kPagePadding, kPagePadding,
            ),
            child: Text(
              content,
              style: AppText.body15.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final Product product;
  final int qty;
  final ValueChanged<int> onQtyChanged;
  final VoidCallback onAdd;

  const _BottomBar({
    required this.product,
    required this.qty,
    required this.onQtyChanged,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kPagePadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.hairline),
        ),
        boxShadow: [
          AppShadow.soft.copyWith(spreadRadius: 0),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quantity',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _QtyButton(
                      icon: CupertinoIcons.minus,
                      onPressed: qty > 1 ? () => onQtyChanged(qty - 1) : null,
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.softGreenTint,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$qty',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                          fontFeatures: [
                            FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                    ),
                    _QtyButton(
                      icon: CupertinoIcons.plus,
                      onPressed: qty < 10 ? () => onQtyChanged(qty + 1) : null,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: CupertinoButton.filled(
                onPressed: () => onAdd(),
                child: Text(
                  'Add to cart ${formatPrice(product.price)}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _QtyButton({
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.all(10),
      onPressed: onPressed,
      child: Icon(
        icon,
        size: 20,
        color: onPressed != null ? AppColors.primary : AppColors.secondaryText,
      ),
    );
  }
}
